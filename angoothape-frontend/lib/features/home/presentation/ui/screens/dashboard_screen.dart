import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../controllers/home_controller.dart';

import '../widgets/dash_hero.dart';
import '../widgets/dash_quick.dart';
import '../widgets/dash_recent.dart';
import '../widgets/dash_soon.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    final w = c.data.wallet;
    final todays = home.todaysTx();
    final tVal = home.todayCashValue();
    final greet = home.greeting(hi: c.hi);
    final devKey = switch (c.scenario.device) {
      DeviceState.ready => 'dev_ready',
      DeviceState.disconnected => 'dev_off',
      DeviceState.permission => 'dev_perm',
    };
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greet,
                      style: body(13, weight: FontWeight.w500, color: p.ink2),
                    ),
                    Text(
                      c.data.retailer.name,
                      style: display(
                        30,
                        weight: FontWeight.w700,
                        color: p.ink,
                        letterSpacing: -0.9,
                      ),
                    ),
                    Text(
                      '${c.data.retailer.shop} · ${c.data.retailer.id}',
                      style: body(12.5, color: p.ink2),
                    ),
                  ],
                ),
              ),
              if (LayoutScope.of(context).isMobile)
                const DevicePill(compact: true),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final two = box.maxWidth >= 900;
              final hero = DashHero(
                c: c,
                p: p,
                balance: w.aeps,
                todayCount: todays.length,
                todayValue: tVal,
              );
              final quick = DashQuick(c: c, p: p, devKey: devKey);
              final recent = DashRecent(c: c, p: p);
              final soon = DashSoon(c: c, p: p);
              if (!two) {
                return Column(
                  children: [
                    hero,
                    const SizedBox(height: 16),
                    quick,
                    const SizedBox(height: 16),
                    recent,
                    const SizedBox(height: 16),
                    soon,
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 13, child: hero),
                      const SizedBox(width: 16),
                      Expanded(flex: 10, child: quick),
                    ],
                  ),
                  const SizedBox(height: 16),
                  recent,
                  const SizedBox(height: 16),
                  soon,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
