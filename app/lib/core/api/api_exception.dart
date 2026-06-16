import 'package:sameway/core/api/api_error_message.dart';

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  /// User-facing text — never a bare "Validation failed" when field errors exist.
  String get displayMessage => ApiErrorMessage.compose(
        message: message,
        code: code,
        details: details,
      );

  factory ApiException.fromErrorMap(
    Map<String, dynamic> error, {
    int? statusCode,
  }) {
    return ApiException(
      error['message'] as String? ?? 'Request failed',
      code: error['code'] as String?,
      statusCode: statusCode,
      details: error['details'],
    );
  }

  @override
  String toString() => displayMessage;
}
