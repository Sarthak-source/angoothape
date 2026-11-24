import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Map<String, dynamic>> call({
    required String partnerId,
    required String otp,
    required String totp,
    String? challengeId,
  }) {
    return _repo.verifyOtp(
      partnerId: partnerId,
      otp: otp,
      totp: totp,
      challengeId: challengeId,
    );
  }
}
