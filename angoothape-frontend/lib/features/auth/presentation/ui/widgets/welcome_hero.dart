import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key, required this.c, required this.tall});
  final AppController c;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1B1944),
      child: Stack(
        fit: tall ? StackFit.expand : StackFit.loose,
        children: [
          const Positioned(
            right: -160,
            top: -160,
            width: 420,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x73F2662F), Color(0x00F2662F)],
                  stops: [0, 0.65],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -30,
            width: 150,
            height: 150,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xF2F2662F),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 80,
            top: 30,
            width: 18,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF4FB477),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: tall
                ? const EdgeInsets.all(56)
                : const EdgeInsets.fromLTRB(24, 36, 24, 30),
            child: Column(
              mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Wordmark(height: 42, onDark: true),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    c.t('welcome_t'),
                    style: display(
                      tall ? 34 : 26,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Text(
                    c.t('welcome_p'),
                    style: body(
                      15,
                      color: const Color(0xFFC6C4EC),
                      height: 1.5,
                    ),
                  ),
                ),
                if (tall) ...[
                  const SizedBox(height: 24),
                  _feat(ApIcons.fingerprint, c.t('f1')),
                  const SizedBox(height: 12),
                  _feat(ApIcons.doc, c.t('f2')),
                  const SizedBox(height: 12),
                  _feat(ApIcons.headset, c.t('f3')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feat(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFBA078), size: 22),
      const SizedBox(width: 12),
      Expanded(
        child: Text(text, style: body(14, color: const Color(0xFFE2E1F5))),
      ),
    ],
  );
}
