import '../../../../core/api/api_client.dart';

class SupportApi {
  SupportApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> createTicket({
    required String type,
    required String message,
    String? ref,
  }) {
    return _client.post('/api/tickets', {
      'type': type,
      'message': message,
      'ref': ref,
    });
  }

  Future<Map<String, dynamic>> device() {
    return _client.get('/api/device');
  }

  Future<void> patchDevice({required String state}) async {
    await _client.patch('/api/device', {'state': state});
  }

  Future<void> testDevice() async {
    await _client.post('/api/device/test');
  }

  Future<void> deviceRequest({required String kind}) async {
    await _client.post('/api/device/requests', {'kind': kind});
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String shop,
    required String city,
    required String mobile,
  }) {
    return _client.patch('/api/me', {
      'name': name,
      'shop': shop,
      'city': city,
      'mobile': mobile,
    });
  }

  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    await _client.post('/api/me/password', {
      'current': current,
      'next': next,
    });
  }
}
