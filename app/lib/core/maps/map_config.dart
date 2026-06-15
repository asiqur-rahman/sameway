import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
/// Google Maps configuration.
///
/// Mobile Maps SDK (Android/iOS) is free — no per-load charge.
/// Create a key at https://console.cloud.google.com/ (enable Maps SDK for Android + iOS).
class MapConfig {
  MapConfig._();

  /// Pass via `--dart-define=GOOGLE_MAPS_API_KEY=...` and `android/local.properties`.
  static const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Native GoogleMap works on Android/iOS (not web without extra setup).
  static bool get useNativeMaps => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Default map center — Dhaka.
  static const LatLng defaultCenter = LatLng(23.8103, 90.4254);

  /// Demo commute corridor (Uttara → Motijheel).
  static const LatLng defaultHome = LatLng(23.8759, 90.3795);
  static const LatLng defaultOffice = LatLng(23.7330, 90.4172);

  static const double defaultZoom = 13;
  static const double routeZoom = 11.5;
}
