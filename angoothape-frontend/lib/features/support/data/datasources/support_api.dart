import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/http_client.dart';

class SupportApi {
  SupportApi(this._client);
  final HttpClient _client;

  Future<Map<String, dynamic>> createTicket({
    required String type,
    required String message,
    String? ref,
  }) {
    return _client.post(ApiEndpoints.tickets, {
      'type': type,
      'message': message,
      'ref': ref,
    });
  }

  Future<Map<String, dynamic>> device() {
    return _client.get(ApiEndpoints.device);
  }

  Future<void> patchDevice({required String state}) async {
    await _client.patch(ApiEndpoints.device, {'state': state});
  }

  Future<void> testDevice() async {
    await _client.post(ApiEndpoints.deviceTest);
  }

  Future<void> deviceRequest({required String kind}) async {
    await _client.post(ApiEndpoints.deviceRequests, {'kind': kind});
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String shop,
    required String city,
    required String mobile,
  }) {
    return _client.patch(ApiEndpoints.me, {
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
    await _client.post(ApiEndpoints.mePassword, {
      'current': current,
      'next': next,
    });
  }
}
