import 'package:flutter/foundation.dart';
import 'package:sameway/core/api/api_config.dart';
import 'package:sameway/core/api/repositories/users_repository.dart';

/// Registers device tokens with the backend for push delivery.
///
/// For dev/testing without Firebase project files, pass:
/// `--dart-define=FCM_DEV_TOKEN=your-test-token`
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  static const String _devToken = String.fromEnvironment('FCM_DEV_TOKEN');

  Future<void> initialize() async {
    if (!ApiConfig.enabled) return;
    await registerToken();
  }

  Future<void> registerToken() async {
    if (!ApiConfig.enabled) return;

    final token = _devToken.isNotEmpty ? _devToken : await _fetchNativeToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint('[PushService] no token — set FCM_DEV_TOKEN or configure Firebase');
      }
      return;
    }

    try {
      await UsersRepository.instance.registerDeviceToken(
        token: token,
        platform: _platformLabel(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[PushService] register failed: $e');
    }
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'web';
    }
  }

  Future<String?> _fetchNativeToken() async {
    // Real FCM: add firebase_core + firebase_messaging and google-services files,
    // then return FirebaseMessaging.instance.getToken().
    return null;
  }
}
