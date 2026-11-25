import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/http_client.dart';

class SessionApi {
  SessionApi(this._client);
  final HttpClient _client;

  Future<void> restore() => _client.restore();

  bool get signedIn => _client.hasAccessToken;

  Future<void> persistTokens(String token, {String? mfaToken}) {
    return _client.persistToken(token, mfa: mfaToken);
  }

  Future<void> clearTokens() => _client.clearToken();

  Future<Map<String, dynamic>> catalog() => _client.get(ApiEndpoints.catalog);

  Future<Map<String, dynamic>> me() => _client.get(ApiEndpoints.me);

  Future<void> savePreferences({
    required String lang,
    required bool dark,
    required double scale,
  }) async {
    await _client.patch(ApiEndpoints.mePreferences, {
      'lang': lang,
      'dark': dark,
      'scale': scale,
    });
  }

  Future<void> resetDemo() async {
    await _client.post(ApiEndpoints.demoReset);
  }
}
