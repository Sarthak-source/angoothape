import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../aeps/presentation/ui/widgets/result_body.dart';

class TxnScreen extends StatelessWidget {
  const TxnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final x = c.txnByRef(c.params['ref']);
    if (x == null) return Center(child: Text(c.both('Not found', 'नहीं मिला')));
    final b = bankById(x.bank);
    final tickets = c.data.ticketsByRef[x.ref] ?? const <Ticket>[];
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
                  '${c.data.retailer.shop} (${c.data.retailer.id})',
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
