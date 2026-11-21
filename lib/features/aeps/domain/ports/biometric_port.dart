class CaptureOutcome {
  const CaptureOutcome({required this.ok, required this.quality});

  final bool ok;
  final int quality;
}

/// L1 RD scanner. This app never uses the phone's own fingerprint sensor.
abstract class BiometricPort {
  Future<CaptureOutcome> capture({
    required bool failFirstAttempt,
    required int attemptsSoFar,
  });
}
