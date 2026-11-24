import '../repositories/auth_repository.dart';

class VerifyTotpUseCase {
  const VerifyTotpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Map<String, dynamic>> call({
    required String partnerId,
    required String totp,
    String? challengeId,
  }) {
    return _repo.verifyTotp(
      partnerId: partnerId,
      totp: totp,
      challengeId: challengeId,
    );
  }
}
