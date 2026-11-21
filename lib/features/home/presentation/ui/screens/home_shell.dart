import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aeps/presentation/ui/screens/aeps_screen.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_sheets.dart';
import '../../../../../core/widgets/app_widgets.dart';
import 'ledger_screen.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../session/presentation/providers/session_providers.dart';
import '../../../../support/presentation/ui/screens/support_screen.dart';
import 'dashboard_screen.dart';
import '../../../../../core/theme/ap_icons.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final profile = const LayoutService().resolve(constraints.maxWidth);
        final p = ap(context);
        return LayoutScope(
          profile: profile,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (c.sheet != null) {
                c.closeSheet();
                return;
              }
              c.back();
            },
            child: Scaffold(
              backgroundColor: p.canvas,
              body: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const _Ribbon(),
                        Expanded(
                          child: profile.showSidebar
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    12,
                                  ),
                                  child: Row(
                                    children: [
                                      _Side(expanded: profile.sidebarExpanded),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const _DeskHead(),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: _Body(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    const _MobileTop(),
                                    const Expanded(child: _Body()),
                                    const _BottomNav(),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const AppSheet(),
                    _SyncViewport(profile: profile),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SyncViewport extends ConsumerWidget {
  const _SyncViewport({required this.profile});
  final LayoutProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(viewportWidthProvider.notifier).update(profile.width);
      c.bindLayout(profile);
    });
    return const SizedBox.shrink();
  }
}

class _Body extends StatelessWidget {
  const _Body();
  @override
  Widget build(BuildContext context) {
    final route = AppScope.of(context).route;
    return switch (route) {
      'aeps' => const AepsScreen(),
      'hist' => const HistoryScreen(),
      'txn' => const TxnScreen(),
      'wallet' => const WalletScreen(),
      'banks' => const BanksScreen(),
      'device' => const DeviceScreen(),
      'help' => const HelpScreen(),
      'help-new' => const HelpNewScreen(),
      'ticket' => const TicketScreen(),
      'profile' => const ProfileScreen(),
      'more' => const MoreScreen(),
      'services' => const ServicesScreen(),
      _ => const DashboardScreen(),
    };
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      width: double.infinity,
      color: const Color(0xFF1B1944),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: c.t('demo'),
              style: body(
                11,
                weight: FontWeight.w800,
                color: const Color(0xFFFBA078),
              ),
            ),
            TextSpan(
              text: '  ·  ${c.t('ribbon')}',
              style: body(
                11,
                weight: FontWeight.w600,
                color: const Color(0xFFE2E1F5),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MobileTop extends StatelessWidget {
  const _MobileTop();
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

class _DeskHead extends StatelessWidget {
  const _DeskHead();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final w = c.data.wallet;
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: cardBox(p, radius: 24),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF403C8C), ApPalette.indigo],
              ),
            ),
            child: Text(
              'RS',
              style: body(13, weight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Retailer.shop,
                style: body(14, weight: FontWeight.w700, color: p.ink),
              ),
              Text(
                '${Retailer.id} · ${c.both('Retailer', 'रिटेलर')}',
                style: body(12.5, color: p.ink2),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _chip(p, c.t('main_wallet'), inr(w.main)),
                  const SizedBox(width: 6),
                  _chip(p, c.t('aeps_bal'), inr(w.aeps)),
                  const SizedBox(width: 14),
                  const DevicePill(compact: true),
                  const SizedBox(width: 14),
                  ApButton(
                    small: true,
                    kind: ApButtonKind.ghost,
                    icon: ApIcons.globe,
                    label: c.lang == 'hi' ? 'English' : 'हिन्दी',
                    onPressed: c.toggleLang,
                  ),
                  const SizedBox(width: 14),
                  ApButton(
                    small: true,
                    kind: ApButtonKind.soft,
                    icon: ApIcons.headset,
                    label: c.t('nav_help'),
                    onPressed: () => c.nav('help'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(ApPalette p, String k, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: p.canvas,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: body(10.5, color: p.ink2, height: 1.2)),
        Text(
          v,
          style: display(14, weight: FontWeight.w700, color: p.ink),
        ),
      ],
    ),
  );
}

class _Side extends StatelessWidget {
  const _Side({required this.expanded});
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();
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
