import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../aeps/presentation/ui/screens/aeps_screen.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

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
    final p = ap(context);
    final layout = LayoutScope.of(context);
    final rows = c.filteredTx();
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
                onPressed: () => c.sim('export'),
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
                onChanged: (v) => c.setHist(q: v),
              );
              final chips = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in ['all', 'success', 'failed', 'pending'])
                    ApChip(
                      label: s == 'all' ? c.t('all') : c.t('s_$s'),
                      selected: c.hist.status == s,
                      onTap: () => c.setHist(status: s),
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
                      onChanged: (v) => c.setHist(svc: v),
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
                      onChanged: (v) => c.setHist(range: v),
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
                      c.clearHist();
                    },
                    child: Text(c.t('clear_filters')),
                  ),
                ],
              ),
            )
          else if (layout.history == HistoryPresentation.table)
            _TxTable(rows: rows)
          else
            _Grouped(rows: rows),
          Text(
            '${rows.length} ${c.t('txns')}',
            style: body(12.5, color: p.ink2),
          ),
        ],
      ),
    );
  }
}

class _Grouped extends StatelessWidget {
  const _Grouped({required this.rows});
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

class _TxTable extends StatefulWidget {
  const _TxTable({required this.rows});
  final List<Txn> rows;
  @override
  State<_TxTable> createState() => _TxTableState();
}

class _TxTableState extends State<_TxTable> {
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

class TxnScreen extends StatelessWidget {
  const TxnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final x = c.txnByRef(c.params['ref']);
    if (x == null) return Center(child: Text(c.both('Not found', 'नहीं मिला')));
    final b = bankById(x.bank);
    final tickets = c.data.tickets.where((k) => k.ref == x.ref);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('txn_details'), style: display(22, color: p.ink)),
          const SizedBox(height: 12),
          ResultBody(tx: x, live: false),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardBox(p),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.t('details'), style: display(16, color: p.ink)),
                const SizedBox(height: 8),
                _line(p, c.t('service'), c.t(x.svc)),
                _line(p, c.t('bank'), b?.name ?? ''),
                _line(p, c.t('masked_id'), maskAadhaar(x.aadhaar4)),
                _line(p, c.t('mobile'), maskMobile(x.mobile4)),
                _line(
                  p,
                  c.t('ref'),
                  x.ref,
                  trailing: TextButton(
                    onPressed: () => copyText(context, x.ref, c.t('copied')),
                    child: Text(c.t('copy')),
                  ),
                ),
                _line(p, c.t('rrn'), x.rrn),
                _line(p, c.t('datetime'), fmtDt(x.t, c.lang)),
                _line(
                  p,
                  c.both('Retailer', 'रिटेलर'),
                  '${Retailer.shop} (${Retailer.id})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardBox(p),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.both('Timeline', 'समयरेखा'),
                  style: display(16, color: p.ink),
                ),
                const SizedBox(height: 8),
                _tl(
                  p,
                  c.both('Started', 'शुरू'),
                  fmtDt(x.t.subtract(const Duration(seconds: 40)), c.lang),
                  ApIcons.check,
                  p.success,
                ),
                _tl(
                  p,
                  c.both(
                    'Fingerprint sent for authentication',
                    'फ़िंगरप्रिंट सत्यापन भेजा',
                  ),
                  fmtDt(x.t.subtract(const Duration(seconds: 25)), c.lang),
                  ApIcons.check,
                  p.success,
                ),
                _tl(
                  p,
                  x.status == TxStatus.success
                      ? c.both('Approved by bank', 'बैंक ने स्वीकृत किया')
                      : x.status == TxStatus.failed
                      ? c.both('Declined by bank', 'बैंक ने अस्वीकार किया')
                      : c.both(
                          'Waiting for bank response',
                          'बैंक के जवाब का इंतज़ार',
                        ),
                  fmtDt(x.t, c.lang),
                  x.status == TxStatus.failed
                      ? ApIcons.close
                      : x.status == TxStatus.pending
                      ? ApIcons.clock
                      : ApIcons.check,
                  x.status == TxStatus.failed
                      ? p.error
                      : x.status == TxStatus.pending
                      ? p.warning
                      : p.success,
                ),
              ],
            ),
          ),
          for (final k in tickets) ...[
            const SizedBox(height: 10),
            Notice(
              tone: NoticeTone.info,
              icon: ApIcons.headset,
              child: Text('${k.id} · ${k.status}\n${k.type}'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(ApPalette p, String k, String v, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: body(14, color: p.ink2)),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(14, weight: FontWeight.w700),
          ),
        ),
        ?trailing,
      ],
    ),
  );

  Widget _tl(
    ApPalette p,
    String title,
    String sub,
    IconData icon,
    Color color,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: body(14, weight: FontWeight.w600)),
              Text(sub, style: body(12.5, color: p.ink2)),
            ],
          ),
        ),
      ],
    ),
  );
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final w = c.data.wallet;
    final items = [...c.data.settlements]..sort((a, b) => b.t.compareTo(a.t));
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('wallet_t'), style: display(22, color: p.ink)),
          const SizedBox(height: 4),
          Text(
            c.both(
              'Each balance is shown separately so they are never confused.',
              'तीनों बैलेंस अलग रखे गए हैं ताकि कोई भ्रम न हो।',
            ),
            style: body(13, color: p.ink2),
          ),
          const SizedBox(height: _gap),
          LayoutBuilder(
            builder: (context, box) {
              final row = box.maxWidth >= 720;
              final cards = [
                _bal(
                  p,
                  c.t('main_wallet'),
                  w.main,
                  c.t('main_wallet_h'),
                  ApButton(
                    label: c.both('Add money', 'पैसे जोड़ें'),
                    kind: ApButtonKind.outline,
                    small: true,
                    icon: ApIcons.plus,
                    onPressed: () => c.sim('topup'),
                  ),
                  fill: row,
                  icon: ApIcons.wallet,
                ),
                _bal(
                  p,
                  c.t('aeps_bal'),
                  w.aeps,
                  c.t('aeps_bal_h'),
                  ApButton(
                    label: c.t('move_bank'),
                    small: true,
                    icon: ApIcons.bank,
                    onPressed: c.openSettle,
                  ),
                  fill: row,
                  icon: ApIcons.fingerprintSimple,
                ),
                _bal(
                  p,
                  c.t('earnings'),
                  w.earn,
                  c.t('earnings_h'),
                  null,
                  tag: c.t('sample'),
                  fill: row,
                  icon: ApIcons.sparkle,
                ),
              ];
              if (row) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: _gap),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: _gap),
                    cards[i],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: _gap),
          Notice(
            tone: NoticeTone.info,
            child: Text(
              c.both(
                "A customer's bank balance never appears in your wallet. It is shown only on that transaction's result and receipt.",
                'ग्राहक का बैंक बैलेंस कभी आपके वॉलेट में नहीं दिखता। वह केवल लेन-देन परिणाम और रसीद पर दिखता है।',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(c.t('settlements'), style: display(16, color: p.ink)),
              const SizedBox(width: 8),
              const AssumeTag(),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: cardBox(p),
            child: Column(
              children: [
                for (final s in items)
                  Builder(
                    builder: (_) {
                      final (bg, fg, icon, label) = switch (s.status) {
                        'reversed' => (
                          p.errorBg,
                          p.error,
                          ApIcons.refresh,
                          c.both('Returned', 'वापस आया'),
                        ),
                        'processing' => (
                          p.warningBg,
                          p.warning,
                          ApIcons.clock,
                          c.both('Processing', 'प्रोसेसिंग'),
                        ),
                        _ => (
                          p.successBg,
                          p.success,
                          ApIcons.check,
                          c.both('Settled', 'सेटल'),
                        ),
                      };
                      final last4 = c.data.accounts
                          .where((a) => a.bank == s.acct)
                          .map((a) => a.last4)
                          .firstOrNull;
                      return ApListRow(
                        leading: ApListRow.tile(ApIcons.bank, bg, fg),
                        title: Text(
                          '${s.id} · ${bankById(s.acct)?.short ?? ''} ••${last4 ?? '—'}',
                        ),
                        subtitle:
                            '${fmtDt(s.t, c.lang)}${s.utr != null ? ' · UTR ${s.utr}' : ''}${s.note != null ? ' · ${s.note}' : ''}',
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AmountText(s.amt, size: 17, dec: 0),
                            const SizedBox(height: 4),
                            ApBadge(label: label, icon: icon, bg: bg, fg: fg),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ApButton(
              kind: ApButtonKind.ghost,
              icon: ApIcons.bank,
              trailingIcon: ApIcons.chevR,
              label: c.t('banks_t'),
              onPressed: () => c.nav('banks'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bal(
    ApPalette p,
    String title,
    double value,
    String help,
    Widget? action, {
    String? tag,
    bool fill = false,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16, color: p.ink2),
              Text(title, style: body(13, color: p.ink2)),
              if (tag != null) AssumeTag(label: tag),
            ],
          ),
          const SizedBox(height: 6),
          AmountText(value, size: 26),
          const SizedBox(height: 4),
          Text(help, style: body(12.5, color: p.ink2)),
          if (action != null) ...[
            const SizedBox(height: 16),
            if (fill) const Spacer(),
            Align(alignment: Alignment.centerLeft, child: action),
          ],
        ],
      ),
    );
  }
}

const double _pad = 20;
const double _gap = 16;

class BanksScreen extends StatelessWidget {
  const BanksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.t('banks_t'), style: display(22, color: p.ink)),
              ),
              ApButton(
                label: c.t('add_bank'),
                small: true,
                icon: ApIcons.plus,
                onPressed: c.openAddBank,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: cardBox(p),
            child: Column(
              children: [
                for (final a in c.data.accounts)
                  Builder(
                    builder: (_) {
                      final b = bankById(a.bank);
                      final (bg, fg, icon, label) = switch (a.status) {
                        'active' => (
                          p.successBg,
                          p.success,
                          ApIcons.check,
                          c.both('Active', 'सक्रिय'),
                        ),
                        'pending' => (
                          p.warningBg,
                          p.warning,
                          ApIcons.clock,
                          c.both('Verifying', 'सत्यापन जारी'),
                        ),
                        _ => (
                          p.errorBg,
                          p.error,
                          ApIcons.close,
                          c.both('Rejected', 'अस्वीकृत'),
                        ),
                      };
                      return ApListRow(
                        leading: b == null
                            ? const SizedBox(width: 42)
                            : BankMono(b, size: 42),
                        title: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${b?.name ?? ''} ••${a.last4}'),
                            if (a.primary)
                              ApBadge(
                                small: true,
                                label: c.both('Primary', 'प्राथमिक'),
                                bg: p.primarySoft,
                                fg: p.primary,
                              ),
                          ],
                        ),
                        subtitle:
                            '${a.holder} · ${a.ifsc}${a.note != null ? ' · ${a.note}' : ''}',
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ApBadge(label: label, icon: icon, bg: bg, fg: fg),
                            if (a.status == 'rejected')
                              TextButton(
                                onPressed: c.openAddBank,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  textStyle: body(
                                    12.5,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                child: Text(c.both('Add again', 'फिर जोड़ें')),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                c.both(
                  'Verified by penny-drop (simulated). Only accounts in your or your shop’s name.',
                  'सत्यापन पेनी-ड्रॉप से (सिम्युलेटेड)। केवल अपने नाम या दुकान के नाम का खाता।',
                ),
                style: body(12.5, color: p.ink2),
              ),
              const AssumeTag(),
            ],
          ),
        ],
      ),
    );
  }
}
