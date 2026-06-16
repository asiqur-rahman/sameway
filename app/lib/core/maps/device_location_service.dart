import 'package:geolocator/geolocator.dart';
import 'package:sameway/core/api/repositories/places_repository.dart';
import 'package:sameway/core/models/search_location.dart';

/// Reads the device GPS position and resolves a human-readable address.
class DeviceLocationService {
  DeviceLocationService._();

  static Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<SearchLocation?> getCurrentSearchLocation() async {
    if (!await _ensurePermission()) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      try {
        return await PlacesRepository.instance.reverseGeocode(
          lat: pos.latitude,
          lng: pos.longitude,
        );
      } catch (_) {
        return SearchLocation(
          address: 'Current location',
          lat: pos.latitude,
          lng: pos.longitude,
        );
      }
    } catch (_) {
      return null;
    }
  }
}
