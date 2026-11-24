import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Map<String, dynamic>> call({
    required String partnerId,
    required String password,
  }) {
    return _repo.login(partnerId: partnerId, password: password);
  }
}
