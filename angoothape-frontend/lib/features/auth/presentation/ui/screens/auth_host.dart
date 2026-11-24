
import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

import 'forgot_confirm_screen.dart';
import 'forgot_screen.dart';
import 'login_screen.dart';
import 'mfa_screen.dart';
import 'otp_screen.dart';
import 'welcome_screen.dart';

class AuthHost extends StatelessWidget {
  const AuthHost({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, _) {
        if (c.route != 'welcome') c.back();
      },
      child: Scaffold(
        backgroundColor: ap(context).canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            switch (c.route) {
              'login' => const LoginScreen(),
              'mfa' => const MfaScreen(),
              'otp' => const OtpScreen(),
              'forgot' => const ForgotScreen(),
              'forgot-otp' => const ForgotConfirmScreen(),
              'join' => const SizedBox.shrink(),
              _ => const WelcomeScreen(),
            },
          ],
        ),
      ),
    );
  }
}
