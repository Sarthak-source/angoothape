import '../../../../core/enums.dart';
import '../ports/aeps_gateway.dart';

class SubmitAepsUseCase {
  const SubmitAepsUseCase(this._gateway);

  final AepsGateway _gateway;

  Future<AepsSubmitResult> call({
    required OutcomeKind outcome,
    required String failReason,
  }) {
    return _gateway.submit(outcome: outcome, failReason: failReason);
  }
}
