import 'package:intl/intl.dart';
import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/session/app_data_models.dart';

class BookingsRepository {
  BookingsRepository._();

  static final BookingsRepository instance = BookingsRepository._();
  final _client = ApiClient.instance;

  Future<({List<UserRide> upcoming, List<UserRide> completed})> fetchMine() async {
    final upcomingData = await _client.get('/bookings/mine', query: {'status': 'upcoming'});
    final completedData = await _client.get('/bookings/mine', query: {'status': 'completed'});

    return (
      upcoming: _merge(upcomingData),
      completed: _merge(completedData),
    );
  }

  List<UserRide> _merge(Map<String, dynamic> data) {
    final asRider = (data['asRider'] as List<dynamic>? ?? [])
        .map((e) => _fromRiderJson(e as Map<String, dynamic>))
        .toList();
    final asDriver = (data['asDriver'] as List<dynamic>? ?? [])
        .map((e) => _fromDriverJson(e as Map<String, dynamic>))
        .toList();
    return [...asDriver, ...asRider];
  }

  UserRide _fromRiderJson(Map<String, dynamic> json) {
    return UserRide(
      id: json['id'] as String,
      route: json['route'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      timeLabel: _formatTime(json['timeLabel'] as String?),
      detail: json['detail'] as String? ?? '',
      status: _mapStatus(json['status'] as String?),
      driverName: json['driverName'] as String?,
      isDriver: false,
      chatThreadId: json['chatThreadId'] as String?,
    );
  }

  UserRide _fromDriverJson(Map<String, dynamic> json) {
    return UserRide(
      id: json['id'] as String,
      route: json['route'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      timeLabel: _formatTime(json['timeLabel'] as String?),
      detail: json['detail'] as String? ?? '',
      status: _mapStatus(json['status'] as String?),
      isDriver: true,
      chatThreadId: json['chatThreadId'] as String?,
    );
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('EEE, MMM d · h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  RideStatus _mapStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'accepted' || 'confirmed' || 'open' || 'full' => RideStatus.confirmed,
      'completed' => RideStatus.completed,
      'declined' || 'cancelled' => RideStatus.declined,
      _ => RideStatus.pending,
    };
  }
}
