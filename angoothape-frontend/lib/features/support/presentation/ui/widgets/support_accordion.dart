import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/theme/ap_icons.dart';

class SupportAccordion extends StatefulWidget {
  const SupportAccordion({super.key, required this.items});
  final List<(String, List<String>)> items;
  @override
  State<SupportAccordion> createState() => SupportAccordionState();
}

class SupportAccordionState extends State<SupportAccordion> {
  int? open;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
            InkWell(
              onTap: () => setState(() => open = open == i ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      Icon(ApIcons.help, size: 20, color: p.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.items[i].$1,
                          style: body(
                            14,
                            weight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: open == i ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(ApIcons.chevD, size: 20, color: p.ink2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (open == i)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var n = 0; n < widget.items[i].$2.length; n++)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 6),
                        child: Text(
                          '${n + 1}.  ${widget.items[i].$2[n]}',
                          style: body(14, color: p.ink2, height: 1.55),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
