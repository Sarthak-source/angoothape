import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);
  final AuthApi _api;

  @override
  Future<Map<String, dynamic>> login({
    required String partnerId,
    required String password,
  }) {
    return _api.login(partnerId: partnerId, password: password);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String partnerId,
    required String otp,
    required String totp,
    String? challengeId,
  }) {
    return _api.verifyOtp(
      partnerId: partnerId,
      otp: otp,
      totp: totp,
      challengeId: challengeId,
    );
  }

  @override
  Future<Map<String, dynamic>> resendOtp({required String partnerId}) {
    return _api.resendOtp(partnerId: partnerId);
  }

  @override
  Future<void> logout() => _api.logout();

  @override
  Future<Map<String, dynamic>> forgot({required String partnerId}) {
    return _api.forgot(partnerId: partnerId);
  }

  @override
  Future<void> confirmForgot({
    required String partnerId,
    required String otp,
    required String password,
  }) {
    return _api.confirmForgot(
      partnerId: partnerId,
      otp: otp,
      password: password,
    );
  }
}
