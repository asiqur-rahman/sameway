import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';

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
}
