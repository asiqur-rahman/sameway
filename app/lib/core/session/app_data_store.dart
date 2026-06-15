import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sameway/core/api/api_config.dart';
import 'package:sameway/core/api/repositories/bookings_repository.dart';
import 'package:sameway/core/api/repositories/chat_repository.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/utils/commute_time_format.dart';

class AppDataStore extends ChangeNotifier {
  AppDataStore._();

  static final AppDataStore instance = AppDataStore._();

  static const _storageKey = 'sameway_app_data';

  PostRideDraft _draft = PostRideDraft();
  List<UserRide> _rides = [];
  List<JoinRequest> _joinRequests = [];
  List<ChatThread> _chats = [];
  String? _activePostedRideId;
  bool _ready = false;

  bool _loadingBookings = false;
  bool _refreshingBookings = false;
  bool _loadingChats = false;
  bool _refreshingChats = false;
  bool _loadingRequests = false;
  bool _refreshingRequests = false;
  bool _loadingConversation = false;
  bool _isPublishing = false;
  bool _isRequestingJoin = false;
  bool _isSendingMessage = false;
  final Set<String> _processingRequestIds = {};

  String? _bookingsError;
  String? _chatsError;
  String? _requestsError;
  String? _conversationError;
  String? _loadingConversationId;

  bool get isReady => _ready;
  bool get isLoadingBookings => _loadingBookings;
  bool get isRefreshingBookings => _refreshingBookings;
  bool get isLoadingChats => _loadingChats;
  bool get isRefreshingChats => _refreshingChats;
  bool get isLoadingRequests => _loadingRequests;
  bool get isRefreshingRequests => _refreshingRequests;
  bool get isLoadingConversation => _loadingConversation;
  bool get isPublishing => _isPublishing;
  bool get isRequestingJoin => _isRequestingJoin;
  bool get isSendingMessage => _isSendingMessage;
  String? get bookingsError => _bookingsError;
  String? get chatsError => _chatsError;
  String? get requestsError => _requestsError;
  String? get conversationError => _conversationError;

  bool isProcessingRequest(String id) => _processingRequestIds.contains(id);

  PostRideDraft get postRideDraft => _draft;
  List<UserRide> get rides => List.unmodifiable(_rides);
  List<UserRide> get upcomingRides => _rides.where((r) => r.isUpcoming).toList();
  List<UserRide> get completedRides =>
      _rides.where((r) => r.status == RideStatus.completed).toList();
  List<JoinRequest> get pendingJoinRequests =>
      _joinRequests.where((r) => r.status == RideStatus.pending).toList();
  List<ChatThread> get chatThreads => List.unmodifiable(_chats);
  int get unreadChatCount => _chats.where((t) => t.unread).length;

