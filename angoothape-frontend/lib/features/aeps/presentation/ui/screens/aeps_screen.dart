import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

import 'aeps_auth_screen.dart';
import 'aeps_details_screen.dart';
import 'aeps_processing_screen.dart';
import 'aeps_result_screen.dart';

class AepsScreen extends StatelessWidget {
  const AepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final layout = LayoutScope.of(context);
    final step = c.aeps.step;
    final idx = switch (step) {
      AepsStep.details => 0,
      AepsStep.auth => 1,
      AepsStep.processing || AepsStep.result => 2,
    };
    final stepper = step == AepsStep.processing
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StepperBar(
              labels: [
                c.t('step_details'),
                c.t('step_auth'),
                c.t('step_result'),
              ],
              index: idx,
              doneLast: step == AepsStep.result,
            ),
          );
    if (layout.stickyPrimary && step == AepsStep.details) {
      return AepsDetails(stepper: stepper);
    }
    return ScreenPad(
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (layout.showHeader && step != AepsStep.processing)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c.t('aeps_title'),
                      style: display(22, color: ap(context).ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const DevicePill(),
                ],
              ),
            ),
          stepper,
          switch (step) {
            AepsStep.details => const AepsDetails(),
            AepsStep.auth => const AepsAuth(),
            AepsStep.processing => const AepsProcessing(),
            AepsStep.result => const AepsResult(live: true),
          },
        ],
      ),
    );
  }
}
