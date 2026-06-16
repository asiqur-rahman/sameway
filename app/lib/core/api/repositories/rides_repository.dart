import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/ride_day/ride_day_models.dart';

/// A saved regular commute route that can auto-post daily rides.
class RegularRoute {
  const RegularRoute({
    required this.id,
    required this.startAddress,
    required this.startLat,
    required this.startLng,
    required this.endAddress,
    required this.endLat,
    required this.endLng,
    required this.scheduleDays,
    required this.departureTime,
    required this.defaultSeats,
    this.name,
  });

  final String id;
  final String? name;
  final String startAddress;
  final double startLat;
  final double startLng;
  final String endAddress;
  final double endLat;
  final double endLng;

  /// Days of week (0=Sunday … 6=Saturday) this route runs.
  final List<int> scheduleDays;

  /// Departure time as "HH:MM".
  final String departureTime;
  final int defaultSeats;

  String get displayName => name?.isNotEmpty == true
      ? name!
      : '${_short(startAddress)} → ${_short(endAddress)}';

  String get scheduleLabel {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final days = scheduleDays.map((d) => names[d % 7]).join('–');
    return '$days · $departureTime · $defaultSeats seat${defaultSeats == 1 ? '' : 's'}';
  }

  String _short(String address) => address.split(',').first.trim();

  factory RegularRoute.fromJson(Map<String, dynamic> json) => RegularRoute(
        id: json['id'] as String,
        name: json['name'] as String?,
        startAddress: json['startAddress'] as String? ?? '',
        startLat: (json['startLat'] as num?)?.toDouble() ?? 0,
        startLng: (json['startLng'] as num?)?.toDouble() ?? 0,
        endAddress: json['endAddress'] as String? ?? '',
        endLat: (json['endLat'] as num?)?.toDouble() ?? 0,
        endLng: (json['endLng'] as num?)?.toDouble() ?? 0,
        scheduleDays: (json['scheduleDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [],
        departureTime: json['departureTime'] as String? ?? '08:00',
        defaultSeats: json['defaultSeats'] as int? ?? 1,
      );
}

class RidesRepository {
  RidesRepository._();

  static final RidesRepository instance = RidesRepository._();
  final _client = ApiClient.instance;

  Future<List<FindRideListing>> search({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String? fromAddress,
    String? toAddress,
    String vehicleFilter = 'ANY',
    String genderPreference = 'NONE',
    int minMatchScore = 50,
    int maxWalkingMinutes = 15,
  }) async {
    final data = await _client.post('/rides/search', data: {
      'fromLat': fromLat,
      'fromLng': fromLng,
      'toLat': toLat,
      'toLng': toLng,
      if (fromAddress != null) 'fromAddress': fromAddress,
      if (toAddress != null) 'toAddress': toAddress,
      'vehicleFilter': vehicleFilter,
      'genderPreference': genderPreference,
      'minMatchScore': minMatchScore,
      'maxWalkingMinutes': maxWalkingMinutes,
    });

    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FindRideListing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createRide({
    required String vehicleId,
    required String startAddress,
    required double startLat,
    required double startLng,
    required String endAddress,
    required double endLat,
    required double endLng,
    required DateTime departureAt,
    required int availableSeats,
    String repeat = 'ONCE',
    List<Map<String, dynamic>> stops = const [],
  }) async {
    final data = await _client.post('/rides', data: {
      'vehicleId': vehicleId,
      'start': {'address': startAddress, 'lat': startLat, 'lng': startLng},
      'end': {'address': endAddress, 'lat': endLat, 'lng': endLng},
      'stops': stops,
      'departureAt': departureAt.toUtc().toIso8601String(),
      'repeat': repeat,
      'availableSeats': availableSeats,
    });
    return data['id'] as String;
  }

  Future<void> requestJoin(String rideId, {String? riderNote}) async {
    await _client.post('/rides/$rideId/request', data: {
      if (riderNote != null) 'riderNote': riderNote,
    });
  }

  Future<List<Map<String, dynamic>>> getIncomingRequests(String rideId) async {
    final rows = await _client.getList('/rides/$rideId/requests');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> acceptRequest(String rideId, String requestId) async {
    await _client.post('/rides/$rideId/requests/$requestId');
  }

  Future<void> declineRequest(String rideId, String requestId) async {
    await _client.delete('/rides/$rideId/requests/$requestId');
  }

  Future<List<Map<String, dynamic>>> getMyDriverRides() async {
    final rows = await _client.getList('/rides');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<TodayRideSummary?> getTodayRide() async {
    final data = await _client.get('/rides/today');
    final ride = data['ride'];
    if (ride == null) return null;
    return TodayRideSummary.fromJson(ride as Map<String, dynamic>);
  }

  Future<LiveRide> getLiveRide(String rideId) async {
    final data = await _client.get('/rides/$rideId/live');
    return LiveRide.fromJson(data);
  }

  Future<int> headingOut(String rideId) async {
    final data = await _client.post('/rides/$rideId/heading-out');
    return data['notified'] as int? ?? 0;
  }

  Future<void> updateParticipantStatus(String rideId, String userId, String status) async {
    await _client.patch('/rides/$rideId/participants/$userId/status', data: {'status': status});
  }

  Future<void> cancelRide(String rideId) async {
    await _client.delete('/rides/$rideId');
  }

  Future<void> submitReview({
    required String rideId,
    required String targetUserId,
    required int rating,
    String? comment,
  }) async {
    await _client.post('/rides/$rideId/reviews', data: {
      'targetUserId': targetUserId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }

  // ─── Regular Routes ────────────────────────────────────────────────────────

  Future<List<RegularRoute>> listRegularRoutes() async {
    final rows = await _client.getList('/regular-routes');
    return rows
        .cast<Map<String, dynamic>>()
        .map(RegularRoute.fromJson)
        .toList();
  }

  Future<RegularRoute> createRegularRoute({
    required String startAddress,
    required double startLat,
    required double startLng,
    required String endAddress,
    required double endLat,
    required double endLng,
    required List<int> scheduleDays,
    required String departureTime,
    required int defaultSeats,
    String? name,
  }) async {
    final data = await _client.post('/regular-routes', data: {
      if (name != null && name.isNotEmpty) 'name': name,
      'start': {'address': startAddress, 'lat': startLat, 'lng': startLng},
      'end': {'address': endAddress, 'lat': endLat, 'lng': endLng},
      'stops': <dynamic>[],
      'scheduleDays': scheduleDays,
      'departureTime': departureTime,
      'defaultSeats': defaultSeats,
    });
    return RegularRoute.fromJson(data);
  }

  Future<void> deleteRegularRoute(String routeId) async {
    await _client.delete('/regular-routes/$routeId');
  }

  /// Post a one-time ride from a saved regular route for a given departure time.
  Future<String> postRideFromRoute(String routeId, DateTime departureAt) async {
    final data = await _client.post(
      '/regular-routes/$routeId/post-ride',
      data: {'departureAt': departureAt.toUtc().toIso8601String()},
    );
    return data['id'] as String;
  }
}
