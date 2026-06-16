import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sameway/core/config/env_config.dart';

/// Map display settings — tile URL and region come from [EnvConfig] / `dart_defines.json`.
abstract final class MapConfig {
  static String get tileUrl => EnvConfig.mapTileUrl;

  static bool get useNativeMaps => true;

  static LatLng get defaultCenter => EnvConfig.defaultMapCenter;

  static LatLng get defaultHome => EnvConfig.defaultHome;

  static LatLng get defaultOffice => EnvConfig.defaultOffice;

  static const double defaultZoom = 13;
  static const double routeZoom = 11.5;
  static const double pickerZoom = 15;

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
