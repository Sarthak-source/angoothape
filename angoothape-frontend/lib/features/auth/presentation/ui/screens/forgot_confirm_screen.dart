
import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/auth_layout.dart';

class ForgotConfirmScreen extends StatefulWidget {
  const ForgotConfirmScreen({super.key});
  @override
  State<ForgotConfirmScreen> createState() => _ForgotConfirmScreenState();
}

class _ForgotConfirmScreenState extends State<ForgotConfirmScreen> {
  final otp = TextEditingController();
  final password = TextEditingController();
  @override
  void dispose() {
    otp.dispose();
    password.dispose();
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
            Text(c.t('otp_t'), style: display(24, color: p.ink)),
            if (c.login.demoOtp != null) ...[
              const SizedBox(height: 8),
              Text(
                '${c.t('otp_demo')}: ${c.login.demoOtp}',
                style: body(13, color: p.accentText),
              ),
            ],
            const SizedBox(height: 16),
            ApTextField(
              label: c.t('otp_t'),
              controller: otp,
              digits: 6,
              maxLength: 6,
              fill: p.canvas,
              error: c.login.otpErr.isEmpty ? null : c.login.otpErr,
            ),
            ApTextField(
              label: c.both('New password', 'नया पासवर्ड'),
              controller: password,
              obscure: true,
              fill: p.canvas,
              prefix: Icon(ApIcons.lock, color: p.ink3),
            ),
            ApButton(
              label: c.both('Reset password', 'पासवर्ड रीसेट करें'),
              expand: true,
              busy: c.login.busy,
              onPressed: () => c.confirmForgot(otp.text, password.text),
            ),
          ],
        ),
      ),
    );
  }
}
