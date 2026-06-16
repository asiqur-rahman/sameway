import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap — free tiles, no API key required.
class MapConfig {
  MapConfig._();

  static const String tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// OSM works on mobile, desktop, and web.
  static bool get useNativeMaps => true;

  static const LatLng defaultCenter = LatLng(23.8103, 90.4254);

  /// Demo commute corridor (Uttara → Motijheel).
  static const LatLng defaultHome = LatLng(23.8759, 90.3795);
  static const LatLng defaultOffice = LatLng(23.7330, 90.4172);

  static const double defaultZoom = 13;
  static const double routeZoom = 11.5;
  static const double pickerZoom = 15;

  /// Required by OSM tile usage policy (flutter_map passes this as User-Agent).
  static String get userAgentPackageName {
    if (kIsWeb) return 'com.sameway.sameway.web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'com.sameway.sameway';
      case TargetPlatform.iOS:
        return 'com.sameway.sameway.ios';
      default:
        return 'com.sameway.sameway';
    }
  }
}
