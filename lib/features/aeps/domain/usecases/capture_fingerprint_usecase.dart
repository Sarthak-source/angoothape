import '../ports/biometric_port.dart';

class CaptureFingerprintUseCase {
  const CaptureFingerprintUseCase(this._port);

  final BiometricPort _port;

  Future<CaptureOutcome> call({
    required bool failFirstAttempt,
    required int attemptsSoFar,
  }) {
    return _port.capture(
      failFirstAttempt: failFirstAttempt,
      attemptsSoFar: attemptsSoFar,
    );
  }
}
