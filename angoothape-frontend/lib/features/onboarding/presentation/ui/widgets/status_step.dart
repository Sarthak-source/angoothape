import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../controllers/join_controller.dart';

class JoinStatusStep extends StatelessWidget {
  const JoinStatusStep({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final JoinController flow = c;
    final p = ap(context);
    final approved = c.join.approved;
    final approver = c.join.role == 'retailer'
        ? c.both(
            'Approval by your distributor',
            'डिस्ट्रीब्यूटर द्वारा स्वीकृति',
          )
        : c.both(
            'Approval by angoothaPe operations',
            'angoothaPe ऑपरेशंस द्वारा स्वीकृति',
          );
    final role = switch (c.join.role) {
      'distributor' => c.both('Distributor', 'डिस्ट्रीब्यूटर'),
      'super' => c.both('Super Distributor', 'सुपर डिस्ट्रीब्यूटर'),
      _ => c.both('Retailer / Franchisee', 'रिटेलर / फ़्रैंचाइज़ी'),
    };
    Widget line(IconData icon, Color color, String title, String sub) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: body(14, weight: FontWeight.w600)),
                    Text(sub, style: body(12.5, color: p.ink2)),
                  ],
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        Icon(
          approved ? ApIcons.check : ApIcons.clock,
          size: 72,
          color: approved ? p.success : p.warning,
        ),
        const SizedBox(height: 8),
        Text(
          approved
              ? c.both('Your account is active', 'आपका खाता सक्रिय है')
              : c.both('Application submitted', 'आवेदन जमा हो गया'),
          style: display(24, color: p.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '${c.both('Application no.', 'आवेदन संख्या')} ${c.join.applicationId ?? '—'} · $role',
          style: body(13, color: p.ink2),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: cardBox(p),
          child: Column(
            children: [
              line(
                ApIcons.check,
                p.success,
                c.both('Application submitted', 'आवेदन जमा'),
                fmtDt(DateTime.now(), c.lang),
              ),
              line(
                approved ? ApIcons.check : ApIcons.clock,
                approved ? p.success : p.warning,
                c.both('Document check', 'दस्तावेज़ जाँच'),
                approved
                    ? c.both('Completed', 'पूरा')
                    : c.both(
                        'Usually 1–2 working days (example)',
                        'आमतौर पर 1–2 कार्यदिवस (उदाहरण)',
                      ),
              ),
              line(
                approved ? ApIcons.check : Icons.radio_button_unchecked,
                approved ? p.success : p.ink3,
                approver,
                approved
                    ? c.both('Approved', 'स्वीकृत')
                    : c.both('Waiting', 'प्रतीक्षा में'),
              ),
              line(
                approved ? ApIcons.check : Icons.radio_button_unchecked,
                approved ? p.success : p.ink3,
                c.both(
                  'Account activated, device setup',
                  'खाता सक्रिय, डिवाइस सेटअप',
                ),
                approved ? c.both('Log in to start', 'लॉग इन करें') : '—',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Notice(
          tone: NoticeTone.info,
          child: Text(
            c.both(
              'We will SMS you when the status changes. If more documents are needed, you will see it here.',
              'स्थिति बदलने पर हम SMS भेजेंगे। अतिरिक्त दस्तावेज़ माँगे जाएँ तो यहाँ दिखेगा।',
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (approved)
          ApButton(
            label: c.t('login'),
            expand: true,
            onPressed: () => c.go('login'),
          )
        else
          ApButton(
            label: c.both(
              'Demo: simulate approval',
              'डेमो: स्वीकृति सिम्युलेट करें',
            ),
            kind: ApButtonKind.soft,
            icon: ApIcons.sparkle,
            expand: true,
            onPressed: flow.simulateApproval,
          ),
      ],
    );
  }
}
