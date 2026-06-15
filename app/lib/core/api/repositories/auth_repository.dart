import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/api/token_storage.dart';
import 'package:sameway/core/api/user_mapper.dart';
import 'package:sameway/core/session/user_profile.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();
  final _client = ApiClient.instance;

  Future<UserProfile> signup({
    required String fullName,
    required String workEmail,
    required String phone,
    required String password,
  }) async {
    final data = await _client.post('/auth/signup', data: {
      'fullName': fullName,
      'workEmail': workEmail.trim().toLowerCase(),
      'phone': phone,
      'password': password,
    });
    await _saveTokens(data);
    return UserMapper.fromApi(data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> signin({
    required String workEmail,
    required String password,
  }) async {
    final data = await _client.post('/auth/signin', data: {
      'workEmail': workEmail.trim().toLowerCase(),
      'password': password,
    });
    await _saveTokens(data);
    return UserMapper.fromApi(data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile?> fetchMe() async {
    final token = await TokenStorage.instance.accessToken;
    if (token == null || token.isEmpty) return null;
    final data = await _client.get('/auth/me');
    return UserMapper.fromApi(data);
  }

  Future<void> signOut() async {
    final refresh = await TokenStorage.instance.refreshToken;
    if (refresh != null) {
      try {
        await _client.delete('/auth/refresh', data: {'refreshToken': refresh});
      } catch (_) {}
    }
    await TokenStorage.instance.clear();
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final tokens = data['tokens'] as Map<String, dynamic>;
    await TokenStorage.instance.saveTokens(
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
  }
}
