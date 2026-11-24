import 'package:flutter/material.dart';

import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/widgets/app_widgets.dart';

class AuthBack extends StatelessWidget {
  const AuthBack({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: c.back,
        icon: const Icon(ApIcons.chevL, size: 18),
        label: Text(c.t('back')),
      ),
    );
  }
}
