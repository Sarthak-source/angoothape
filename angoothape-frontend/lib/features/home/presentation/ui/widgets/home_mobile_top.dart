import 'package:flutter/material.dart';

import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

class HomeMobileTop extends StatelessWidget {
  const HomeMobileTop({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    if (c.route == 'dash') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(
          children: [
            const Wordmark(height: 32),
            const Spacer(),
            _round(p, ApIcons.globe, c.toggleLang),
            const SizedBox(width: 8),
            _round(p, ApIcons.headset, () => c.nav('help')),
          ],
        ),
      );
    }
    final titles = {
      'aeps': c.t('aeps_title'),
      'hist': c.t('nav_hist'),
      'txn': c.t('txn_details'),
      'wallet': c.t('wallet_t'),
      'banks': c.t('banks_t'),
      'device': c.t('device_t'),
      'help': c.t('help_t'),
      'help-new': c.t('new_req'),
      'ticket': c.t('help_t'),
      'profile': c.t('profile_t'),
      'more': c.t('nav_more'),
      'services': c.t('nav_services'),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          if (c.showBack())
            IconButton(onPressed: c.back, icon: const Icon(ApIcons.back))
          else
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              titles[c.route] ?? '',
              style: display(18, color: p.ink),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _round(p, ApIcons.headset, () => c.nav('help')),
        ],
      ),
    );
  }

  Widget _round(ApPalette p, IconData icon, VoidCallback onTap) => Material(
    color: p.card,
    shape: const CircleBorder(),
    elevation: 1,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(width: 44, height: 44, child: Icon(icon, color: p.ink)),
    ),
  );
}
