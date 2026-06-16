import 'package:flutter/foundation.dart';
import 'package:sameway/core/api/api_config.dart';
import 'package:sameway/core/api/models/reminder_settings.dart';
import 'package:sameway/core/api/repositories/notifications_repository.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/api/repositories/users_repository.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/features/ride_day/ride_day_models.dart';

export 'package:sameway/features/ride_day/ride_day_models.dart';

/// Ride-day state: today's ride, live polling, notifications, reminder settings.
class RideDayStore extends ChangeNotifier {
  RideDayStore._();

  static final RideDayStore instance = RideDayStore._();

  TodayRideSummary? _today;
  LiveRide? _live;
  NotificationPage? _notifications;
  ReminderSettings _reminders = const ReminderSettings();

  bool _loadingToday = false;
  bool _loadingLive = false;
  bool _loadingNotifications = false;
  bool _notifying = false;
  String? _error;

  TodayRideSummary? get today => _today;
  LiveRide? get live => _live;
  NotificationPage? get notifications => _notifications;
  ReminderSettings get reminders => _reminders;
  bool get loadingToday => _loadingToday;
  bool get loadingLive => _loadingLive;
  bool get loadingNotifications => _loadingNotifications;
  bool get notifying => _notifying;
  String? get error => _error;

  Future<void> refreshToday() async {
    if (!ApiConfig.enabled) return;
    _loadingToday = true;
    _error = null;
    notifyListeners();
    try {
      final data = await RidesRepository.instance.getTodayRide();
      _today = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingToday = false;
      notifyListeners();
    }
  }

  Future<void> refreshLive() async {
    final rideId = _today?.rideId ?? _live?.id;
    if (rideId == null || !ApiConfig.enabled) return;
    _loadingLive = true;
    notifyListeners();
    try {
      _live = await RidesRepository.instance.getLiveRide(rideId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingLive = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await refreshToday();
    if (_today != null) {
      await refreshLive();
    }
    await refreshNotifications();
    await refreshReminderSettings();
  }

  Future<void> refreshNotifications() async {
    if (!ApiConfig.enabled) return;
    _loadingNotifications = true;
    notifyListeners();
    try {
      _notifications = await NotificationsRepository.instance.list();
    } catch (_) {
      _notifications = const NotificationPage(items: [], total: 0, unreadCount: 0);
    } finally {
      _loadingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> refreshReminderSettings() async {
    if (!ApiConfig.enabled) return;
    try {
      _reminders = await UsersRepository.instance.getReminderSettings();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    _reminders = settings;
    notifyListeners();
    try {
      _reminders = await UsersRepository.instance.updateReminderSettings(settings);
      notifyListeners();
    } catch (_) {}
  }

  Future<int?> notifyRiders() async {
    final rideId = _today?.rideId ?? _live?.id;
    if (rideId == null) return null;
    _notifying = true;
    notifyListeners();
    try {
      final count = await RidesRepository.instance.headingOut(rideId);
      await refreshLive();
      return count;
    } finally {
      _notifying = false;
      notifyListeners();
    }
  }

  Future<void> updateMyStatus(String status) async {
    final rideId = _today?.rideId ?? _live?.id;
    final userId = AppSession.instance.currentUser?.id;
    if (rideId == null || userId == null) return;
    await RidesRepository.instance.updateParticipantStatus(rideId, userId, status);
    await refreshLive();
  }

  void clearOnSignOut() {
    _today = null;
    _live = null;
    _notifications = null;
    _reminders = const ReminderSettings();
    _error = null;
    notifyListeners();
  }
}
