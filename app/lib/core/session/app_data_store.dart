import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_session.dart';

class AppDataStore extends ChangeNotifier {
  AppDataStore._();

  static final AppDataStore instance = AppDataStore._();

  static const _storageKey = 'sameway_app_data';
  static final _random = Random();

  static String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';

  Map<String, UserAppData> _byUser = {};
  bool _ready = false;

  bool get isReady => _ready;

  UserAppData? get _currentData {
    final userId = AppSession.instance.currentUser?.id;
    if (userId == null) return null;
    return _byUser.putIfAbsent(userId, UserAppData.new);
  }

  PostRideDraft get postRideDraft =>
      _currentData?.postRideDraft ?? PostRideDraft();

  List<UserRide> get rides => List.unmodifiable(_currentData?.rides ?? const []);

  List<UserRide> get upcomingRides =>
      rides.where((r) => r.isUpcoming).toList();

  List<UserRide> get completedRides =>
      rides.where((r) => r.status == RideStatus.completed).toList();

  List<JoinRequest> get pendingJoinRequests => (_currentData?.joinRequests ?? [])
      .where((r) => r.status == RideStatus.pending)
      .toList();

  List<ChatThread> get chatThreads =>
      List.unmodifiable(_currentData?.chats ?? const []);

  int get unreadChatCount =>
      chatThreads.where((t) => t.unread).length;

  UserRide? get activePostedRide => rides.cast<UserRide?>().firstWhere(
        (r) => r != null && r.isDriver && r.isUpcoming,
        orElse: () => null,
      );

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _byUser = UserAppData.decodeMap(raw);
      } catch (_) {
        _byUser = {};
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, UserAppData.encodeMap(_byUser));
    notifyListeners();
  }

  Future<void> updatePostRideDraft(void Function(PostRideDraft draft) edit) async {
    final data = _currentData;
    if (data == null) return;
    edit(data.postRideDraft);
    await _persist();
  }

  Future<void> addStop(String address) async {
    await updatePostRideDraft((d) {
      if (address.trim().isNotEmpty) d.stops = [...d.stops, address.trim()];
    });
  }

  Future<String> publishPostedRide() async {
    final data = _currentData;
    final draft = data?.postRideDraft;
    if (data == null || draft == null || !draft.hasRoute) {
      throw StateError('Route is incomplete');
    }

    final rideId = _newId();
    final timeLabel = '${draft.dateLabel ?? 'Tomorrow'} · ${draft.departTime ?? '8:30 AM'}';
    final ride = UserRide(
      id: rideId,
      route: draft.routeLabel,
      from: draft.startAddress!,
      to: draft.endAddress!,
      timeLabel: timeLabel,
      detail: '${draft.seats} seat${draft.seats == 1 ? '' : 's'} · ${draft.repeat}',
      status: RideStatus.confirmed,
      isDriver: true,
    );
    data.rides.insert(0, ride);

    if (data.joinRequests.where((r) => r.rideId == rideId).isEmpty) {
      data.joinRequests.addAll([
        JoinRequest(
          id: _newId(),
          riderName: 'Karim R.',
          route: '${_shortPlace(draft.startAddress!)} → near your route',
          matchLabel: '92% match',
          note: 'Regular commuter · verified',
          rideId: rideId,
        ),
        JoinRequest(
          id: _newId(),
          riderName: 'Sadia K.',
          route: 'Azampur → ${_shortPlace(draft.endAddress!)} area',
          matchLabel: '87% match',
          note: 'Prefers front seat',
          rideId: rideId,
        ),
        JoinRequest(
          id: _newId(),
          riderName: 'Tanvir M.',
          route: 'House Building → Farmgate',
          matchLabel: '81% match',
          note: 'New to Same Way',
          rideId: rideId,
        ),
      ]);
    }

    await _persist();
    return rideId;
  }

  Future<({UserRide ride, ChatThread chat})> requestJoinRide({
    required String driverName,
    required String route,
    required String from,
    required String to,
    required String timeLabel,
    required String detail,
    String? matchLabel,
  }) async {
    final data = _currentData;
    if (data == null) throw StateError('Not signed in');

    final rideId = _newId();
    final threadId = _newId();
    final thread = ChatThread(
      id: threadId,
      peerName: driverName,
      rideContext: '$route · $timeLabel',
      messages: [
        ChatMessage(
          text: 'Hi! I\'d like to join your ride. ${matchLabel ?? ''}'.trim(),
          isMine: true,
          sentAt: DateTime.now(),
        ),
      ],
    );

    final ride = UserRide(
      id: rideId,
      route: route,
      from: from,
      to: to,
      timeLabel: timeLabel,
      detail: detail,
      status: RideStatus.pending,
      driverName: driverName,
      chatThreadId: threadId,
    );

    data.rides.insert(0, ride);
    data.chats.insert(0, thread);
    await _persist();
    return (ride: ride, chat: thread);
  }

  Future<void> acceptJoinRequest(String requestId) async {
    final data = _currentData;
    if (data == null) return;

    final request = data.joinRequests.firstWhere((r) => r.id == requestId);
    request.status = RideStatus.confirmed;

    final threadId = _newId();
    data.chats.insert(
      0,
      ChatThread(
        id: threadId,
        peerName: request.riderName,
        rideContext: request.route,
        messages: [
          ChatMessage(
            text: 'Ride confirmed! See you tomorrow.',
            isMine: true,
            sentAt: DateTime.now(),
          ),
        ],
      ),
    );

    await _persist();
  }

  Future<void> declineJoinRequest(String requestId) async {
    final data = _currentData;
    if (data == null) return;
    final request = data.joinRequests.firstWhere((r) => r.id == requestId);
    request.status = RideStatus.declined;
    await _persist();
  }

  Future<void> sendChatMessage(String threadId, String text) async {
    final data = _currentData;
    if (data == null || text.trim().isEmpty) return;

    final thread = data.chats.firstWhere((t) => t.id == threadId);
    thread.messages.add(
      ChatMessage(text: text.trim(), isMine: true, sentAt: DateTime.now()),
    );
    thread.unread = false;
    await _persist();
  }

  Future<void> markChatRead(String threadId) async {
    final data = _currentData;
    if (data == null) return;
    final thread = data.chats.cast<ChatThread?>().firstWhere(
          (t) => t?.id == threadId,
          orElse: () => null,
        );
    if (thread != null && thread.unread) {
      thread.unread = false;
      await _persist();
    }
  }

  ChatThread? threadById(String id) {
    for (final t in chatThreads) {
      if (t.id == id) return t;
    }
    return null;
  }

  String _shortPlace(String address) {
    final parts = address.split(',');
    return parts.first.trim();
  }
}
