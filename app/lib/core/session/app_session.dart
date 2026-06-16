import 'package:flutter/foundation.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/maps/search_location_resolver.dart';
import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/api/api_config.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/api/repositories/auth_repository.dart';
import 'package:sameway/core/api/repositories/users_repository.dart';
import 'package:sameway/core/api/user_mapper.dart';
import 'package:sameway/core/push/push_service.dart';
import 'package:sameway/core/session/user_profile.dart';
import 'package:sameway/core/validation/form_validators.dart';
import 'package:sameway/features/onboarding/onboarding_state.dart';
import 'package:sameway/features/ride_day/ride_day_store.dart';

/// Auth + onboarding session backed by the Same Way API.
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _ready = false;
  bool _isAuthenticating = false;

  bool get isReady => _ready;
  bool get isAuthenticating => _isAuthenticating;
  UserProfile? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  UserProfile? get currentUser => _currentUser;

  Future<void> initialize() async {
    ApiClient.instance.initialize(
      onRefreshFailed: () async {
        _currentUser = null;
        notifyListeners();
      },
    );

    if (!ApiConfig.enabled) {
      _ready = true;
      notifyListeners();
      return;
    }

    try {
      final user = await AuthRepository.instance.fetchMe();
      _currentUser = user;
      _syncOnboardingState();
    } catch (_) {
      _currentUser = null;
    }
    _ready = true;
    notifyListeners();
  }

  void _syncOnboardingState() {
    final user = _currentUser;
    final state = OnboardingState.instance;
    if (user == null) {
      state.reset();
      return;
    }
    state.commuteType = user.commuteType;
    state.hasVehicleDetails = user.hasVehicleDetails;
    state.designation = user.designation;
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

    try {
      _isAuthenticating = true;
      notifyListeners();
      _currentUser = await AuthRepository.instance.signup(
        fullName: fullName,
        workEmail: email,
        phone: phone,
        password: password,
      );
      _syncOnboardingState();
      await AppDataStore.instance.refreshAll();
      await RideDayStore.instance.refreshAll();
      await PushService.instance.registerToken();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not create account. Is the backend running?';
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String workEmail,
    required String password,
  }) async {
    try {
      _isAuthenticating = true;
      notifyListeners();
      _currentUser = await AuthRepository.instance.signin(
        workEmail: workEmail,
        password: password,
      );
      _syncOnboardingState();
      await AppDataStore.instance.refreshAll();
      await RideDayStore.instance.refreshAll();
      await PushService.instance.registerToken();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not sign in. Is the backend running?';
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthRepository.instance.signOut();
    _currentUser = null;
    SearchLocationResolver.clearSessionCache();
    AppDataStore.instance.clearOnSignOut();
    RideDayStore.instance.clearOnSignOut();
    OnboardingState.instance.reset();
    notifyListeners();
  }

  Future<void> refreshMe() async {
    final user = await AuthRepository.instance.fetchMe();
    if (user != null) {
      _currentUser = user;
      _syncOnboardingState();
      notifyListeners();
    }
  }

  Future<void> updateCurrent(void Function(UserProfile user) mutate) async {
    final user = _currentUser;
    if (user == null) return;
    mutate(user);
    notifyListeners();

    try {
      await UsersRepository.instance.updateProfile({
        if (user.fullName.isNotEmpty) 'fullName': user.fullName,
        'commuteType': UserMapper.commuteTypeToApi(user.commuteType),
        if (user.photoUrl != null && user.photoUrl!.startsWith('http')) 'photoUrl': user.photoUrl,
        if (user.companyName != null) 'companyName': user.companyName,
        if (user.designation != null) 'designation': user.designation,
        'idVisibility': user.idVisibility == IdVisibility.publicToRiders
            ? 'PUBLIC_TO_RIDERS'
            : 'ADMIN_ONLY',
      });
      await refreshMe();
    } catch (_) {}
  }

  Future<void> syncVehicle(VehicleInfo vehicle) async {
    final user = _currentUser;
    if (user == null) return;
    try {
      if (vehicle.id != null) {
        // updates handled separately if needed
      } else {
        final saved = await UsersRepository.instance.addVehicle(vehicle);
        user.vehicle = saved;
      }
      await refreshMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> syncCommutePreferences(CommutePreferences prefs) async {
    try {
      await UsersRepository.instance.updateCommutePreferences(prefs);
      await refreshMe();
    } catch (_) {}
  }

  Future<void> syncPlace({
    required String label,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final user = _currentUser;
    if (user != null) {
      if (label == 'HOME') {
        user.homeAddress = address;
        user.homeLat = lat;
        user.homeLng = lng;
      } else if (label == 'OFFICE') {
        user.officeAddress = address;
        user.officeLat = lat;
        user.officeLng = lng;
      }
      notifyListeners();
    }

    try {
      await UsersRepository.instance.savePlace(
        label: label,
        address: address,
        lat: lat,
        lng: lng,
      );
      await refreshMe();
    } catch (_) {}
  }

  String? onboardingRouteForCurrentUser() {
    final user = _currentUser;
    if (user == null) return null;
    return FormValidators.routeForPhase(user.phase);
  }
}
