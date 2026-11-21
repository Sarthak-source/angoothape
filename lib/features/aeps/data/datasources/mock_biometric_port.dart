import '../../domain/ports/biometric_port.dart';

class MockBiometricPort implements BiometricPort {
  @override
  Future<CaptureOutcome> capture({
    required bool failFirstAttempt,
    required int attemptsSoFar,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1600));
    final fail = failFirstAttempt && attemptsSoFar == 0;
    return CaptureOutcome(ok: !fail, quality: fail ? 31 : 78);
  }
}
