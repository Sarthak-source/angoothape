
import 'package:flutter/material.dart';

import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

import 'auth_mini_hero.dart';
import 'login_art.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.form});
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final wide = const LayoutService()
        .resolve(MediaQuery.sizeOf(context).width)
        .twoColumnForms;
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
