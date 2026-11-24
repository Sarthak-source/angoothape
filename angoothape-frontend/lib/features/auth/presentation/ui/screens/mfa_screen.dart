import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../widgets/auth_back.dart';
import '../widgets/auth_digit_row.dart';
import '../widgets/auth_layout.dart';

Uint8List? qrBytes(String? dataUrl) {
  if (dataUrl == null || dataUrl.isEmpty) return null;
  final i = dataUrl.indexOf('base64,');
  if (i < 0) return null;
  try {
    return base64Decode(dataUrl.substring(i + 7));
  } catch (_) {
    return null;
  }
}

class MfaScreen extends StatefulWidget {
  const MfaScreen({super.key});
  @override
  State<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends State<MfaScreen> {
  final totp = TextEditingController();
  final totpFocus = FocusNode();

  @override
  void dispose() {
    totp.dispose();
    totpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final bytes = qrBytes(c.login.qrDataUrl);
    final form = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBack(),
          Text(c.t('mfa_t'), style: display(24, color: p.ink)),
          const SizedBox(height: 6),
          Text(
            c.login.enroll ? c.t('mfa_enroll') : c.t('mfa_enter'),
            style: body(14, color: p.ink2),
          ),
          if (bytes != null) ...[
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.line),
                ),
                child: Image.memory(bytes, width: 180, height: 180),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              c.t('mfa_scan'),
              textAlign: TextAlign.center,
              style: body(12.5, color: p.ink2),
            ),
          ],
          const SizedBox(height: 16),
          Text(c.t('mfa_totp'), style: body(13, weight: FontWeight.w600)),
          if (c.login.demoTotp != null) ...[
            const SizedBox(height: 4),
            Text(
              '${c.t('mfa_demo')}: ${c.login.demoTotp}',
              style: body(13, color: p.accentText),
            ),
          ],
          const SizedBox(height: 8),
          AuthDigitRow(
            controller: totp,
            focus: totpFocus,
            onChanged: () => setState(() {}),
          ),
          if (c.login.otpErr.isNotEmpty) HelpText(c.login.otpErr, error: true),
          const SizedBox(height: 18),
          ApButton(
            label: c.t('cont'),
            expand: true,
            busy: c.login.busy,
            onPressed: () => c.submitTotp(totp.text),
          ),
        ],
      ),
    );
    return AuthLayout(form: form);
  }
}
