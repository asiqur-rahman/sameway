import 'package:sameway/core/api/api_client.dart';

class UploadsRepository {
  UploadsRepository._();

  static final UploadsRepository instance = UploadsRepository._();
  final _client = ApiClient.instance;

  /// Upload image; [type] is `profiles` or `verification`.
  Future<String> uploadImage(String filePath, {String type = 'profiles'}) async {
    final result = await _client.postMultipart(
      '/uploads',
      filePath: filePath,
      fieldName: 'file',
      fields: {'type': type},
    );
    return result['url'] as String;
  }
}
