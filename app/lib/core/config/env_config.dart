import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// App configuration from `dart_defines.json` (bundled asset).
///
/// Edit `app/dart_defines.json`, then stop and run `flutter run` again.
/// Optional: `--dart-define=KEY=value` overrides a single value for CI builds.
abstract final class EnvConfig {
  static String _apiBaseUrl = '';
  static String _mapTileUrl = '';
  static String _fcmDevToken = '';
  static bool _apiEnabled = true;
  static String _defaultMapCenter = '';
  static String _defaultHome = '';
  static String _defaultOffice = '';

  static String get apiBaseUrl => _apiBaseUrl;
  static String get mapTileUrl => _mapTileUrl;
  static String get fcmDevToken => _fcmDevToken;
  static bool get apiEnabled => _apiEnabled;

  /// Loads `dart_defines.json` on every cold start. No extra CLI flags required.
  static Future<void> load() async {
    await _loadFromAsset();
    _applyCompileTimeOverrides();

    if (kDebugMode) {
      debugPrint('[SameWay] API_BASE_URL=$_apiBaseUrl');
    }
  }

  static Future<void> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString('dart_defines.json');
      _applyMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[EnvConfig] Failed to load dart_defines.json: $e');
    }
  }

  static void _applyMap(Map<String, dynamic> map) {
    _apiBaseUrl = map['API_BASE_URL'] as String? ?? '';
    _mapTileUrl = map['MAP_TILE_URL'] as String? ?? '';
    _fcmDevToken = map['FCM_DEV_TOKEN'] as String? ?? '';
    if (map.containsKey('API_ENABLED')) {
      final v = map['API_ENABLED'];
      _apiEnabled = v == true || v == 'true';
    }
    _defaultMapCenter = map['DEFAULT_MAP_CENTER'] as String? ?? '';
    _defaultHome = map['DEFAULT_HOME'] as String? ?? '';
    _defaultOffice = map['DEFAULT_OFFICE'] as String? ?? '';
  }

  /// CI / release builds only — in debug, `dart_defines.json` always wins.
  static void _applyCompileTimeOverrides() {
    if (kDebugMode) return;
    const api = String.fromEnvironment('API_BASE_URL');
    if (api.isNotEmpty) _apiBaseUrl = api;

    const tiles = String.fromEnvironment('MAP_TILE_URL');
    if (tiles.isNotEmpty) _mapTileUrl = tiles;

    const fcm = String.fromEnvironment('FCM_DEV_TOKEN');
    if (fcm.isNotEmpty) _fcmDevToken = fcm;

    const center = String.fromEnvironment('DEFAULT_MAP_CENTER');
    if (center.isNotEmpty) _defaultMapCenter = center;

    const home = String.fromEnvironment('DEFAULT_HOME');
    if (home.isNotEmpty) _defaultHome = home;

    const office = String.fromEnvironment('DEFAULT_OFFICE');
    if (office.isNotEmpty) _defaultOffice = office;

    const enabled = String.fromEnvironment('API_ENABLED');
    if (enabled.isNotEmpty) {
      _apiEnabled = enabled == 'true';
    }
  }

  static void ensureConfigured() {
    final missing = <String>[];
    if (_apiBaseUrl.isEmpty) missing.add('API_BASE_URL');
    if (_mapTileUrl.isEmpty) missing.add('MAP_TILE_URL');
    if (_defaultMapCenter.isEmpty) missing.add('DEFAULT_MAP_CENTER');
    if (_defaultHome.isEmpty) missing.add('DEFAULT_HOME');
    if (_defaultOffice.isEmpty) missing.add('DEFAULT_OFFICE');

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing config in dart_defines.json: ${missing.join(', ')}.\n'
        'Edit app/dart_defines.json, then stop the app and run `flutter run` again.',
      );
    }

    if (kDebugMode &&
        !kIsWeb &&
        (_apiBaseUrl.contains('localhost') || _apiBaseUrl.contains('127.0.0.1'))) {
      debugPrint(
        '[EnvConfig] WARNING: API_BASE_URL=$_apiBaseUrl — on a physical phone '
        'use your PC Wi‑Fi IP. Update dart_defines.json and restart the app.',
      );
    }
  }

  static LatLng get defaultMapCenter => _parseLatLng(_defaultMapCenter, 'DEFAULT_MAP_CENTER');

  static LatLng get defaultHome => _parseLatLng(_defaultHome, 'DEFAULT_HOME');

  static LatLng get defaultOffice => _parseLatLng(_defaultOffice, 'DEFAULT_OFFICE');

  static LatLng _parseLatLng(String raw, String name) {
    final parts = raw.split(',');
    if (parts.length != 2) {
      throw StateError('$name must be "lat,lng" (got "$raw")');
    }
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      throw StateError('$name must be "lat,lng" with valid numbers (got "$raw")');
    }
    return LatLng(lat, lng);
  }
}
