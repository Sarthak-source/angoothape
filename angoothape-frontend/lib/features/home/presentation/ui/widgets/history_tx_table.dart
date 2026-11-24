import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';

class HistoryTxTable extends StatefulWidget {
  const HistoryTxTable({super.key, required this.rows});
  final List<Txn> rows;
  @override
  State<HistoryTxTable> createState() => HistoryTxTableState();
}

class HistoryTxTableState extends State<HistoryTxTable> {
  int? focused;
  int? hovered;

  static const _surface = Color(0xFFF7F7FB);
  static const _surfaceDark = Color(0xFF1C1A40);

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final surface = Theme.of(context).brightness == Brightness.dark
        ? _surfaceDark
        : _surface;
    final rows = widget.rows;
    if (focused != null && focused! >= rows.length) focused = 0;
    void open(int i) => c.go('txn', params: {'ref': rows[i].ref});

    Widget cell(
      String text, {
      TextStyle? style,
      TextAlign align = TextAlign.left,
      int flex = 1,
    }) {
      return Expanded(
        flex: flex,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: style ?? body(13.5, color: p.ink),
        ),
      );
    }

    Widget headerCell(
      String label, {
      int flex = 1,
      TextAlign align = TextAlign.left,
    }) {
      return Expanded(
        flex: flex,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: body(12, weight: FontWeight.w600, color: p.ink2),
        ),
      );
    }

    const pad = EdgeInsets.symmetric(horizontal: 14);
    Widget line(List<Widget> children, {required bool header, Color? bg}) {
      return ColoredBox(
        color: bg ?? Colors.transparent,
        child: Padding(
          padding: pad,
          child: SizedBox(
            height: header ? 46 : 52,
            child: Row(children: children),
          ),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          final i = focused ?? 0;
          if (rows.isNotEmpty) open(i);
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          if (rows.isEmpty) return;
          setState(() {
            focused = ((focused ?? -1) + 1).clamp(0, rows.length - 1);
          });
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          if (rows.isEmpty) return;
          setState(() {
            focused = ((focused ?? rows.length) - 1).clamp(0, rows.length - 1);
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardBox(p),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, box) {
              final table = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  line(
                    [
                      headerCell(c.t('datetime'), flex: 16),
                      headerCell(c.t('service'), flex: 14),
                      headerCell(c.t('bank'), flex: 18),
                      headerCell(c.t('masked_id'), flex: 10),
                      headerCell(c.t('ref'), flex: 16),
                      headerCell(c.t('status'), flex: 12),
                      headerCell(
                        c.both('Amount', 'राशि'),
                        flex: 12,
                        align: TextAlign.right,
                      ),
                    ],
                    header: true,
                    bg: surface,
                  ),
                  for (var i = 0; i < rows.length; i++) ...[
                    Divider(height: 1, thickness: 1, color: p.line),
                    MouseRegion(
                      onEnter: (_) => setState(() => hovered = i),
                      onExit: (_) => setState(() {
                        if (hovered == i) hovered = null;
                      }),
                      child: Material(
                        color: hovered == i || focused == i ? surface : p.card,
                        child: InkWell(
                          onTap: () {
                            setState(() => focused = i);
                            open(i);
                          },
                          hoverColor: Colors.transparent,
                          child: line([
                            cell(fmtDt(rows[i].t, c.lang), flex: 16),
                            cell(c.t(rows[i].svc), flex: 14),
                            cell(bankById(rows[i].bank)?.name ?? '', flex: 18),
                            cell('XX${rows[i].aadhaar4}', flex: 10),
                            cell(
                              rows[i].ref,
                              flex: 16,
                              style: body(12.5, color: p.ink).copyWith(
                                fontFamily: 'ui-monospace',
                                fontFamilyFallback: const [
                                  'SFMono-Regular',
                                  'Menlo',
                                  'Consolas',
                                  'monospace',
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge(rows[i].status),
                              ),
                            ),
                            cell(
                              rows[i].svc == 'cw' ? inr(rows[i].amt) : '—',
                              flex: 12,
                              align: TextAlign.right,
                              style: body(
                                13.5,
                                weight: FontWeight.w600,
                                color: rows[i].svc == 'cw' ? p.ink : p.ink2,
                              ),
                            ),
                          ], header: false),
                        ),
                      ),
                    ),
                  ],
                ],
              );
              if (box.maxWidth >= 760) return table;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: 760, child: table),
              );
            },
          ),
        ),
      ),
    );
  }
}
