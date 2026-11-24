abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String partnerId,
    required String password,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String partnerId,
    required String otp,
    String? challengeId,
  });

  Future<Map<String, dynamic>> verifyTotp({
    required String partnerId,
    required String totp,
    String? challengeId,
  });

  Future<Map<String, dynamic>> resendOtp({required String partnerId});

  Future<void> logout();

  Future<Map<String, dynamic>> forgot({required String partnerId});

  Future<void> confirmForgot({
    required String partnerId,
    required String otp,
    required String password,
  });
}
