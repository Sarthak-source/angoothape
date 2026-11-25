import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/http_client.dart';

class JoinApi {
  JoinApi(this._client);
  final HttpClient _client;

  Future<Map<String, dynamic>> submit({
    required String role,
    required Map<String, String> fields,
    required Map<String, String> docs,
    String? ekycId,
  }) {
    return _client.post(ApiEndpoints.join, {
      'role': role,
      'fields': fields,
      'docs': docs,
      'ekycId': ekycId,
    });
  }

  Future<Map<String, dynamic>> startEkyc({required String pan}) {
    return _client.post(ApiEndpoints.joinEkyc, {'pan': pan});
  }

  Future<void> approve(String applicationId) async {
    await _client.post(ApiEndpoints.joinApprove(applicationId));
  }
}
