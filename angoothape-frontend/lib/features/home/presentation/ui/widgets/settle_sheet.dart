import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../controllers/home_controller.dart';
import '../../../../session/domain/entities/session_entities.dart';

class SettleSheet extends StatefulWidget {
  const SettleSheet({super.key});
  @override
  State<SettleSheet> createState() => SettleSheetState();
}

class SettleSheetState extends State<SettleSheet> {
  final amt = TextEditingController();
  @override
  void dispose() {
    amt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    final n = int.tryParse(amt.text) ?? 0;
    final err =
        (c.sheet?.tried ?? false) && (n < 100 || n > c.data.wallet.aeps);
    final active = c.data.accounts.where((a) => a.status == 'active');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.t('move_bank')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApTextField(
                  label: c.both('Amount', 'राशि'),
                  controller: amt,
                  digits: 7,
                  invalid: err,
                  style: display(28, weight: FontWeight.w700),
                  padding: EdgeInsets.zero,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Center(
                      widthFactor: 1,
                      child: Text('₹', style: display(26, color: p.ink2)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ApChip(
                      label:
                          '${c.both('All', 'पूरा')} ${inr(c.data.wallet.aeps, dec: 0)}',
                      selected: false,
                      onTap: () => setState(
                        () => amt.text = c.data.wallet.aeps.floor().toString(),
                      ),
                    ),
                  ],
                ),
                if (err)
                  HelpText(
                    c.both(
                      'Enter between ₹100 and ${inr(c.data.wallet.aeps, dec: 0)}.',
                      '₹100 से ${inr(c.data.wallet.aeps, dec: 0)} के बीच राशि डालें।',
                    ),
                    error: true,
                  )
                else
                  HelpText('${c.t('aeps_bal')}: ${inr(c.data.wallet.aeps)}'),
                const SizedBox(height: 10),
                Text(
                  c.both('To account', 'खाता'),
                  style: body(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final a in active)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: cardBox(p, radius: 22),
                    child: Row(
                      children: [
                        if (bankById(a.bank) != null)
                          BankMono(bankById(a.bank)!),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bankById(a.bank)?.name ?? ''} ••${a.last4}',
                                style: body(14, weight: FontWeight.w700),
                              ),
                              Text(a.holder, style: body(12.5, color: p.ink2)),
                            ],
                          ),
                        ),
                        Icon(ApIcons.check, color: p.success, size: 20),
                      ],
                    ),
                  ),
                Notice(
                  tone: NoticeTone.warn,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        c.both(
                          'Settlement charges and timing depend on the partner and are not confirmed.',
                          'सेटलमेंट शुल्क और समय पार्टनर पर निर्भर हैं, अभी तय नहीं।',
                        ),
                      ),
                      const AssumeTag(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SheetFoot(
          children: [
            ApButton(
              label: c.t('cancel'),
              kind: ApButtonKind.ghost,
              onPressed: c.closeSheet,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ApButton(
                label: c.t('move_bank'),
                onPressed: () {
                  c.sheet?.amt = amt.text;
                  home.submitSettle();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
