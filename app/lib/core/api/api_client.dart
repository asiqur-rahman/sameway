import 'package:dio/dio.dart';
import 'package:sameway/core/config/env_config.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/api/token_storage.dart';

typedef TokenRefreshCallback = Future<void> Function();

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  bool _initialized = false;
  TokenRefreshCallback? _onRefreshFailed;

  void initialize({TokenRefreshCallback? onRefreshFailed}) {
    if (_initialized) return;
    _onRefreshFailed = onRefreshFailed;
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.extra.containsKey('retried')) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              final opts = error.requestOptions;
              opts.extra['retried'] = true;
              final token = await TokenStorage.instance.accessToken;
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );
    _initialized = true;
  }

  Future<bool> _tryRefresh() async {
    final refresh = await TokenStorage.instance.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      await _onRefreshFailed?.call();
      return false;
    }
    try {
      final response = await Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = _unwrap(response.data);
      final tokens = data['tokens'] as Map<String, dynamic>;
      await TokenStorage.instance.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      await TokenStorage.instance.clear();
      await _onRefreshFailed?.call();
      return false;
    }
  }

  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw ApiException('Invalid response format');
    }
    if (body['success'] == true) {
      return body['data'] as Map<String, dynamic>;
    }
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      throw ApiException(
        error['message'] as String? ?? 'Request failed',
        code: error['code'] as String?,
      );
    }
    throw ApiException('Request failed');
  }

  List<dynamic> _unwrapList(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw ApiException('Invalid response format');
    }
    if (body['success'] == true) {
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return data['items'] as List<dynamic>;
      }
      return [];
    }
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      throw ApiException(
        error['message'] as String? ?? 'Request failed',
        code: error['code'] as String?,
      );
    }
    throw ApiException('Request failed');
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return _unwrapList(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<void> delete(String path, {Object? data}) async {
    try {
      await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  /// Multipart file upload — returns unwrapped `{ url: "..." }`.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?fields,
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _unwrap(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  ApiException _fromDio(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final err = body['error'] as Map<String, dynamic>;
      return ApiException(
        err['message'] as String? ?? e.message ?? 'Network error',
        code: err['code'] as String?,
        statusCode: e.response?.statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        'Could not reach the server at ${EnvConfig.apiBaseUrl}. '
        'Check Wi‑Fi, confirm the backend is running, and firewall rules for your API port.',
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(
      e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }
}
