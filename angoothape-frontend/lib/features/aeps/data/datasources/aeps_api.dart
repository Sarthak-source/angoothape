import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/http_client.dart';

class AepsApi {
  AepsApi(this._client);
  final HttpClient _client;

  Future<Map<String, dynamic>> submit(Map<String, dynamic> body) {
    return _client.post(ApiEndpoints.aeps, body);
  }
}
