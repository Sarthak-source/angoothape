import '../repositories/join_repository.dart';

class StartEkycUseCase {
  const StartEkycUseCase(this._repo);
  final JoinRepository _repo;

  Future<Map<String, dynamic>> call({required String pan}) {
    return _repo.startEkyc(pan: pan);
  }
}
