import 'package:flutter/foundation.dart';

/// API base URL — override with `--dart-define=API_BASE_URL=...`
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultBaseUrl;
  }

  static const bool enabled = bool.fromEnvironment(
    'API_ENABLED',
    defaultValue: true,
  );

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api/v1';
      default:
        return 'http://localhost:3000/api/v1';
    }
  }
}
