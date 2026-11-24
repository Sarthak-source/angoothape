import '../repositories/home_repository.dart';

class LoadTransactionsUseCase {
  const LoadTransactionsUseCase(this._repo);
  final HomeRepository _repo;

  Future<Map<String, dynamic>> call({
    required String q,
    required String status,
    required String svc,
    required String range,
  }) {
    return _repo.transactions(q: q, status: status, svc: svc, range: range);
  }
}
