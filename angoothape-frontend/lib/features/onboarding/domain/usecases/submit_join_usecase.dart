import '../repositories/join_repository.dart';

class SubmitJoinUseCase {
  const SubmitJoinUseCase(this._repo);
  final JoinRepository _repo;

  Future<Map<String, dynamic>> call({
    required String role,
    required Map<String, String> fields,
    required Map<String, String> docs,
    String? ekycId,
  }) {
    return _repo.submit(
      role: role,
      fields: fields,
      docs: docs,
      ekycId: ekycId,
    );
  }
}
