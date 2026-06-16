import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/models/search_location.dart';

class PlacesRepository {
  PlacesRepository._();

  static final PlacesRepository instance = PlacesRepository._();
  final _client = ApiClient.instance;

  Future<SearchLocation> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final data = await _client.get(
      '/places/reverse',
      query: {'lat': lat, 'lng': lng},
    );
    return SearchLocation(
      address: data['address'] as String? ?? 'Pinned location',
      lat: (data['lat'] as num?)?.toDouble() ?? lat,
      lng: (data['lng'] as num?)?.toDouble() ?? lng,
    );
  }

  Future<SearchLocation> geocodeAddress(String query) async {
    final data = await _client.get(
      '/places/geocode',
      query: {'q': query.trim()},
    );
    return SearchLocation(
      address: data['address'] as String? ?? query.trim(),
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
    );
  }
}
