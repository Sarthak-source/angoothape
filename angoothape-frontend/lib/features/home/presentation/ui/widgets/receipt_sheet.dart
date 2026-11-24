import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../controllers/home_controller.dart';
import '../../../../session/domain/entities/session_entities.dart';

class ReceiptSheet extends StatelessWidget {
  const ReceiptSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final x = home.txnByRef(c.sheet?.ref);
    if (x == null) return const SizedBox.shrink();
    final b = bankById(x.bank);
    final share =
        LayoutScope.of(context).receipt == ReceiptPresentation.shareAndPrint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.t('receipt')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDEDDE9)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFC4C3D4),
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Wordmark(height: 26),
                                const Spacer(),
                                Text(
                                  '${c.t(x.svc)}\n${c.t('customer_copy')}',
                                  textAlign: TextAlign.right,
                                  style: body(
                                    11,
                                    weight: FontWeight.w600,
                                    color: const Color(0xFF56546B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 12),
                        child: Column(
                          children: [
                            if (x.svc == 'cw')
                              AmountText(
                                x.amt,
                                size: 30,
                                color: const Color(0xFF1B1A2E),
                              )
                            else
                              Text(
                                c.t(x.svc),
                                style: display(
                                  18,
                                  color: const Color(0xFF1B1A2E),
                                ),
                              ),
                            const SizedBox(height: 6),
                            StatusBadge(x.status),
                          ],
                        ),
                      ),
                      _r(c.t('datetime'), fmtDt(x.t, c.lang)),
                      _r(c.t('ref'), x.ref),
                      _r(c.t('rrn'), x.rrn),
                      _r(c.t('bank'), b?.name ?? ''),
                      _r(c.t('masked_id'), maskAadhaar(x.aadhaar4)),
                      _r(c.t('mobile'), maskMobile(x.mobile4)),
                      if (x.status == TxStatus.success && x.bal != null)
                        _r(c.t('cust_bal'), inr(x.bal!)),
                      _r(
                        c.both('Retailer', 'रिटेलर'),
                        '${c.data.retailer.shop}\n${c.data.retailer.id} · ${c.data.retailer.city}',
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        height: 1.5,
                        thickness: 1.5,
                        color: Color(0xFFC4C3D4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        x.status == TxStatus.success
                            ? c.both(
                                'Confirmed by bank.',
                                'बैंक द्वारा पुष्टि की गई।',
                              )
                            : x.status == TxStatus.failed
                            ? c.both(
                                'Failed — no cash given to customer.',
                                'असफल — ग्राहक को नकद नहीं दिया गया।',
                              )
                            : c.both(
                                'Pending — do not give cash until confirmed.',
                                'पेंडिंग — परिणाम की पुष्टि होने तक नकद न दें।',
                              ),
                        textAlign: TextAlign.center,
                        style: body(
                          11,
                          color: const Color(0xFF737189),
                          height: 1.5,
                        ),
                      ),
                      Text(
                        c.both(
                          'Demo receipt with mock data. Help: 1800 000 0000',
                          'मॉक डेटा वाली डेमो रसीद। सहायता: 1800 000 0000',
                        ),
                        textAlign: TextAlign.center,
                        style: body(
                          11,
                          color: const Color(0xFF737189),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 58,
                  right: 14,
                  child: Transform.rotate(
                    angle: 8 * 3.1415926535 / 180,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFB8441A),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEMO',
                        style: display(
                          10,
                          weight: FontWeight.w700,
                          color: const Color(0xFFB8441A),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SheetFoot(
          children: [
            if (share) ...[
              Expanded(
                child: ApButton(
                  label: c.t('share'),
                  icon: ApIcons.share,
                  onPressed: () => home.receiptAction('share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ApButton(
                  label: c.t('print'),
                  kind: ApButtonKind.outline,
                  icon: ApIcons.printer,
                  onPressed: () => home.receiptAction('print'),
                ),
              ),
            ] else ...[
              ApButton(
                label: c.t('copy_ref'),
                kind: ApButtonKind.ghost,
                icon: ApIcons.copy,
                onPressed: () => copyText(context, x.ref, c.t('copied')),
              ),
              const Spacer(),
              ApButton(
                label: c.t('download'),
                kind: ApButtonKind.outline,
                icon: ApIcons.download,
                onPressed: () => home.receiptAction('download'),
              ),
              const SizedBox(width: 10),
              ApButton(
                label: c.t('print'),
                icon: ApIcons.printer,
                onPressed: () => home.receiptAction('print'),
              ),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ApIcons.info, size: 16, color: ap(context).ink2),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.both(
                    'Each print, download or share is stored on your account.',
                    'हर प्रिंट, डाउनलोड या शेयर आपके खाते में दर्ज होता है।',
                  ),
                  style: body(12, color: ap(context).ink2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _r(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(k, style: body(12.5, color: const Color(0xFF56546B))),
        ),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(
              12.5,
              weight: FontWeight.w700,
              color: const Color(0xFF1B1A2E),
            ),
          ),
        ),
      ],
    ),
  );
}
