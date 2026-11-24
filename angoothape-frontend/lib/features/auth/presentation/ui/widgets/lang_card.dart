
import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';

class LangCard extends StatelessWidget {
  const LangCard({super.key, 
    required this.title,
    required this.sub,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });
  final String title;
  final String sub;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? p.primarySoft : p.card,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? p.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: display(17, color: p.ink)),
                Text(sub, style: body(12, color: p.ink2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
