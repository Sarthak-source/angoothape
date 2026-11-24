import 'package:flutter/material.dart';

import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final moreOn = const {
      'more',
      'device',
      'help',
      'profile',
      'banks',
      'services',
      'help-new',
      'ticket',
    }.contains(c.route);
    String cur = c.route;
    if (cur == 'txn') cur = 'hist';
    Widget item(String route, IconData icon, String label, bool on) => Expanded(
      child: InkWell(
        onTap: () => c.nav(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: on
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(
                icon,
                color: on ? Colors.white : const Color(0xFFB4B2CC),
                size: 22,
              ),
            ),
            Text(
              label,
              style: body(
                11,
                weight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? Colors.white : const Color(0xFFB4B2CC),
              ),
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1944),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x6612102E),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  item('dash', ApIcons.home, c.t('nav_home'), cur == 'dash'),
                  item('hist', ApIcons.list, c.t('nav_hist'), cur == 'hist'),
                  const Expanded(child: SizedBox()),
                  item(
                    'wallet',
                    ApIcons.wallet,
                    c.t('nav_wallet'),
                    cur == 'wallet',
                  ),
                  item('more', ApIcons.menu, c.t('nav_more'), moreOn),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => c.nav('aeps'),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2662F),
                    shape: BoxShape.circle,
                    border: Border.all(color: ap(context).canvas, width: 5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x80F2662F),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    ApIcons.fingerprint,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
