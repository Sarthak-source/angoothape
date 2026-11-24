import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_sheets.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/providers/session_providers.dart';
import '../../../../aeps/presentation/ui/screens/aeps_screen.dart';
import '../../../../support/presentation/ui/screens/device_screen.dart';
import '../../../../support/presentation/ui/screens/help_new_screen.dart';
import '../../../../support/presentation/ui/screens/help_screen.dart';
import '../../../../support/presentation/ui/screens/more_screen.dart';
import '../../../../support/presentation/ui/screens/profile_screen.dart';
import '../../../../support/presentation/ui/screens/services_screen.dart';
import '../../../../support/presentation/ui/screens/ticket_screen.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_desk_head.dart';
import '../widgets/home_mobile_top.dart';
import '../widgets/home_side_nav.dart';
import '../widgets/home_demo_ribbon.dart';
import 'banks_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'txn_screen.dart';
import 'wallet_screen.dart';

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
                        const DemoRibbon(),
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
                                      HomeSideNav(expanded: profile.sidebarExpanded),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const HomeDeskHead(),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: HomeBody(),
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
                                    const HomeMobileTop(),
                                    const Expanded(child: HomeBody()),
                                    const HomeBottomNav(),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const AppSheet(),
                    HomeSyncViewport(profile: profile),
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

class HomeSyncViewport extends ConsumerWidget {
  const HomeSyncViewport({super.key, required this.profile});
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

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});
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
