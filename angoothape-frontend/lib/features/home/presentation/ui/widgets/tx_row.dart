import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';

class TxRow extends StatelessWidget {
  const TxRow({super.key, required this.tx, required this.onTap});
  final Txn tx;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final c = AppScope.of(context);
    final b = bankById(tx.bank);
    final (bg, fg, icon) = switch (tx.svc) {
      'be' => (p.primarySoft, p.primary, ApIcons.scale),
      'ms' => (p.primarySoft, p.primary, ApIcons.doc),
      _ => switch (tx.status) {
        TxStatus.failed => (p.errorBg, p.error, ApIcons.cash),
        TxStatus.pending => (p.warningBg, p.warning, ApIcons.cash),
        TxStatus.success => (p.primarySoft, p.primary, ApIcons.cash),
      },
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        hoverColor: p.canvas,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: fg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.t(tx.svc)} · ${b?.short ?? ''}',
                        style: body(
                          14.5,
                          weight: FontWeight.w600,
                          color: p.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${maskAadhaar(tx.aadhaar4)} · ${dayLabel(tx.t, c.lang, c.t('today'), c.t('yesterday'))}, ${fmtT(tx.t)}',
                        style: body(12.5, color: p.ink2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (tx.svc == 'cw')
                      AmountText(tx.amt, size: 17, dec: 0)
                    else
                      Text('—', style: body(12.5, color: p.ink2)),
                    const SizedBox(height: 4),
                    StatusBadge(tx.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
