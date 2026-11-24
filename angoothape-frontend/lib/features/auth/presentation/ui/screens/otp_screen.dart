import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../widgets/auth_back.dart';
import '../widgets/auth_digit_row.dart';
import '../widgets/auth_layout.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final code = TextEditingController();
  final focus = FocusNode();
  Timer? timer;
  String _pushed = '';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final otp = AppScope.of(context).login.otp;
    if (otp != _pushed) {
      _pushed = otp;
      code.text = otp;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final left = c.login.resendAt
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 99);
    final form = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBack(),
          Text(c.t('otp_t'), style: display(24, color: p.ink)),
          const SizedBox(height: 6),
          Text(
            c.login.emailMasked == null
                ? c.t('otp_sent')
                : '${c.t('otp_email')} ${c.login.emailMasked}',
            style: body(14, color: p.ink2),
          ),
          if (c.login.demoOtp != null) ...[
            const SizedBox(height: 8),
            Text(
              '${c.t('otp_demo')}: ${c.login.demoOtp}',
              style: body(13, color: p.accentText),
            ),
          ],
          const SizedBox(height: 18),
          AuthDigitRow(
            controller: code,
            focus: focus,
            onChanged: () => setState(() {}),
          ),
          if (c.login.otpErr.isNotEmpty) HelpText(c.login.otpErr, error: true),
          const SizedBox(height: 18),
          ApButton(
            label: c.t('verify'),
            expand: true,
            busy: c.login.busy,
            onPressed: () => c.submitOtp(code.text),
          ),
          const SizedBox(height: 12),
          Center(
            child: left > 0
                ? Text(
                    '${c.t('resend_in')} 0:${left.toString().padLeft(2, '0')}',
                    style: body(13, color: p.ink2),
                  )
                : TextButton(
                    onPressed: c.resendOtp,
                    child: Text(c.t('resend')),
                  ),
          ),
        ],
      ),
    );
    return AuthLayout(form: form);
  }
}
