import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../controllers/join_controller.dart';

class RoleStep extends StatelessWidget {
  const RoleStep({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final JoinController flow = c;
    final p = ap(context);
    final roles = [
      (
        'retailer',
        ApIcons.store,
        c.both('Retailer / Franchisee', 'रिटेलर / फ़्रैंचाइज़ी'),
        c.both(
          'Serve customers at your shop: AEPS cash withdrawal, balance enquiry and more.',
          'अपनी दुकान पर ग्राहकों को सेवा दें: AEPS नकद निकासी, बैलेंस जाँच और बहुत कुछ।',
        ),
      ),
      (
        'distributor',
        ApIcons.users,
        c.both('Distributor', 'डिस्ट्रीब्यूटर'),
        c.both(
          'Onboard and support retailers in your area, approve their applications and track performance.',
          'अपने क्षेत्र के रिटेलर जोड़ें, उनके आवेदन स्वीकृत करें और प्रदर्शन देखें।',
        ),
      ),
      (
        'super',
        ApIcons.network,
        c.both('Super Distributor', 'सुपर डिस्ट्रीब्यूटर'),
        c.both(
          'Manage distributors across districts or a state and oversee the network.',
          'ज़िलों या राज्य में डिस्ट्रीब्यूटर प्रबंधित करें और नेटवर्क की निगरानी करें।',
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.both(
            'How do you want to join?',
            'आप किस रूप में जुड़ना चाहते हैं?',
          ),
          style: display(22, color: p.ink),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              c.both(
                'Permissions and approval rules shown here are proposals.',
                'अनुमतियाँ और स्वीकृति नियम प्रस्तावित हैं।',
              ),
              style: body(13, color: p.ink2),
            ),
            const AssumeTag(),
          ],
        ),
        const SizedBox(height: 14),
        for (final r in roles) ...[
          RoleCard(
            selected: flow.join.role == r.$1,
            icon: r.$2,
            title: r.$3,
            blurb: r.$4,
            onTap: () => flow.setRole(r.$1),
          ),
          const SizedBox(height: 10),
        ],
        Notice(
          tone: NoticeTone.info,
          child: Text(
            c.both(
              'Retailers are approved by their distributor; distributors and super distributors by the angoothaPe operations team.',
              'रिटेलर को उनका डिस्ट्रीब्यूटर स्वीकृत करता है; डिस्ट्रीब्यूटर और सुपर डिस्ट्रीब्यूटर को angoothaPe ऑपरेशंस टीम।',
            ),
          ),
        ),
        const SizedBox(height: 16),
        ApButton(
          label: c.t('cont'),
          expand: true,
          onPressed: () => flow.joinNext(const {}),
        ),
      ],
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({super.key, 
    required this.selected,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String blurb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Material(
      color: selected ? p.primarySoft : p.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? p.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: display(16, color: p.ink)),
                    const SizedBox(height: 4),
                    Text(blurb, style: body(13, color: p.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
