import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('profile_t'), style: display(22, color: p.ink)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardBox(p),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ApPalette.indigo,
                  child: Text(
                    c.data.retailer.initials,
                    style: body(
                      16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.data.retailer.name, style: display(18, color: p.ink)),
                      Text(
                        '${c.data.retailer.shop} · ${c.data.retailer.id}',
                        style: body(12.5, color: p.ink2),
                      ),
                      Text(c.data.retailer.city, style: body(12.5, color: p.ink2)),
                    ],
                  ),
                ),
                StatusBadge(TxStatus.success),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${c.both('Role', 'भूमिका')}: ${c.data.retailer.role}',
            style: body(14),
          ),
          Text(
            '${c.both('Distributor', 'डिस्ट्रीब्यूटर')}: ${c.data.retailer.distributor}',
            style: body(14, color: p.ink2),
          ),
          Text(
            '${c.t('mobile')}: ${c.data.retailer.mobile}',
            style: body(14, color: p.ink2),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(ApIcons.edit, color: p.primary),
            title: Text(
              c.both('Edit profile', 'प्रोफ़ाइल बदलें'),
              style: body(14, weight: FontWeight.w700),
            ),
            trailing: const Icon(ApIcons.chevR),
            onTap: c.openProfile,
          ),
          _row(
            p,
            ApIcons.globe,
            c.t('language'),
            c.lang == 'en' ? 'English' : 'हिन्दी',
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'hi', label: Text('हिं')),
              ],
              selected: {c.lang},
              onSelectionChanged: (s) => c.setLang(s.first),
            ),
          ),
          _row(
            p,
            ApIcons.keyboard,
            c.t('text_size'),
            c.both('For easier reading', 'पढ़ने में आसानी के लिए'),
            trailing: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1, label: Text('A')),
                ButtonSegment(value: 1.15, label: Text('A+')),
              ],
              selected: {c.scale},
              onSelectionChanged: (s) => c.setScale(s.first),
            ),
          ),
          SwitchListTile(
            value: c.dark,
            onChanged: (_) => c.toggleDark(),
            title: Text(
              c.t('dark_prev'),
              style: body(14, weight: FontWeight.w600),
            ),
            subtitle: Text(
              c.both(
                'Tokens ready; light mode is the primary design',
                'टोकन तैयार; मुख्य डिज़ाइन लाइट मोड है',
              ),
              style: body(12, color: p.ink2),
            ),
          ),
          ListTile(
            leading: Icon(ApIcons.sparkle, color: p.primary),
            title: Text(
              c.both('Demo scenarios', 'डेमो स्थितियाँ'),
              style: body(14, weight: FontWeight.w700),
            ),
            subtitle: Text(
              c.both(
                'Next outcome, device and fingerprint capture',
                'अगला परिणाम, डिवाइस और फ़िंगरप्रिंट',
              ),
              style: body(12, color: p.ink2),
            ),
            trailing: const Icon(ApIcons.chevR),
            onTap: c.openScenarios,
          ),
          ListTile(
            leading: const Icon(ApIcons.bank),
            title: Text(c.t('banks_t')),
            trailing: const Icon(ApIcons.chevR),
            onTap: () => c.nav('banks'),
          ),
          ListTile(
            leading: const Icon(ApIcons.fingerprint),
            title: Text(c.t('device_t')),
            trailing: const Icon(ApIcons.chevR),
            onTap: () => c.nav('device'),
          ),
          ListTile(
            leading: const Icon(ApIcons.lock),
            title: Text(c.both('Password & security', 'पासवर्ड और सुरक्षा')),
            onTap: c.openPassword,
          ),
          ListTile(
            leading: Icon(ApIcons.refresh, color: p.warning),
            title: Text(c.t('reset_demo')),
            onTap: c.resetDemo,
          ),
          ListTile(
            leading: Icon(ApIcons.logout, color: p.error),
            title: Text(
              c.t('logout'),
              style: body(14, weight: FontWeight.w700, color: p.error),
            ),
            onTap: c.logout,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              c.both('angoothaPe · live session data', 'angoothaPe · लाइव सेशन डेटा'),
              style: body(12, color: p.ink3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    ApPalette p,
    IconData icon,
    String title,
    String sub, {
    required Widget trailing,
  }) => ListTile(
    leading: Icon(icon, color: p.primary),
    title: Text(title, style: body(14, weight: FontWeight.w600)),
    subtitle: Text(sub, style: body(12, color: p.ink2)),
    trailing: trailing,
  );
}
