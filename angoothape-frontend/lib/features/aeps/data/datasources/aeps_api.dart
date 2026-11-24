import '../../../../core/api/api_client.dart';

class AepsApi {
  AepsApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> submit(Map<String, dynamic> body) {
    return _client.post('/api/aeps', body);
  }
}
