import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/di.dart';
import '../../../../../core/theme/palette.dart';

import 'forgot_confirm_screen.dart';
import 'forgot_screen.dart';
import 'login_screen.dart';
import 'mfa_screen.dart';
import 'otp_screen.dart';
import 'welcome_screen.dart';

class AuthHost extends ConsumerWidget {
  const AuthHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appProvider);
    final c = ref.read(appProvider.notifier);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, _) {
        if (session.route != 'welcome') c.back();
      },
      child: Scaffold(
        backgroundColor: ap(context).canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            switch (session.route) {
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
