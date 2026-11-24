import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

class SlideToScan extends StatefulWidget {
  const SlideToScan({
    super.key,
    required this.label,
    required this.onConfirmed,
  });
  final String label;
  final VoidCallback onConfirmed;
  @override
  State<SlideToScan> createState() => _SlideToScanState();
}

class _SlideToScanState extends State<SlideToScan> {
  double dx = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final max = (box.maxWidth - 68).clamp(1, 1000).toDouble();
            return GestureDetector(
              onHorizontalDragUpdate: (d) =>
                  setState(() => dx = (dx + d.delta.dx).clamp(0, max)),
              onHorizontalDragEnd: (_) {
                if (dx >= max * 0.85) {
                  setState(() => dx = max);
                  widget.onConfirmed();
                } else {
                  if (dx < 12) c.toast(c.t('slide_hint'));
                  setState(() => dx = 0);
                }
              },
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2662F),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2662F).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ((dx + 56) / box.maxWidth).clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ApPalette.orange700,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6 + dx,
                      top: 6,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          ApIcons.fingerprint,
                          color: ApPalette.orange700,
                          size: 30,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          widget.label,
                          style: display(
                            16,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(c.t('slide_help'), style: body(12.5, color: ap(context).ink2)),
      ],
    );
  }
}
