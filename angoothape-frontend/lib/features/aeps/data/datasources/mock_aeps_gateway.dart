import 'dart:math';

import '../../../session/domain/entities/session_entities.dart';
import '../../domain/ports/aeps_gateway.dart';

class MockAepsGateway implements AepsGateway {
  @override
  Future<AepsSubmitResult> submit({
    required OutcomeKind outcome,
    required String failReason,
  }) async {
    final slow = outcome == OutcomeKind.network;
    await Future.delayed(Duration(milliseconds: slow ? 3600 : 2600));
    switch (outcome) {
      case OutcomeKind.network:
        return const AepsSubmitResult(status: TxStatus.pending, unknown: true);
      case OutcomeKind.pending:
        return const AepsSubmitResult(status: TxStatus.pending);
      case OutcomeKind.failed:
        return AepsSubmitResult(status: TxStatus.failed, reason: failReason);
      case OutcomeKind.success:
        final bal =
            ((2500 + Random().nextDouble() * 24000) * 100).round() / 100;
        return AepsSubmitResult(status: TxStatus.success, balance: bal);
    }
  }

  @override
  Future<AepsSubmitResult> checkStatus({
    required bool unknown,
    required int checksAfterThis,
    required String pendingResolve,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    final stillPending = !unknown && checksAfterThis < 2;
    if (stillPending) return const AepsSubmitResult(status: TxStatus.pending);
    if (pendingResolve == 'failed') {
      return const AepsSubmitResult(status: TxStatus.failed, reason: 'timeout');
    }
    final bal = ((2500 + Random().nextDouble() * 24000) * 100).round() / 100;
    return AepsSubmitResult(status: TxStatus.success, balance: bal);
  }
}
