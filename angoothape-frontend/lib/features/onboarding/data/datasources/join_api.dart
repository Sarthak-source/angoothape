import '../../../../core/api/api_client.dart';

class JoinApi {
  JoinApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> submit({
    required String role,
    required Map<String, String> fields,
    required Map<String, String> docs,
    String? ekycId,
  }) {
    return _client.post('/join', {
      'role': role,
      'fields': fields,
      'docs': docs,
      'ekycId': ekycId,
    });
  }

  Future<Map<String, dynamic>> startEkyc({required String pan}) {
    return _client.post('/join/ekyc', {'pan': pan});
  }

  Future<void> approve(String applicationId) async {
    await _client.post('/join/$applicationId/approve');
  }
}
