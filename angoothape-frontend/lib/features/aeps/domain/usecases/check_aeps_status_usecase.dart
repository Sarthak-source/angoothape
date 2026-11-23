import '../ports/aeps_gateway.dart';

class CheckAepsStatusUseCase {
  const CheckAepsStatusUseCase(this._gateway);

  final AepsGateway _gateway;

  Future<AepsSubmitResult> call({
    required bool unknown,
    required int checksAfterThis,
    required String pendingResolve,
  }) {
    return _gateway.checkStatus(
      unknown: unknown,
      checksAfterThis: checksAfterThis,
      pendingResolve: pendingResolve,
    );
  }
}
