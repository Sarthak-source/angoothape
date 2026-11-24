import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

import 'tx_row.dart';

class DashRecent extends StatelessWidget {
  const DashRecent({super.key, required this.c, required this.p});
  final AppController c;
  final ApPalette p;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardBox(p),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                c.t('recent'),
                style: display(18, weight: FontWeight.w700, color: p.ink),
              ),
              const Spacer(),
              ApButton(
                small: true,
                kind: ApButtonKind.soft,
                label: c.t('view_all'),
                trailingIcon: ApIcons.chevR,
                onPressed: () => c.nav('hist'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tx in c.data.tx.take(4))
            TxRow(
              tx: tx,
              onTap: () => c.go('txn', params: {'ref': tx.ref}),
            ),
        ],
      ),
    );
  }
}
