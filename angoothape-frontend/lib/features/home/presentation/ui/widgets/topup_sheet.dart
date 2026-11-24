import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../controllers/home_controller.dart';

class TopupSheet extends StatefulWidget {
  const TopupSheet({super.key});
  @override
  State<TopupSheet> createState() => TopupSheetState();
}

class TopupSheetState extends State<TopupSheet> {
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
    final n = int.tryParse(amt.text) ?? 0;
    final err = (c.sheet?.tried ?? false) && (n < 100 || n > 50000);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.both('Wallet top-up', 'वॉलेट टॉप-अप')),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: ApTextField(
            label: c.both('Amount', 'राशि'),
            controller: amt,
            digits: 7,
            invalid: err,
            onChanged: (v) {
              home.setSettleAmt(v);
              setState(() {});
            },
          ),
        ),
        if (err)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: HelpText(
              c.both('Enter between ₹100 and ₹50,000.', '₹100 से ₹50,000 के बीच लिखें।'),
              error: true,
            ),
          ),
        SheetFoot(
          children: [
            ApButton(
              label: c.both('Add to wallet', 'वॉलेट में जोड़ें'),
              expand: true,
              onPressed: () {
                home.setSettleAmt(amt.text);
                home.submitTopup();
              },
            ),
          ],
        ),
      ],
    );
  }
}
