import 'package:flutter/material.dart';

import '../theme/ap_icons.dart';
import '../theme/palette.dart';
import 'app_widgets.dart';

class SheetHead extends StatelessWidget {
  const SheetHead(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: display(18, color: p.ink)),
          ),
          Material(
            color: p.card,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: AppScope.of(context).closeSheet,
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.card,
                  boxShadow: cardShadow(),
                ),
                child: Icon(ApIcons.close, color: p.ink, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetFoot extends StatelessWidget {
  const SheetFoot({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Row(children: children),
    );
  }
}
