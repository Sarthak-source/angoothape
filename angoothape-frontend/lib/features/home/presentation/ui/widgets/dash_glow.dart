import 'package:flutter/material.dart';


class DashGlow extends StatelessWidget {
  const DashGlow({super.key, required this.size, required this.color, required this.alpha});
  final double size;
  final Color color;
  final double alpha;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.7],
      ),
    ),
  );
}