  UserRide? get activePostedRide {
    if (_activePostedRideId != null) {
      for (final r in _rides) {
        if (r.id == _activePostedRideId) return r;
      }
    }
    for (final r in _rides) {
      if (r.isDriver && r.isUpcoming) return r;
    }
    return null;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = UserAppData.decodeMap(raw);
        final userId = AppSession.instance.currentUser?.id;
        if (userId != null && map.containsKey(userId)) {
          _draft = map[userId]!.postRideDraft;
          _activePostedRideId = map[userId]!.activePostedRideId;
        }
      } catch (_) {}
    }
    _ready = true;
    notifyListeners();
    if (AppSession.instance.isLoggedIn && ApiConfig.enabled) {
      await refreshAll();
    }
  }

  Future<void> _persistDraft() async {
    final userId = AppSession.instance.currentUser?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = UserAppData(
      postRideDraft: _draft,
      activePostedRideId: _activePostedRideId,
    );
    await prefs.setString(_storageKey, UserAppData.encodeMap({userId: data}));
    notifyListeners();
  }

  Future<void> refreshAll() async {
    if (!ApiConfig.enabled || !AppSession.instance.isLoggedIn) return;
    await Future.wait([
      refreshBookings(),
      refreshChats(),
      refreshJoinRequests(),
    ]);
  }

  Future<void> refreshBookings({bool refresh = false}) async {
    if (!ApiConfig.enabled || !AppSession.instance.isLoggedIn) return;
    if (_loadingBookings && !refresh) return;

    if (refresh) {
      _refreshingBookings = true;
    } else {
      _loadingBookings = true;
    }
    _bookingsError = null;
    notifyListeners();

    try {
      final result = await BookingsRepository.instance.fetchMine();
      _rides = [...result.upcoming, ...result.completed];
    } catch (e) {
      _bookingsError = 'Could not load rides';
      if (kDebugMode) debugPrint('refreshBookings: $e');
    } finally {
      _loadingBookings = false;
      _refreshingBookings = false;
      notifyListeners();
    }
  }

  Future<void> refreshChats({bool refresh = false}) async {
    if (!ApiConfig.enabled || !AppSession.instance.isLoggedIn) return;
    if (_loadingChats && !refresh) return;

    if (refresh) {
      _refreshingChats = true;
    } else {
      _loadingChats = true;
    }
    _chatsError = null;
    notifyListeners();

    try {
      _chats = await ChatRepository.instance.fetchConversations();
    } catch (e) {
      _chatsError = 'Could not load messages';
      if (kDebugMode) debugPrint('refreshChats: $e');
    } finally {
      _loadingChats = false;
      _refreshingChats = false;
      notifyListeners();
    }
  }

  Future<void> refreshJoinRequests({bool refresh = false}) async {
    if (!ApiConfig.enabled || !AppSession.instance.isLoggedIn) return;

    final rideId = _activePostedRideId ?? activePostedRide?.id;
    if (rideId == null) {
      _joinRequests = [];
      _loadingRequests = false;
      _refreshingRequests = false;
      notifyListeners();
      return;
    }

    if (_loadingRequests && !refresh) return;

    if (refresh) {
      _refreshingRequests = true;
    } else {
      _loadingRequests = true;
    }
    _requestsError = null;
    notifyListeners();

    try {
      final rows = await RidesRepository.instance.getIncomingRequests(rideId);
      _joinRequests = rows.map((r) {
        final rider = r['rider'] as Map<String, dynamic>? ?? {};
        final score = r['matchScore'] as num?;
        return JoinRequest(
          id: r['id'] as String,
          riderName: rider['fullName'] as String? ?? 'Rider',
          route: r['riderNote'] as String? ?? 'Join request',
          matchLabel: score != null ? '${score.round()}% match' : 'Match pending',
          note: r['riderNote'] as String? ?? '',
          rideId: rideId,
        );
      }).toList();
    } catch (e) {
      _requestsError = 'Could not load requests';
      if (kDebugMode) debugPrint('refreshJoinRequests: $e');
    } finally {
      _loadingRequests = false;
      _refreshingRequests = false;
      notifyListeners();
    }
  }

  Future<void> updatePostRideDraft(void Function(PostRideDraft draft) edit) async {
    edit(_draft);
    await _persistDraft();
  }

  Future<void> addStop(String address) async {
    await updatePostRideDraft((d) {
      if (address.trim().isNotEmpty) d.stops = [...d.stops, address.trim()];
    });
  }

  Future<String> publishPostedRide() async {
    final draft = _draft;
    final user = AppSession.instance.currentUser;
    if (user == null || !draft.hasRoute) {
      throw StateError('Route is incomplete');
    }

    final vehicleId = user.vehicle?.id;
    if (vehicleId == null) throw StateError('Add a vehicle before posting');

    _isPublishing = true;
    notifyListeners();

    try {
      final startLat = draft.startLat ?? user.homeLat ?? 23.8759;
      final startLng = draft.startLng ?? user.homeLng ?? 90.3795;
      final endLat = draft.endLat ?? user.officeLat ?? 23.7330;
      final endLng = draft.endLng ?? user.officeLng ?? 90.4172;

      final date = draft.dateLabel != null
          ? DateFormat('EEE, MMM d').parse(draft.dateLabel!)
          : DateTime.now();
      final time =
          CommuteTimeFormat.parse(draft.departTime) ?? const TimeOfDay(hour: 8, minute: 30);
      final departureAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      final repeat = switch (draft.repeat) {
        'Daily' => 'DAILY',
        'Weekdays' => 'WEEKDAYS',
        _ => 'ONCE',
      };

      final rideId = await RidesRepository.instance.createRide(
        vehicleId: vehicleId,
        startAddress: draft.startAddress!,
        startLat: startLat,
        startLng: startLng,
        endAddress: draft.endAddress!,
        endLat: endLat,
        endLng: endLng,
        departureAt: departureAt,
        availableSeats: draft.seats,
        repeat: repeat,
      );

      _activePostedRideId = rideId;
      await _persistDraft();
      await refreshBookings();
      await refreshJoinRequests();
      return rideId;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  Future<void> requestJoinRide({
    required String rideId,
    required String driverName,
    required String route,
    required String from,
    required String to,
    required String timeLabel,
    required String detail,
    String? matchLabel,
  }) async {
    _isRequestingJoin = true;
    notifyListeners();
    try {
      await RidesRepository.instance.requestJoin(
        rideId,
        riderNote: 'Hi! I\'d like to join your ride. ${matchLabel ?? ''}'.trim(),
      );
      await refreshBookings();
    } finally {
      _isRequestingJoin = false;
      notifyListeners();
    }
  }

  Future<void> acceptJoinRequest(String requestId) async {
    final rideId = _activePostedRideId ?? activePostedRide?.id;
    if (rideId == null) return;
    _processingRequestIds.add(requestId);
    notifyListeners();
    try {
      await RidesRepository.instance.acceptRequest(rideId, requestId);
      await refreshJoinRequests();
      await refreshBookings();
      await refreshChats();
    } finally {
      _processingRequestIds.remove(requestId);
      notifyListeners();
    }
  }

  Future<void> declineJoinRequest(String requestId) async {
    final rideId = _activePostedRideId ?? activePostedRide?.id;
    if (rideId == null) return;
    _processingRequestIds.add(requestId);
    notifyListeners();
    try {
      await RidesRepository.instance.declineRequest(rideId, requestId);
      await refreshJoinRequests();
    } finally {
      _processingRequestIds.remove(requestId);
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String threadId, String text) async {
    if (text.trim().isEmpty) return;
    _isSendingMessage = true;
    notifyListeners();
    try {
      await ChatRepository.instance.sendMessage(threadId, text.trim());
      await refreshChats();
      await _mergeMessages(threadId);
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  Future<void> markChatRead(String threadId) async {
    try {
      await ChatRepository.instance.markRead(threadId);
      final thread = threadById(threadId);
      if (thread != null && thread.unread) {
        thread.unread = false;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadConversation(String threadId) async {
    _loadingConversation = true;
    _loadingConversationId = threadId;
    _conversationError = null;
    notifyListeners();
    try {
      await _mergeMessages(threadId);
    } catch (e) {
      _conversationError = 'Could not load conversation';
      if (kDebugMode) debugPrint('loadConversation: $e');
    } finally {
      _loadingConversation = false;
      _loadingConversationId = null;
      notifyListeners();
    }
  }

  Future<void> _mergeMessages(String threadId) async {
    final messages = await ChatRepository.instance.fetchMessages(threadId);
    final thread = threadById(threadId);
    if (thread != null) {
      thread.messages
        ..clear()
        ..addAll(messages);
    }
  }

  bool isLoadingConversationFor(String threadId) =>
      _loadingConversation && _loadingConversationId == threadId;

  ChatThread? threadById(String id) {
    for (final t in _chats) {
      if (t.id == id) return t;
    }
    return null;
  }

  void clearOnSignOut() {
    _rides = [];
    _joinRequests = [];
    _chats = [];
    _activePostedRideId = null;
    _draft = PostRideDraft();
    _bookingsError = null;
    _chatsError = null;
    _requestsError = null;
    notifyListeners();
  }
}
