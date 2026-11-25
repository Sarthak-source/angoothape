import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/di.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/business_step.dart';
import '../widgets/kyc_step.dart';
import '../widgets/role_step.dart';
import '../widgets/status_step.dart';

class JoinScreen extends ConsumerWidget {
  const JoinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appProvider);
    final c = ref.read(appProvider.notifier);
    final p = ap(context);
    final steps = session.hi
        ? ['भूमिका', 'व्यवसाय', 'KYC', 'स्थिति']
        : ['Role', 'Business', 'KYC', 'Status'];
    return Scaffold(
      backgroundColor: p.canvas,
      body: SafeArea(
        child: ScreenPad(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: c.back,
                    icon: const Icon(ApIcons.chevL),
                    label: Text(c.t('back')),
                  ),
                  const Spacer(),
                  const Wordmark(height: 26),
                ],
              ),
              const SizedBox(height: 8),
              StepperBar(
                labels: steps,
                index: session.join.step,
                doneLast: session.join.step == 3 && session.join.approved,
              ),
              const SizedBox(height: 18),
              switch (session.join.step) {
                0 => const RoleStep(),
                1 => const BusinessStep(),
                2 => const KycStep(),
                _ => const JoinStatusStep(),
              },
            ],
          ),
        ),
      ),
    );
  }
}
