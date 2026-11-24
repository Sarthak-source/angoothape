import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';

class ScenarioSheet extends StatelessWidget {
  const ScenarioSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final s = c.scenario;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHead(c.both('Demo scenarios', 'डेमो स्थितियाँ')),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  c.both(
                    'These switches only change the next mock transaction. Nothing here is a real bank or device.',
                    'ये स्विच केवल अगले मॉक लेन-देन को बदलते हैं।',
                  ),
                  style: body(13, color: ap(context).ink2),
                ),
              ),
              _sec(c.both('Next transaction outcome', 'अगला परिणाम')),
              RadioGroup<OutcomeKind>(
                groupValue: s.outcome,
                onChanged: (v) {
                  if (v != null) c.setOutcome(v);
                },
                child: Column(
                  children: [
                    for (final o in OutcomeKind.values)
                      RadioListTile<OutcomeKind>(
                        value: o,
                        title: Text(_outcome(c, o)),
                      ),
                  ],
                ),
              ),
              if (s.outcome == OutcomeKind.failed) ...[
                _sec(c.both('Failure reason', 'असफलता का कारण')),
                RadioGroup<String>(
                  groupValue: s.failReason,
                  onChanged: (v) {
                    if (v != null) c.setFailReason(v);
                  },
                  child: Column(
                    children: [
                      for (final r in ['insufficient', 'bio', 'bankdown'])
                        RadioListTile<String>(
                          value: r,
                          title: Text(reasons[r]!.text(c.lang)),
                        ),
                    ],
                  ),
                ),
              ],
              if (s.outcome == OutcomeKind.pending ||
                  s.outcome == OutcomeKind.network) ...[
                _sec(
                  c.both(
                    'When status is checked, resolve as',
                    'स्थिति जाँच पर परिणाम',
                  ),
                ),
                RadioGroup<String>(
                  groupValue: s.pendingResolve,
                  onChanged: (v) {
                    if (v != null) c.setPendingResolve(v);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'success',
                        title: Text(c.t('s_success')),
                      ),
                      RadioListTile<String>(
                        value: 'failed',
                        title: Text(c.t('s_failed')),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    c.both(
                      'Pending needs 2 checks. A network-unknown resolves on the first check.',
                      'पेंडिंग के लिए 2 जाँच। नेटवर्क-अज्ञात पहली जाँच पर सुलझता है।',
                    ),
                    style: body(12, color: ap(context).ink2),
                  ),
                ),
              ],
              _sec(c.both('Fingerprint device', 'फ़िंगरप्रिंट डिवाइस')),
              RadioGroup<DeviceState>(
                groupValue: s.device,
                onChanged: (v) {
                  if (v != null) c.setDevice(v);
                },
                child: Column(
                  children: [
                    for (final d in DeviceState.values)
                      RadioListTile<DeviceState>(
                        value: d,
                        title: Text(_dev(c, d)),
                      ),
                  ],
                ),
              ),
              _sec(c.both('Fingerprint capture', 'फ़िंगरप्रिंट कैप्चर')),
              RadioGroup<bool>(
                groupValue: s.captureRetry,
                onChanged: (v) {
                  if (v != null) c.setCaptureRetry(v);
                },
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: false,
                      title: Text(c.both('Good first time', 'पहली बार साफ़')),
                    ),
                    RadioListTile<bool>(
                      value: true,
                      title: Text(
                        c.both('First attempt unclear', 'पहली कोशिश अस्पष्ट'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  c.both(
                    'Aadhaar is cleared when a transaction is submitted and is never stored.',
                    'आधार सबमिट पर मिट जाता है और सेव नहीं होता।',
                  ),
                  style: body(12, color: ap(context).ink2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Text(t, style: body(12, weight: FontWeight.w800)),
  );

  String _outcome(AppController c, OutcomeKind o) => switch (o) {
    OutcomeKind.success => c.t('s_success'),
    OutcomeKind.failed => c.t('s_failed'),
    OutcomeKind.pending => c.both('Pending (bank slow)', 'पेंडिंग (बैंक धीमा)'),
    OutcomeKind.network => c.both(
      'Network drop → unknown',
      'नेटवर्क टूटा → अज्ञात',
    ),
  };

  String _dev(AppController c, DeviceState d) => switch (d) {
    DeviceState.ready => c.t('dev_ready'),
    DeviceState.disconnected => c.t('dev_off'),
    DeviceState.permission => c.t('dev_perm'),
  };
}
