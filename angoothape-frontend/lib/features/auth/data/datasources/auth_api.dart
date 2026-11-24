import '../../../../core/api/api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String partnerId,
    required String password,
  }) {
    return _client.post('/auth/login', {
      'partnerId': partnerId,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String partnerId,
    required String otp,
  }) {
    return _client.post('/auth/otp', {
      'partnerId': partnerId,
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> resendOtp({required String partnerId}) {
    return _client.post('/auth/resend', {'partnerId': partnerId});
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<Map<String, dynamic>> forgot({required String partnerId}) {
    return _client.post('/auth/forgot', {'partnerId': partnerId});
  }

  Future<void> confirmForgot({
    required String partnerId,
    required String otp,
    required String password,
  }) async {
    await _client.post('/auth/forgot/confirm', {
      'partnerId': partnerId,
      'otp': otp,
      'password': password,
    });
  }
}
