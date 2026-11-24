import '../repositories/support_repository.dart';

class CreateTicketUseCase {
  const CreateTicketUseCase(this._repo);
  final SupportRepository _repo;

  Future<Map<String, dynamic>> call({
    required String type,
    required String message,
    String? ref,
  }) {
    return _repo.createTicket(type: type, message: message, ref: ref);
  }
}
