import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/fingerprint_pad.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/device_tabs.dart';
import '../widgets/support_accordion.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final d = c.scenario.device;
    final ready = d == DeviceState.ready;
    final steps = deviceGuide(c.devTab, c.lang);
    final faqs = deviceFaqs[c.lang] ?? deviceFaqs['en'] ?? const <(String, List<String>)>[];

    final scanner = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: cardBox(p),
      constraints: const BoxConstraints(minHeight: 280),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FingerprintPad(
            state: c.devTest == 'run'
                ? PadState.capturing
                : c.devTest == 'done'
                ? PadState.good
                : ready
                ? PadState.place
                : PadState.bad,
          ),
          const SizedBox(height: 14),
          Text(
            c.devTest == 'run'
                ? c.t('capturing')
                : c.devTest == 'done'
                ? c.both('Capture quality good', 'स्कैन अच्छा है')
                : c.t('test_cap'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          if (c.devTest != 'run') ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                c.devTest == 'done'
                    ? c.both(
                        'Quality score 78/100 (demo)',
                        'गुणवत्ता स्कोर 78/100 (डेमो)',
                      )
                    : c.both(
                        'Place your own finger to check the scanner works.',
                        'अपनी उंगली रखकर जाँचें कि स्कैनर ठीक काम कर रहा है।',
                      ),
                style: body(14, color: p.ink2, height: 1.45),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            if (c.devTest == 'done')
              ApButton(
                label: c.t('test_cap'),
                kind: ApButtonKind.outline,
                onPressed: c.testCapture,
              )
            else if (ready)
              ApButton(
                label: c.t('test_cap'),
                icon: ApIcons.fingerprintSimple,
                onPressed: c.testCapture,
              )
            else
              ApButton(
                label: c.t('check_again'),
                icon: ApIcons.refresh,
                onPressed: c.recheckDevicePage,
              ),
          ],
        ],
      ),
    );

    final guide = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeviceTabs(
          value: c.devTab,
          onChanged: c.setDevTab,
          items: const [
            ('web', 'Web (Windows)'),
            ('android', 'Android'),
            ('ios', 'iOS'),
          ],
        ),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            child: Text(
              '${i + 1}.  ${steps[i]}',
              style: body(14, color: p.ink, height: 1.5),
            ),
          ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              c.both(
                'Supported scanner models and platform support are an integration dependency to confirm.',
                'डिवाइस मॉडल और प्लेटफ़ॉर्म सपोर्ट एक इंटीग्रेशन निर्भरता है।',
              ),
              style: body(12.5, color: p.ink2),
            ),
            AssumeTag(label: c.both('Dependency', 'Dependency')),
          ],
        ),
      ],
    );

    return ScreenPad(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.t('device_t'), style: display(22, color: p.ink)),
            const SizedBox(height: 18),
            Notice(
              padding: const EdgeInsets.all(18),
              tone: ready
                  ? NoticeTone.ok
                  : d == DeviceState.disconnected
                  ? NoticeTone.warn
                  : NoticeTone.err,
              icon: ready
                  ? ApIcons.shield
                  : d == DeviceState.disconnected
                  ? ApIcons.usb
                  : ApIcons.alert,
              title: ready
                  ? c.t('dev_ready')
                  : c.t(
                      d == DeviceState.disconnected
                          ? 'dev_off_t'
                          : 'dev_perm_t',
                    ),
              child: Text(
                ready
                    ? c.both(
                        'L1 RD fingerprint scanner (demo) · RD Service running · checked just now',
                        'L1 RD फ़िंगरप्रिंट स्कैनर (डेमो) · RD Service चालू · आखिरी जाँच अभी',
                      )
                    : c.t(
                        d == DeviceState.disconnected
                            ? 'dev_off_p'
                            : 'dev_perm_p',
                      ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, box) {
                if (box.maxWidth < 700) {
                  return Column(
                    children: [scanner, const SizedBox(height: 16), guide],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: scanner),
                    const SizedBox(width: 16),
                    Expanded(child: guide),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 10),
              child: Text(c.t('trouble'), style: display(16, color: p.ink)),
            ),
            SupportAccordion(items: faqs),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ApButton(
                  label: c.both('Request repair', 'मरम्मत अनुरोध'),
                  kind: ApButtonKind.outline,
                  icon: ApIcons.settings,
                  onPressed: () => c.deviceRequest('repair'),
                ),
                ApButton(
                  label: c.both('Get a device', 'नया डिवाइस'),
                  kind: ApButtonKind.ghost,
                  icon: ApIcons.device,
                  onPressed: () => c.deviceRequest('order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
