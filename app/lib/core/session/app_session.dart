import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/validation/form_validators.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';

/// Local auth + onboarding session (persists across restarts).
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  static const _usersKey = 'sameway_users';
  static const _currentUserIdKey = 'sameway_current_user_id';

  bool _ready = false;
  List<UserProfile> _users = [];
  String? _currentUserId;

  bool get isReady => _ready;
  bool get isLoggedIn => _currentUserId != null;
  UserProfile? get currentUser =>
      _currentUserId == null ? null : _userById(_currentUserId!);

  UserProfile? _userById(String id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw != null) {
      _users = UserProfile.decodeList(raw);
    }
    _currentUserId = prefs.getString(_currentUserIdKey);
    _syncOnboardingState();
    _ready = true;
    notifyListeners();
  }

  void _syncOnboardingState() {
    final user = currentUser;
    final state = OnboardingState.instance;
    if (user == null) {
      state.reset();
      return;
    }
    state.commuteType = user.commuteType;
    state.hasVehicleDetails = user.hasVehicleDetails;
    state.designation = user.designation;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, UserProfile.encodeList(_users));
    if (_currentUserId != null) {
      await prefs.setString(_currentUserIdKey, _currentUserId!);
    } else {
      await prefs.remove(_currentUserIdKey);
    }
  }

  Future<void> _commit(UserProfile user) async {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    _currentUserId = user.id;
    _syncOnboardingState();
    await _persist();
    notifyListeners();
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode('sameway:$password');
    return sha256.convert(bytes).toString();
  }

  Future<String?> register({
    required String fullName,
    required String workEmail,
    required String phone,
    required String password,
  }) async {
    final email = workEmail.trim().toLowerCase();
    final emailErr = FormValidators.workEmail(email);
    if (emailErr != null) return emailErr;

    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    final exists = _users.any((u) {
      final uPhone = u.phone.replaceAll(RegExp(r'\D'), '');
      return u.workEmail == email || uPhone == phoneDigits;
    });
    if (exists) return 'An account with this email or phone already exists';

    final user = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      workEmail: email,
      phone: phone.trim(),
      passwordHash: hashPassword(password),
      workEmailVerified: FormValidators.isEmailDomainAutoVerified(email),
      phase: OnboardingPhase.accountCreated,
    );

    await _commit(user);
    return null;
  }

  Future<String?> signIn({
    required String workEmail,
    required String password,
  }) async {
    final email = workEmail.trim().toLowerCase();
    UserProfile? user;
    for (final u in _users) {
      if (u.workEmail == email) {
        user = u;
        break;
      }
    }
    if (user == null) return 'No account found for this email';
    if (user.passwordHash != hashPassword(password)) {
      return 'Incorrect password';
    }
    _currentUserId = user.id;
    _syncOnboardingState();
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    _currentUserId = null;
    OnboardingState.instance.reset();
    await _persist();
    notifyListeners();
  }

  Future<void> updateCurrent(void Function(UserProfile user) mutate) async {
    final user = currentUser;
    if (user == null) return;
    mutate(user);
    await _commit(user);
  }

  String? onboardingRouteForCurrentUser() {
    final user = currentUser;
    if (user == null) return null;
    return FormValidators.routeForPhase(user.phase);
  }
}
