import 'package:flutter/material.dart';

import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';

class HomeSideNav extends StatelessWidget {
  const HomeSideNav({super.key, required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final items = <(String, IconData, String)>[
      ('dash', ApIcons.home, 'nav_home'),
      ('aeps', ApIcons.fingerprint, 'nav_aeps'),
      ('hist', ApIcons.list, 'nav_hist'),
      ('wallet', ApIcons.wallet, 'nav_wallet'),
      ('device', ApIcons.device, 'nav_device'),
      ('banks', ApIcons.bank, 'nav_banks'),
    ];
    final bottom = <(String, IconData, String)>[
      ('help', ApIcons.help, 'nav_help'),
      ('profile', ApIcons.user, 'nav_profile'),
    ];
    String cur = c.route;
    if (cur == 'txn') cur = 'hist';
    if (cur == 'help-new' || cur == 'ticket') cur = 'help';
    return Container(
      width: expanded ? 232 : 96,
      padding: expanded
          ? const EdgeInsets.symmetric(vertical: 20, horizontal: 14)
          : const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: ap(context).nav,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8012102E),
            blurRadius: 40,
            spreadRadius: -18,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 18),
            child: Align(
              alignment: expanded ? Alignment.centerLeft : Alignment.center,
              child: expanded
                  ? const Wordmark(height: 28, onDark: true)
                  : const LogoMark(size: 36, onDark: true),
            ),
          ),
          for (final i in items)
            _btn(c, i.$1, i.$2, c.t(i.$3), cur == i.$1, expanded),
          const Spacer(),
          for (final i in bottom)
            _btn(c, i.$1, i.$2, c.t(i.$3), cur == i.$1, expanded),
        ],
      ),
    );
  }

  Widget _btn(
    AppController c,
    String route,
    IconData icon,
    String label,
    bool on,
    bool expanded,
  ) {
    final fg = on ? Colors.white : const Color(0xFFB4B2CC);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: on ? const Color(0xFFF2662F) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: on
            ? const [
                BoxShadow(
                  color: Color(0xE6F2662F),
                  blurRadius: 22,
                  spreadRadius: -10,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          onTap: () => c.nav(route),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 14 : 4,
                vertical: expanded ? 0 : 8,
              ),
              child: expanded
                  ? Row(
                      children: [
                        Icon(icon, color: fg, size: 22),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            label,
                            style: body(
                              14,
                              weight: on ? FontWeight.w600 : FontWeight.w500,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(icon, color: fg, size: 22),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: body(10.5, weight: FontWeight.w500, color: fg),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
