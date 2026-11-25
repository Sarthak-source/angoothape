import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/http_client.dart';

class AuthApi {
  AuthApi(this._client);
  final HttpClient _client;

  Future<Map<String, dynamic>> login({
    required String partnerId,
    required String password,
  }) {
    return _client.post(ApiEndpoints.login, {
      'partnerId': partnerId,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String partnerId,
    required String otp,
    String? challengeId,
  }) {
    return _client.post(ApiEndpoints.otp, {
      'partnerId': partnerId,
      'otp': otp,
      if (challengeId != null && challengeId.isNotEmpty)
        'challengeId': challengeId,
    });
  }

  Future<Map<String, dynamic>> verifyTotp({
    required String partnerId,
    required String totp,
    String? challengeId,
  }) {
    return _client.post(ApiEndpoints.totp, {
      'partnerId': partnerId,
      'totp': totp,
      if (challengeId != null && challengeId.isNotEmpty)
        'challengeId': challengeId,
    });
  }

  Future<Map<String, dynamic>> resendOtp({required String partnerId}) {
    return _client.post(ApiEndpoints.resendOtp, {'partnerId': partnerId});
  }

  Future<void> logout() async {
    await _client.post(ApiEndpoints.logout);
  }

  Future<Map<String, dynamic>> forgot({required String partnerId}) {
    return _client.post(ApiEndpoints.forgot, {'partnerId': partnerId});
  }

  Future<void> confirmForgot({
    required String partnerId,
    required String otp,
    required String password,
  }) async {
    await _client.post(ApiEndpoints.forgotConfirm, {
      'partnerId': partnerId,
      'otp': otp,
      'password': password,
    });
  }
}
