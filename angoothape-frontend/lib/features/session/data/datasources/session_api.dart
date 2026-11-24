import '../../../../core/api/api_client.dart';

class SessionApi {
  SessionApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> catalog() => _client.get('/catalog');

  Future<Map<String, dynamic>> me() => _client.get('/api/me');

  Future<void> savePreferences({
    required String lang,
    required bool dark,
    required double scale,
  }) async {
    await _client.patch('/api/me/preferences', {
      'lang': lang,
      'dark': dark,
      'scale': scale,
    });
  }

  Future<void> resetDemo() async {
    await _client.post('/api/demo/reset');
  }
}
