import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

import '../widgets/auth_mini_hero.dart';
import '../widgets/login_art.dart';

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
    final wide = const LayoutService()
        .resolve(MediaQuery.sizeOf(context).width)
        .twoColumnForms;
    final form = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: c.back, child: Text(c.t('back'))),
          Text(c.t('otp_t'), style: display(24, color: p.ink)),
          const SizedBox(height: 6),
          Text(c.t('otp_sent'), style: body(14, color: p.ink2)),
          if (c.login.demoOtp != null) ...[
            const SizedBox(height: 8),
            Text(
              '${c.t('otp_demo')}: ${c.login.demoOtp}',
              style: body(13, color: p.accentText),
            ),
          ],
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => focus.requestFocus(),
            child: Stack(
              children: [
                Row(
                  children: List.generate(6, (i) {
                    final ch = i < code.text.length ? code.text[i] : '';
                    final cur = i == code.text.length;
                    return Expanded(
                      child: Container(
                        height: 58,
                        margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cur ? p.primarySoft : p.canvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cur ? p.primary : p.line,
                            width: 1.5,
                          ),
                        ),
                        child: Text(ch, style: display(24, color: p.ink)),
                      ),
                    );
                  }),
                ),
                Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: code,
                    focusNode: focus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      setState(() {});
                      if (v.length == 6) c.submitOtp(v);
                    },
                  ),
                ),
              ],
            ),
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
    if (!wide) {
      return ListView(
        children: [
          const AuthMiniHero(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              decoration: cardBox(p),
              child: form,
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 3, child: LoginArt()),
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
                  decoration: cardBox(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Wordmark(height: 36),
                      ),
                      form,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
