import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../controllers/home_controller.dart';
import '../../../../session/domain/entities/session_entities.dart';

class AddBankSheet extends StatefulWidget {
  const AddBankSheet({super.key});
  @override
  State<AddBankSheet> createState() => AddBankSheetState();
}

class AddBankSheetState extends State<AddBankSheet> {
  final holder = TextEditingController();
  final acct = TextEditingController();
  final acct2 = TextEditingController();
  final ifsc = TextEditingController();

  @override
  void dispose() {
    holder.dispose();
    acct.dispose();
    acct2.dispose();
    ifsc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    final tried = c.sheet?.tried ?? false;
    final ifscOk = validIfsc(ifsc.text);
    final bankId = ifscOk ? ifscBank[ifsc.text.substring(0, 4)] : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.t('add_bank')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _f(
                  p,
                  c.both('Account holder name', 'खाताधारक का नाम'),
                  holder,
                  error: tried && holder.text.trim().isEmpty
                      ? c.both('Enter the name.', 'नाम डालें।')
                      : null,
                ),
                _f(
                  p,
                  c.both('Account number', 'खाता संख्या'),
                  acct,
                  digits: true,
                  error: tried && !validAccount(acct.text)
                      ? c.both(
                          'Enter a 9–18 digit account number.',
                          '9–18 अंकों का खाता नंबर डालें।',
                        )
                      : null,
                ),
                _f(
                  p,
                  c.both('Re-enter account number', 'खाता संख्या दोबारा'),
                  acct2,
                  digits: true,
                  error: tried && acct.text != acct2.text
                      ? c.both(
                          'Account numbers do not match.',
                          'दोनों नंबर मेल नहीं खाते।',
                        )
                      : null,
                ),
                _f(
                  p,
                  'IFSC',
                  ifsc,
                  caps: true,
                  error: tried && !ifscOk
                      ? c.both(
                          'Enter a valid IFSC, e.g. SBIN0001234.',
                          'सही IFSC डालें, जैसे SBIN0001234।',
                        )
                      : null,
                ),
                if (ifscOk)
                  HelpText(
                    c.both(
                      '${bankById(bankId)?.name ?? 'Bank found'} · Branch (demo)',
                      '${bankById(bankId)?.name ?? 'बैंक मिला'} · शाखा (डेमो)',
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
                label: c.both('Add and verify', 'जोड़ें और सत्यापित करें'),
                onPressed: () => home.submitBank({
                  'holder': holder.text,
                  'acct': acct.text,
                  'acct2': acct2.text,
                  'ifsc': ifsc.text.toUpperCase(),
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _f(
    ApPalette p,
    String label,
    TextEditingController ctl, {
    bool digits = false,
    bool caps = false,
    String? error,
  }) {
    return ApTextField(
      label: label,
      controller: ctl,
      numeric: digits,
      caps: caps,
      error: error,
      padding: const EdgeInsets.only(bottom: 10),
      onChanged: (_) => setState(() {}),
    );
  }
}
