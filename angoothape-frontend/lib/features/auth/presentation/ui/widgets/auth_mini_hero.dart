
import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

class AuthMiniHero extends StatelessWidget {
  const AuthMiniHero({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      color: const Color(0xFF1B1944),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wordmark(height: 36, onDark: true),
          const SizedBox(height: 12),
          Text(c.t('welcome_t'), style: display(22, color: Colors.white)),
        ],
      ),
    );
  }
}
