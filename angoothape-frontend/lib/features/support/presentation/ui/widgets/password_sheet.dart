import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';

class PasswordSheet extends StatefulWidget {
  const PasswordSheet({super.key});
  @override
  State<PasswordSheet> createState() => PasswordSheetState();
}

class PasswordSheetState extends State<PasswordSheet> {
  final current = TextEditingController();
  final next = TextEditingController();
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final tried = c.sheet?.tried ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.both('Password & security', 'पासवर्ड और सुरक्षा')),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: Column(
            children: [
              ApTextField(
                label: c.both('Current password', 'वर्तमान पासवर्ड'),
                controller: current,
                obscure: true,
                error: tried && current.text.isEmpty
                    ? c.both('Enter current password', 'वर्तमान पासवर्ड लिखें')
                    : null,
              ),
              ApTextField(
                label: c.both('New password', 'नया पासवर्ड'),
                controller: next,
                obscure: true,
                error: tried && next.text.length < 8
                    ? c.both('Use at least 8 characters', 'कम से कम 8 अक्षर')
                    : null,
              ),
            ],
          ),
        ),
        SheetFoot(
          children: [
            ApButton(
              label: c.both('Update password', 'पासवर्ड बदलें'),
              expand: true,
              onPressed: () => c.submitPassword(current.text, next.text),
            ),
          ],
        ),
      ],
    );
  }
}
