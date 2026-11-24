import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/widgets/fingerprint_pad.dart';

class AepsFingerHint extends StatelessWidget {
  const AepsFingerHint({super.key, required this.phase});
  final CapturePhase phase;
  @override
  Widget build(BuildContext context) => FingerprintPad(
    state: switch (phase) {
      CapturePhase.failed || CapturePhase.locked => PadState.bad,
      CapturePhase.ok => PadState.good,
      CapturePhase.capturing => PadState.capturing,
      _ => PadState.place,
    },
  );
}
