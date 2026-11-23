import '../../../session/domain/entities/session_entities.dart';
import '../../domain/ports/aeps_gateway.dart';
import '../datasources/mock_aeps_gateway.dart';

class AepsRepositoryImpl implements AepsGateway {
  AepsRepositoryImpl(this._remote);

  final MockAepsGateway _remote;

  @override
  Future<AepsSubmitResult> submit({
    required OutcomeKind outcome,
    required String failReason,
  }) {
    return _remote.submit(outcome: outcome, failReason: failReason);
  }

  @override
  Future<AepsSubmitResult> checkStatus({
    required bool unknown,
    required int checksAfterThis,
    required String pendingResolve,
  }) {
    return _remote.checkStatus(
      unknown: unknown,
      checksAfterThis: checksAfterThis,
      pendingResolve: pendingResolve,
    );
  }
}
