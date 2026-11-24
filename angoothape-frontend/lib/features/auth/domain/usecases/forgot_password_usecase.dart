import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repo);
  final AuthRepository _repo;

  Future<Map<String, dynamic>> request({required String partnerId}) {
    return _repo.forgot(partnerId: partnerId);
  }

  Future<void> confirm({
    required String partnerId,
    required String otp,
    required String password,
  }) {
    return _repo.confirmForgot(
      partnerId: partnerId,
      otp: otp,
      password: password,
    );
  }
}
