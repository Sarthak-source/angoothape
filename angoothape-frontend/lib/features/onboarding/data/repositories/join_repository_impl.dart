import '../../domain/repositories/join_repository.dart';
import '../datasources/join_api.dart';

class JoinRepositoryImpl implements JoinRepository {
  JoinRepositoryImpl(this._api);
  final JoinApi _api;

  @override
  Future<Map<String, dynamic>> submit({
    required String role,
    required Map<String, String> fields,
    required Map<String, String> docs,
    String? ekycId,
  }) {
    return _api.submit(role: role, fields: fields, docs: docs, ekycId: ekycId);
  }

  @override
  Future<Map<String, dynamic>> startEkyc({required String pan}) {
    return _api.startEkyc(pan: pan);
  }

  @override
  Future<void> approve(String applicationId) => _api.approve(applicationId);
}
