import '../../../session/domain/entities/session_entities.dart';

class AepsSubmitResult {
  const AepsSubmitResult({
    required this.status,
    this.reason,
    this.balance,
    this.unknown = false,
  });

  final TxStatus status;
  final String? reason;
  final double? balance;
  final bool unknown;
}

/// Sponsor-bank AEPS contract. The mock stands in until a partner API exists.
abstract class AepsGateway {
  Future<AepsSubmitResult> submit({
    required OutcomeKind outcome,
    required String failReason,
  });

  /// Pending needs two checks. A network-unknown resolves on the first.
  Future<AepsSubmitResult> checkStatus({
    required bool unknown,
    required int checksAfterThis,
    required String pendingResolve,
  });
}
