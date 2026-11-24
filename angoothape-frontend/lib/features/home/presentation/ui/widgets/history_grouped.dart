import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import 'tx_row.dart';

class HistoryGrouped extends StatelessWidget {
  const HistoryGrouped({super.key, required this.rows});
  final List<Txn> rows;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final groups = <String, List<Txn>>{};
    for (final x in rows) {
      final label = dayLabel(x.t, c.lang, c.t('today'), c.t('yesterday'));
      groups.putIfAbsent(label, () => []).add(x);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Text(
              e.key.toUpperCase(),
              style: body(12, weight: FontWeight.w700, color: p.ink2),
            ),
          ),
          Container(
            decoration: cardBox(p),
            child: Column(
              children: [
                for (final tx in e.value)
                  TxRow(
                    tx: tx,
                    onTap: () => c.go('txn', params: {'ref': tx.ref}),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
