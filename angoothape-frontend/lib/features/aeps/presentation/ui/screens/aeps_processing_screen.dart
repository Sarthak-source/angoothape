import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

class AepsProcessing extends StatelessWidget {
  const AepsProcessing({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final title = a.offline
        ? c.t('net_t')
        : c.t(
            a.service == 'cw'
                ? 'proc_t'
                : a.service == 'be'
                ? 'proc_be'
                : 'proc_ms',
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: cardBox(p, radius: 56),
            alignment: Alignment.center,
            child: Icon(
              a.offline ? ApIcons.wifiOff : ApIcons.fingerprint,
              size: 48,
              color: a.offline ? p.warning : p.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: display(22, color: p.ink),
            textAlign: TextAlign.center,
          ),
          if (a.service == 'cw')
            AmountText(int.tryParse(a.amount) ?? 0, size: 30, dec: 0),
          const SizedBox(height: 8),
          Text(
            a.offline ? c.t('net_p') : c.t('proc_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    i < a.procStep ? ApIcons.check : Icons.circle_outlined,
                    color: i < a.procStep
                        ? p.success
                        : i == a.procStep
                        ? p.primary
                        : p.ink3,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    c.t('ps${i + 1}'),
                    style: body(
                      15,
                      weight: i == a.procStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == a.procStep ? p.primary : p.ink,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ApButton(
            label: c.t('txn_running'),
            icon: ApIcons.lock,
            kind: ApButtonKind.soft,
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
