/// Turns API error payloads into clear, user-facing copy (no generic "Validation failed").
abstract final class ApiErrorMessage {
  static const _genericValidation = 'Please check your input and try again.';
  static const _genericRequest = 'Something went wrong. Please try again.';

  static String fromErrorMap(Map<String, dynamic> error) {
    final code = error['code'] as String?;
    final message = error['message'] as String?;
    final details = error['details'];

    final fromDetails = fromDetailsPayload(details);
    if (fromDetails != null) return fromDetails;

    if (message != null &&
        message.isNotEmpty &&
        message != 'Validation failed' &&
        message != 'Request failed') {
      return message;
    }

    return switch (code) {
      'VALIDATION_ERROR' => _genericValidation,
      'UNAUTHORIZED' => 'Invalid email or password',
      'FORBIDDEN' => 'You do not have permission to do that',
      'NOT_FOUND' => 'The requested item was not found',
      'CONFLICT' => message?.isNotEmpty == true ? message! : 'This information is already in use',
      'RATE_LIMITED' => 'Too many attempts. Please wait a moment and try again.',
      'SERVICE_UNAVAILABLE' => 'Service is temporarily unavailable. Please try again.',
      'INTERNAL_ERROR' => 'Something went wrong on our side. Please try again.',
      _ => message?.isNotEmpty == true ? message! : _genericRequest,
    };
  }

  /// Zod flatten shape: `{ formErrors: [], fieldErrors: { field: ["msg"] } }`.
  static String? fromDetailsPayload(dynamic details) {
    if (details is! Map) return null;

    final messages = <String>[];

    final formErrors = details['formErrors'];
    if (formErrors is List) {
      for (final item in formErrors) {
        if (item is String && item.trim().isNotEmpty) {
          messages.add(item.trim());
        }
      }
    }

    final fieldErrors = details['fieldErrors'];
    if (fieldErrors is Map) {
      for (final entry in fieldErrors.entries) {
        final issues = entry.value;
        if (issues is List) {
          for (final issue in issues) {
            if (issue is String && issue.trim().isNotEmpty) {
              messages.add(issue.trim());
            }
          }
        } else if (issues is String && issues.trim().isNotEmpty) {
          messages.add(issues.trim());
        }
      }
    }

    if (messages.isEmpty) return null;
    return messages.join('\n');
  }
}
