import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class DashSoon extends StatelessWidget {
  const DashSoon({super.key, required this.c, required this.p});
  final AppController c;
  final ApPalette p;
  @override
  Widget build(BuildContext context) {
    final items = futureServices(c.lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              c.t('other_svcs'),
              style: display(18, weight: FontWeight.w700, color: p.ink),
            ),
            const SizedBox(width: 10),
            const SoonTag(),
            const Spacer(),
            ApButton(
              small: true,
              kind: ApButtonKind.ghost,
              label: c.t('nav_services'),
              trailingIcon: ApIcons.chevR,
              onPressed: () => c.nav('services'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => Container(
              width: 118,
              padding: const EdgeInsets.all(14),
              decoration: cardBox(p, radius: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _soonIcons[items[i].$1] ?? ApIcons.grid,
                      color: p.ink2,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items[i].$2,
                    style: body(12.5, weight: FontWeight.w600, color: p.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _soonIcons = <String, IconData>{
  'atm': ApIcons.atm,
  'send': ApIcons.sendMoney,
  'bill': ApIcons.bill,
  'recharge': ApIcons.mobileTx,
  'pan': ApIcons.pan,
  'shield': ApIcons.shield,
  'cash': ApIcons.cash,
  'topup': ApIcons.wallet,
};
