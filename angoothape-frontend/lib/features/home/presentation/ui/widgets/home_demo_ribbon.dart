import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

class DemoRibbon extends StatelessWidget {
  const DemoRibbon({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      width: double.infinity,
      color: const Color(0xFF1B1944),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: c.t('demo'),
              style: body(
                11,
                weight: FontWeight.w800,
                color: const Color(0xFFFBA078),
              ),
            ),
            TextSpan(
              text: '  ·  ${c.t('ribbon')}',
              style: body(
                11,
                weight: FontWeight.w600,
                color: const Color(0xFFE2E1F5),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
