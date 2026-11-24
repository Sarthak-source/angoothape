import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

class ResultBody extends StatelessWidget {
  const ResultBody({super.key, required this.tx, required this.live});
  final Txn tx;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final b = bankById(tx.bank);
    final busy = c.checking[tx.ref] == true;
    late Widget head;
    final extras = <Widget>[];
    final actions = <Widget>[];

    if (tx.status == TxStatus.success) {
      final title = tx.svc == 'cw'
          ? c.t('ok_t')
          : tx.svc == 'be'
          ? c.t('be_ok')
          : c.t('ms_ok');
      head = ResultHead(
        icon: ApIcons.check,
        color: p.success,
        bg: p.successBg,
        title: title,
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      if (tx.svc == 'cw') {
        extras.add(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1944),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(ApIcons.cash, color: Color(0xFFFBA078), size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.t('give_cash')}: ${inr(tx.amt, dec: 0)}',
                        style: display(
                          20,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        c.t('give_cash_p'),
                        style: body(13, color: const Color(0xFFC6C4EC)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (tx.svc == 'ms') extras.add(ResultMiniLine(tx: tx));
      extras.add(
        ResultCard(
          children: [
            _kv(p, c.t('cust_bal'), tx.bal == null ? '—' : inr(tx.bal!)),
            if (tx.svc == 'cw')
              _kv(
                p,
                c.t('wallet_credit'),
                '+ ${inr(tx.amt)}',
                valueColor: p.success,
              ),
            if (tx.svc == 'cw')
              _kv(p, c.t('your_earning'), inr(tx.earn), tag: c.t('sample')),
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('rrn'), tx.rrn),
          ],
        ),
      );
      actions.add(
        ApButton(
          label: c.t('view_receipt'),
          icon: ApIcons.doc,
          expand: true,
          onPressed: () => c.openReceipt(tx.ref),
        ),
      );
      actions.add(
        live
            ? ApButton(
                label: c.t('new_txn'),
                kind: ApButtonKind.outline,
                icon: ApIcons.plus,
                expand: true,
                onPressed: () => c.restartAeps(keep: false),
              )
            : ApButton(
                label: c.t('support_req'),
                kind: ApButtonKind.outline,
                icon: ApIcons.headset,
                expand: true,
                onPressed: () => c.openSupport(tx.ref),
              ),
      );
    } else if (tx.status == TxStatus.failed) {
      final reason = reasons[tx.reason];
      head = ResultHead(
        icon: ApIcons.close,
        color: p.error,
        bg: p.errorBg,
        title: tx.svc == 'cw'
            ? c.t('fail_t')
            : c.both('Transaction failed', 'लेन-देन असफल'),
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      extras.add(
        Notice(
          tone: NoticeTone.err,
          icon: ApIcons.alert,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tx.svc == 'cw' ? '${c.t('no_cash')} ' : ''}${reason?.text(c.lang) ?? ''}',
                style: body(14, weight: FontWeight.w700),
              ),
              Text(reason?.next(c.lang) ?? '', style: body(13)),
            ],
          ),
        ),
      );
      if (tx.svc == 'cw') {
        extras.add(
          Notice(
            tone: NoticeTone.info,
            child: Text(
              '${c.t('fail_debit')} ${c.both('If the customer says money was debited, raise a support request.', 'अगर ग्राहक कहे कि पैसा कटा है, तो सहायता अनुरोध करें।')}',
            ),
          ),
        );
      }
      extras.add(
        ResultCard(
          children: [
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('rrn'), tx.rrn),
            _kv(p, c.t('masked_id'), maskAadhaar(tx.aadhaar4)),
          ],
        ),
      );
      if (live) {
        actions.add(
          ApButton(
            label: c.t('retry_txn'),
            icon: ApIcons.refresh,
            expand: true,
            onPressed: () => c.restartAeps(),
          ),
        );
        actions.add(
          ApButton(
            label: c.t('get_help'),
            kind: ApButtonKind.outline,
            icon: ApIcons.headset,
            expand: true,
            onPressed: () => c.openSupport(tx.ref),
          ),
        );
      } else {
        actions.add(
          ApButton(
            label: c.t('receipt'),
            kind: ApButtonKind.outline,
            icon: ApIcons.doc,
            expand: true,
            onPressed: () => c.openReceipt(tx.ref),
          ),
        );
        actions.add(
          ApButton(
            label: c.t('support_req'),
            icon: ApIcons.headset,
            expand: true,
            onPressed: () => c.openSupport(tx.ref),
          ),
        );
      }
    } else {
      head = ResultHead(
        icon: tx.unknown ? ApIcons.wifiOff : ApIcons.clock,
        color: p.warning,
        bg: p.warningBg,
        title: tx.unknown ? c.t('net_res_t') : c.t('pend_t'),
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      extras.add(
        Notice(
          tone: NoticeTone.warn,
          icon: ApIcons.alert,
          child: Text(
            '${tx.unknown ? c.t('net_res_p') : c.t('pend_p')} ${c.both('Do not start a new withdrawal for this customer.', 'इसी ग्राहक के लिए नई निकासी शुरू न करें।')}',
          ),
        ),
      );
      extras.add(
        ResultCard(
          children: [
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('masked_id'), maskAadhaar(tx.aadhaar4)),
            _kv(p, c.both('Status checks', 'जाँच की गई'), '${tx.checks}'),
          ],
        ),
      );
      actions.add(
        ApButton(
          label: busy ? c.t('checking') : c.t('check_status'),
          icon: ApIcons.refresh,
          busy: busy,
          expand: true,
          onPressed: busy ? null : () => c.checkStatus(tx.ref),
        ),
      );
      actions.add(
        ApButton(
          label: c.t('support_req'),
          kind: ApButtonKind.outline,
          icon: ApIcons.headset,
          expand: true,
          onPressed: () => c.openSupport(tx.ref),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        const SizedBox(height: 12),
        for (final w in extras) ...[w, const SizedBox(height: 12)],
        LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth > 520) {
              return Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  actions[i],
                ],
              ],
            );
          },
        ),
        if (live) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(onPressed: c.doneAeps, child: Text(c.t('done'))),
              if (tx.status == TxStatus.success)
                TextButton(
                  onPressed: () => c.openSupport(tx.ref),
                  child: Text(c.t('get_help')),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _kv(
    ApPalette p,
    String k,
    String v, {
    Color? valueColor,
    String? tag,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(k, style: body(14, color: p.ink2)),
              if (tag != null) AssumeTag(label: tag),
            ],
          ),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(
              14,
              weight: FontWeight.w700,
              color: valueColor ?? p.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class ResultHead extends StatelessWidget {
  const ResultHead({super.key, 
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.sub,
    this.amount,
  });
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String sub;
  final int? amount;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(icon, color: color, size: 46),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: display(24, color: p.ink),
          textAlign: TextAlign.center,
        ),
        if (amount != null) AmountText(amount!, size: 48, dec: 0),
        Text(
          sub,
          style: body(13, color: p.ink2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: cardBox(ap(context)),
    child: Column(children: children),
  );
}

class ResultMiniLine extends StatelessWidget {
  const ResultMiniLine({super.key, required this.tx});
  final Txn tx;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final rows = tx.mini;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('ms_ok'), style: display(16, color: p.ink)),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: body(14, weight: FontWeight.w600),
                        ),
                        Text(
                          fmtDt(row.date, c.lang).split(',').first,
                          style: body(12, color: p.ink2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${row.amount > 0 ? '+' : '−'} ${inr(row.amount.abs())}',
                    style: body(
                      14,
                      weight: FontWeight.w700,
                      color: row.amount > 0 ? p.success : p.ink,
                    ),
                  ),
                ],
              ),
            ),
          Text(c.t('fictional'), style: body(12, color: p.ink2)),
        ],
      ),
    );
  }
}
