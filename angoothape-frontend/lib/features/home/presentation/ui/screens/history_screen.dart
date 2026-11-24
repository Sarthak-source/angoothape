import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../controllers/home_controller.dart';
import '../widgets/history_grouped.dart';
import '../widgets/history_tx_table.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final q = TextEditingController();

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    final layout = LayoutScope.of(context);
    final rows = home.filteredTx();
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c.t('nav_hist'), style: display(22, color: p.ink)),
              const Spacer(),
              ApButton(
                label: c.t('export'),
                kind: ApButtonKind.outline,
                small: true,
                icon: ApIcons.download,
                onPressed: home.requestExport,
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, box) {
              final search = ApTextField(
                controller: q,
                hint: c.t('search_hist'),
                padding: EdgeInsets.zero,
                prefix: Icon(ApIcons.search, color: p.ink3, size: 20),
                onChanged: (v) => home.setHist(q: v),
              );
              final chips = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in ['all', 'success', 'failed', 'pending'])
                    ApChip(
                      label: s == 'all' ? c.t('all') : c.t('s_$s'),
                      selected: c.hist.status == s,
                      onTap: () => home.setHist(status: s),
                    ),
                ],
              );
              final selects = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    child: ApDropdown<String>(
                      key: ValueKey('svc-${c.hist.svc}'),
                      value: c.hist.svc,
                      compact: true,
                      padding: EdgeInsets.zero,
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(c.both('All services', 'सभी सेवाएँ')),
                        ),
                        for (final s in ['cw', 'be', 'ms'])
                          DropdownMenuItem(value: s, child: Text(c.t(s))),
                      ],
                      onChanged: (v) => home.setHist(svc: v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 160,
                    child: ApDropdown<String>(
                      key: ValueKey('range-${c.hist.range}'),
                      value: c.hist.range,
                      compact: true,
                      padding: EdgeInsets.zero,
                      items: [
                        DropdownMenuItem(value: '1', child: Text(c.t('today'))),
                        DropdownMenuItem(value: '7', child: Text(c.t('last7'))),
                        DropdownMenuItem(
                          value: '30',
                          child: Text(c.t('last30')),
                        ),
                      ],
                      onChanged: (v) => home.setHist(range: v),
                    ),
                  ),
                ],
              );
              if (box.maxWidth >= 1100) {
                return Row(
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: search,
                      ),
                    ),
                    const SizedBox(width: 10),
                    chips,
                    const SizedBox(width: 10),
                    selects,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  search,
                  const SizedBox(height: 10),
                  chips,
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: selects,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (c.hist.loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(ApIcons.search, size: 40, color: p.ink3),
                  const SizedBox(height: 8),
                  Text(
                    c.t('no_results'),
                    textAlign: TextAlign.center,
                    style: body(14, color: p.ink2),
                  ),
                  TextButton(
                    onPressed: () {
                      q.clear();
                      home.clearHist();
                    },
                    child: Text(c.t('clear_filters')),
                  ),
                ],
              ),
            )
          else if (layout.history == HistoryPresentation.table)
            HistoryTxTable(rows: rows)
          else
            HistoryGrouped(rows: rows),
          Text(
            '${rows.length} ${c.t('txns')}',
            style: body(12.5, color: p.ink2),
          ),
        ],
      ),
    );
  }
}

