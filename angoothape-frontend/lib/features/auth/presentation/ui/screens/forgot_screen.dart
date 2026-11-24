
import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/auth_layout.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final id = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = AppScope.of(context).login.id;
    if (id.text.isEmpty && current.isNotEmpty) id.text = current;
  }

  @override
  void dispose() {
    id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return AuthLayout(
      form: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: c.back,
                icon: const Icon(ApIcons.chevL),
                label: Text(c.t('back')),
              ),
            ),
            Text(c.t('forgot'), style: display(24, color: p.ink)),
            const SizedBox(height: 8),
            Text(
              c.both(
                'We will send a 6-digit code to the registered mobile.',
                'रजिस्टर्ड मोबाइल पर 6 अंकों का कोड भेजेंगे।',
              ),
              style: body(14, color: p.ink2),
            ),
            const SizedBox(height: 16),
            ApTextField(
              label: c.t('agent_id'),
              controller: id,
              caps: true,
              fill: p.canvas,
              error: c.login.err.isEmpty ? null : c.login.err,
              prefix: Icon(ApIcons.user, color: p.ink3),
            ),
            ApButton(
              label: c.t('cont'),
              expand: true,
              busy: c.login.busy,
              onPressed: () => c.submitForgot(id.text),
            ),
          ],
        ),
      ),
    );
  }
}
