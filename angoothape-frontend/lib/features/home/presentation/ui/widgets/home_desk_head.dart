import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';

class HomeDeskHead extends StatelessWidget {
  const HomeDeskHead({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final w = c.data.wallet;
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: cardBox(p, radius: 24),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF403C8C), ApPalette.indigo],
              ),
            ),
            child: Text(
              c.data.retailer.initials,
              style: body(13, weight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.data.retailer.shop,
                style: body(14, weight: FontWeight.w700, color: p.ink),
              ),
              Text(
                '${c.data.retailer.id} · ${c.both('Retailer', 'रिटेलर')}',
                style: body(12.5, color: p.ink2),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _chip(p, c.t('main_wallet'), inr(w.main)),
                  const SizedBox(width: 6),
                  _chip(p, c.t('aeps_bal'), inr(w.aeps)),
                  const SizedBox(width: 14),
                  const DevicePill(compact: true),
                  const SizedBox(width: 14),
                  ApButton(
                    small: true,
                    kind: ApButtonKind.ghost,
                    icon: ApIcons.globe,
                    label: c.lang == 'hi' ? 'English' : 'हिन्दी',
                    onPressed: c.toggleLang,
                  ),
                  const SizedBox(width: 14),
                  ApButton(
                    small: true,
                    kind: ApButtonKind.soft,
                    icon: ApIcons.headset,
                    label: c.t('nav_help'),
                    onPressed: () => c.nav('help'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(ApPalette p, String k, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: p.canvas,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: body(10.5, color: p.ink2, height: 1.2)),
        Text(
          v,
          style: display(14, weight: FontWeight.w700, color: p.ink),
        ),
      ],
    ),
  );
}
