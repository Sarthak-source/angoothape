import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../enums.dart';
import '../theme/ap_icons.dart';
import '../theme/palette.dart';

/// Animated fingerprint scanner pad: breathing outline while waiting for a
/// finger, progress ring and sweeping scan line while capturing, and a colour
/// fade for the result.
class FingerprintPad extends StatefulWidget {
  const FingerprintPad({
    super.key,
    required this.state,
    this.duration = const Duration(milliseconds: 1600),
  });

  final PadState state;

  /// Length of one capture; the ring fills once over this time.
  final Duration duration;

  @override
  State<FingerprintPad> createState() => _FingerprintPadState();
}

class _FingerprintPadState extends State<FingerprintPad>
    with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: widget.duration ~/ 2,
  );
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    _sync(null);
  }

  @override
  void didUpdateWidget(FingerprintPad old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _sync(old.state);
  }

  void _sync(PadState? from) {
    final s = widget.state;
    if (s == PadState.place && !_reduce) {
      if (!_breathe.isAnimating) _breathe.repeat(reverse: true);
    } else {
      _breathe
        ..stop()
        ..value = 0;
    }
    if (s == PadState.capturing) {
      if (from != PadState.capturing) _ring.forward(from: 0);
      if (_reduce) {
        _scan.stop();
      } else if (!_scan.isAnimating) {
        _scan.repeat(reverse: true);
      }
    } else {
      _ring
        ..stop()
        ..value = 0;
      _scan
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _ring.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final printColor = switch (widget.state) {
      PadState.capturing => p.primary,
      PadState.good => p.success,
      PadState.bad => p.error,
      _ => const Color(0xFFA5A1F0),
    };
    final capturing = widget.state == PadState.capturing;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (capturing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ring,
                builder: (_, _) => CustomPaint(
                  painter: _RingPainter(
                    progress: _ring.value,
                    track: p.line,
                    fill: p.primary,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            left: 18,
            top: 18,
            right: 18,
            bottom: 18,
            child: AnimatedBuilder(
              animation: _breathe,
              builder: (_, _) {
                final t = Curves.easeInOut.transform(_breathe.value);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.canvas,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Color.lerp(p.line, p.primary, t)!,
                      width: 2,
                    ),
                    boxShadow: t == 0
                        ? null
                        : [
                            BoxShadow(
                              color: p.primary.withValues(alpha: 0.10 * t),
                              spreadRadius: 8 * t,
                            ),
                          ],
                  ),
                );
              },
            ),
          ),
          if (capturing && !_reduce)
            AnimatedBuilder(
              animation: _scan,
              builder: (_, _) => Positioned(
                left: 30,
                right: 30,
                top: 30 + 86 * Curves.easeInOut.transform(_scan.value),
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: printColor),
            duration: const Duration(milliseconds: 250),
            builder: (_, color, _) =>
                Icon(ApIcons.fingerprint, size: 84, color: color),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 66 / 150;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(rect.center, r, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}
