import '../../domain/ports/biometric_port.dart';
import '../datasources/mock_biometric_port.dart';

class BiometricRepositoryImpl implements BiometricPort {
  BiometricRepositoryImpl(this._device);

  final MockBiometricPort _device;

  @override
  Future<CaptureOutcome> capture({
    required bool failFirstAttempt,
    required int attemptsSoFar,
  }) {
    return _device.capture(
      failFirstAttempt: failFirstAttempt,
      attemptsSoFar: attemptsSoFar,
    );
  }
}
