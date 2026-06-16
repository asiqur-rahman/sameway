import 'package:sameway/core/api/repositories/places_repository.dart';
import 'package:sameway/core/maps/map_config.dart';
import 'package:sameway/core/models/search_location.dart';
import 'package:sameway/core/session/app_session.dart';

/// Resolves search endpoints to lat/lng using saved places, flow state, or geocoding.
/// Session cache avoids repeat geocode calls during rush-hour search bursts.
class SearchLocationResolver {
  SearchLocationResolver._();

  static final Map<String, SearchLocation> _geocodeCache = {};
  static const _maxGeocodeCacheEntries = 64;

  static void _rememberGeocode(String key, SearchLocation location) {
    if (_geocodeCache.length >= _maxGeocodeCacheEntries) {
      _geocodeCache.remove(_geocodeCache.keys.first);
    }
    _geocodeCache[key] = location;
  }

  static String _cacheKey(String address) => address.trim().toLowerCase();

  static bool hasValidCoords(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat == 0 && lng == 0) return false;
    return lat.abs() <= 90 && lng.abs() <= 180;
  }

  static SearchLocation? savedHome() {
    final user = AppSession.instance.currentUser;
    if (user?.homeAddress?.trim().isEmpty ?? true) return null;
    if (!hasValidCoords(user?.homeLat, user?.homeLng)) return null;
    return SearchLocation(
      address: user!.homeAddress!,
      lat: user.homeLat!,
      lng: user.homeLng!,
    );
  }

  static SearchLocation? savedOffice() {
    final user = AppSession.instance.currentUser;
    if (user?.officeAddress?.trim().isEmpty ?? true) return null;
    if (!hasValidCoords(user?.officeLat, user?.officeLng)) return null;
    return SearchLocation(
      address: user!.officeAddress!,
      lat: user.officeLat!,
      lng: user.officeLng!,
    );
  }

  static bool addressesMatch(String a, String b) {
    final na = a.trim().toLowerCase();
    final nb = b.trim().toLowerCase();
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    return na.contains(nb) || nb.contains(na);
  }

  /// Match typed address to saved home/office coordinates.
  static SearchLocation? matchSavedPlace(String address) {
    final home = savedHome();
    if (home != null && addressesMatch(address, home.address)) return home;
    final office = savedOffice();
    if (office != null && addressesMatch(address, office.address)) return office;
    return null;
  }

  /// Geocode custom address via API, with session cache (one call per unique address).
  static Future<SearchLocation> geocodeOrFallback(String address) async {
    final saved = matchSavedPlace(address);
    if (saved != null) return saved;

    final key = _cacheKey(address);
    final cached = _geocodeCache[key];
    if (cached != null) return cached;

    try {
      final resolved = await PlacesRepository.instance.geocodeAddress(address);
      _rememberGeocode(key, resolved);
      return resolved;
    } catch (_) {
      final fallback = SearchLocation(
        address: address,
        lat: MapConfig.defaultHome.latitude,
        lng: MapConfig.defaultHome.longitude,
      );
      return fallback;
    }
  }

  static Future<SearchLocation> resolveEndpoint({
    required String address,
    double? lat,
    double? lng,
  }) async {
    if (hasValidCoords(lat, lng)) {
      return SearchLocation(address: address, lat: lat!, lng: lng!);
    }
    final saved = matchSavedPlace(address);
    if (saved != null) return saved;
    return geocodeOrFallback(address);
  }

  /// Clear session geocode cache on sign-out (optional hygiene).
  static void clearSessionCache() {
    _geocodeCache.clear();
  }
}
