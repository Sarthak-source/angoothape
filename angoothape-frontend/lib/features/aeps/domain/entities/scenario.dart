import '../../../../core/enums.dart';

class Scenario {
  OutcomeKind outcome = OutcomeKind.success;
  String failReason = 'insufficient';
  String pendingResolve = 'success';
  DeviceState device = DeviceState.ready;
  bool captureRetry = false;
}
