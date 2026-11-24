import '../repositories/session_repository.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase(this._repo);
  final SessionRepository _repo;

  Future<Map<String, dynamic>> call() => _repo.me();
}
