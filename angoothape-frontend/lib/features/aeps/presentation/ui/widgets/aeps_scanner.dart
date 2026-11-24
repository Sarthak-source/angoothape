import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

import 'aeps_finger_hint.dart';
import 'slide_to_scan.dart';

const double _pad = 22;

class AepsScanner extends StatelessWidget {
  const AepsScanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final d = c.scenario.device;
    Widget panel;
    if (a.devChecking) {
      panel = Column(
        children: [
          const Icon(ApIcons.usb, size: 72),
          const SizedBox(height: 12),
          Text(c.t('checking_device'), style: display(18, color: p.ink)),
        ],
      );
    } else if (d != DeviceState.ready) {
      final off = d == DeviceState.disconnected;
      panel = Column(
        children: [
          Icon(
            off ? ApIcons.usb : ApIcons.alert,
            size: 64,
            color: off ? p.warning : p.error,
          ),
          const SizedBox(height: 10),
          Text(
            c.t(off ? 'dev_off_t' : 'dev_perm_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            c.t(off ? 'dev_off_p' : 'dev_perm_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ApButton(
                label: c.t('check_again'),
                icon: ApIcons.refresh,
                onPressed: c.checkDevice,
              ),
              ApButton(
                label: c.t('device_help'),
                kind: ApButtonKind.soft,
                onPressed: () => c.nav('device'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.t('entries_kept'), style: body(12.5, color: p.ink2)),
        ],
      );
    } else if (a.capture == CapturePhase.capturing) {
      panel = Column(
        children: [
          const AepsFingerHint(phase: CapturePhase.capturing),
          const SizedBox(height: 12),
          Text(c.t('capturing'), style: display(18, color: p.ink)),
          Text(
            c.t('place_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (a.capture == CapturePhase.ok) {
      panel = Column(
        children: [
          const AepsFingerHint(phase: CapturePhase.ok),
          const SizedBox(height: 12),
          Text(c.t('cap_ok'), style: display(18, color: p.ink)),
          Text(c.t('sending'), style: body(14, color: p.ink2)),
        ],
      );
    } else if (a.capture == CapturePhase.locked) {
      panel = Column(
        children: [
          const AepsFingerHint(phase: CapturePhase.failed),
          const SizedBox(height: 12),
          Text(
            c.t('cap_fail_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          Text(
            c.t('too_many'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ApButton(
                label: c.t('device_help'),
                kind: ApButtonKind.soft,
                onPressed: () => c.nav('device'),
              ),
              ApButton(
                label: c.t('retry_txn'),
                onPressed: () => c.restartAeps(),
              ),
            ],
          ),
        ],
      );
    } else if (a.capture == CapturePhase.failed) {
      final left = 3 - a.attempts;
      panel = Column(
        children: [
          const AepsFingerHint(phase: CapturePhase.failed),
          const SizedBox(height: 12),
          Text(c.t('cap_fail_t'), style: display(18, color: p.ink)),
          Text(
            c.t('cap_fail_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('$left ${c.t('attempts_left')}', style: body(13, color: p.ink2)),
          const SizedBox(height: 12),
          SlideToScan(label: c.t('try_again'), onConfirmed: c.capture),
        ],
      );
    } else {
      final short = a.service == 'cw'
          ? c.both(
              'Withdraw ${inr(int.tryParse(a.amount) ?? 0, dec: 0)}',
              '${inr(int.tryParse(a.amount) ?? 0, dec: 0)} निकालें',
            )
          : c.t('scan');
      panel = Column(
        children: [
          const AepsFingerHint(phase: CapturePhase.idle),
          const SizedBox(height: 12),
          Text(
            c.t('place_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          Text(
            c.t('place_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SlideToScan(label: short, onConfirmed: c.capture),
          const SizedBox(height: 8),
          Text(
            c.t('no_phone_fp'),
            style: body(12.5, color: p.ink2),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p),
      child: panel,
    );
  }
}
