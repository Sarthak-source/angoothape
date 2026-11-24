import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final dev = switch (c.scenario.device) {
      DeviceState.ready => c.t('dev_ready'),
      DeviceState.disconnected => c.t('dev_off'),
      DeviceState.permission => c.t('dev_perm'),
    };
    return ScreenPad(
      child: Column(
        children: [
          _item(
            context,
            ApIcons.device,
            c.t('nav_device'),
            dev,
            () => c.nav('device'),
          ),
          _item(
            context,
            ApIcons.bank,
            c.t('nav_banks'),
            c.both('Settlement accounts', 'सेटलमेंट खाते'),
            () => c.nav('banks'),
          ),
          _item(
            context,
            ApIcons.headset,
            c.t('nav_help'),
            c.both('FAQs, support requests', 'आम सवाल, अनुरोध'),
            () => c.nav('help'),
          ),
          _item(
            context,
            ApIcons.user,
            c.t('nav_profile'),
            c.both('Language, text size, log out', 'भाषा, अक्षर आकार, लॉग आउट'),
            () => c.nav('profile'),
          ),
          _item(
            context,
            ApIcons.grid,
            c.t('nav_services'),
            c.t('soon'),
            () => c.nav('services'),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    final p = ap(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: cardBox(p),
      child: ListTile(
        leading: Icon(icon, color: p.primary),
        title: Text(title, style: body(15, weight: FontWeight.w600)),
        subtitle: Text(sub, style: body(12, color: p.ink2)),
        trailing: const Icon(ApIcons.chevR),
        onTap: onTap,
      ),
    );
  }
}
