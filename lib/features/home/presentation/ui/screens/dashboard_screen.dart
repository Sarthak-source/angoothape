import 'package:flutter/material.dart';

import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final w = c.data.wallet;
    final now = DateTime.now();
    final todays = c.data.tx
        .where(
          (x) =>
              x.t.year == now.year &&
              x.t.month == now.month &&
              x.t.day == now.day,
        )
        .toList();
    final tVal = todays
        .where((x) => x.status == TxStatus.success && x.svc == 'cw')
        .fold<int>(0, (a, x) => a + x.amt);
    final hr = now.hour;
    final greet = c.hi
        ? 'नमस्ते'
        : hr < 12
        ? 'Good morning'
        : hr < 17
        ? 'Good afternoon'
        : 'Good evening';
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
                      Retailer.name,
                      style: display(
                        30,
                        weight: FontWeight.w700,
                        color: p.ink,
                        letterSpacing: -0.9,
                      ),
                    ),
                    Text(
                      '${Retailer.shop} · ${Retailer.id}',
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
              final hero = _Hero(
                c: c,
                p: p,
                balance: w.aeps,
                todayCount: todays.length,
                todayValue: tVal,
              );
              final quick = _Quick(c: c, p: p, devKey: devKey);
              final recent = _Recent(c: c, p: p);
              final soon = _Soon(c: c, p: p);
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.c,
    required this.p,
    required this.balance,
    required this.todayCount,
    required this.todayValue,
  });
  final AppController c;
  final ApPalette p;
  final double balance;
  final int todayCount;
  final int todayValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApPalette.indigo900,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB31B1944),
            blurRadius: 50,
            spreadRadius: -22,
            offset: Offset(0, 24),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -140,
            top: -150,
            child: _Glow(size: 340, color: Color(0xFFF2662F), alpha: 0.55),
          ),
          const Positioned(
            left: -120,
            bottom: -170,
            child: _Glow(size: 300, color: Color(0xFFA5A1F0), alpha: 0.45),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.t('aeps_bal'),
                        style: body(
                          13,
                          weight: FontWeight.w500,
                          color: const Color(0xFFC6C4EC),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${c.t('today_sum')} · $todayCount ${c.t('txns')} · ${inr(todayValue, dec: 0)}',
                        style: body(12, color: const Color(0xFFE2E1F5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AmountText(balance, size: 46, color: Colors.white),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _mini(c.t('main_wallet'), inr(c.data.wallet.main)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _mini(
                        '${c.t('earnings')} · ${c.t('sample')}',
                        inr(c.data.wallet.earn),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xD9F2662F),
                        blurRadius: 30,
                        spreadRadius: -12,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Material(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(99),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99),
                      hoverColor: ApPalette.orange600,
                      onTap: () => c.startAeps('cw'),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 72),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  ApIcons.fingerprint,
                                  color: ApPalette.orange700,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  c.t('start_aeps'),
                                  style: display(
                                    18,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Icon(
                                ApIcons.chevR,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: body(12, color: const Color(0xFFC6C4EC))),
        const SizedBox(height: 2),
        Text(
          value,
          style: display(17, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _Quick extends StatelessWidget {
  const _Quick({required this.c, required this.p, required this.devKey});
  final AppController c;
  final ApPalette p;
  final String devKey;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        ApIcons.cash,
        p.accentSoft,
        p.accentText,
        c.t('cw'),
        c.t('with_fp'),
        () => c.startAeps('cw'),
      ),
      (
        ApIcons.scale,
        p.primarySoft,
        p.primary,
        c.t('be'),
        c.t('to_confirm'),
        () => c.startAeps('be'),
      ),
      (
        ApIcons.doc,
        p.primarySoft,
        p.primary,
        c.t('ms'),
        c.t('to_confirm'),
        () => c.startAeps('ms'),
      ),
      (
        ApIcons.device,
        c.scenario.device == DeviceState.ready ? p.successBg : p.warningBg,
        c.scenario.device == DeviceState.ready ? p.success : p.warning,
        c.t('nav_device'),
        c.t(devKey),
        () => c.nav('device'),
      ),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      children: [
        for (final t in tiles)
          DecoratedBox(
            decoration: cardBox(p, radius: 26),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(26),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: t.$6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: t.$2,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(t.$1, color: t.$3, size: 26),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.$4,
                            style: body(
                              15,
                              weight: FontWeight.w600,
                              color: p.ink,
                              height: 1.25,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t.$5,
                            style: body(
                              12,
                              weight: FontWeight.w500,
                              color: p.ink2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent({required this.c, required this.p});
  final AppController c;
  final ApPalette p;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardBox(p),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                c.t('recent'),
                style: display(18, weight: FontWeight.w700, color: p.ink),
              ),
              const Spacer(),
              ApButton(
                small: true,
                kind: ApButtonKind.soft,
                label: c.t('view_all'),
                trailingIcon: ApIcons.chevR,
                onPressed: () => c.nav('hist'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tx in c.data.tx.take(4))
            TxRow(
              tx: tx,
              onTap: () => c.go('txn', params: {'ref': tx.ref}),
            ),
        ],
      ),
    );
  }
}

const _soonIcons = <String, IconData>{
  'atm': ApIcons.atm,
  'send': ApIcons.sendMoney,
  'bill': ApIcons.bill,
  'recharge': ApIcons.mobileTx,
  'pan': ApIcons.pan,
  'shield': ApIcons.shield,
  'cash': ApIcons.cash,
  'topup': ApIcons.wallet,
};

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.alpha});
  final double size;
  final Color color;
  final double alpha;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.7],
      ),
    ),
  );
}

class _Soon extends StatelessWidget {
  const _Soon({required this.c, required this.p});
  final AppController c;
  final ApPalette p;
  @override
  Widget build(BuildContext context) {
    final items = futureServices(c.lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              c.t('other_svcs'),
              style: display(18, weight: FontWeight.w700, color: p.ink),
            ),
            const SizedBox(width: 10),
            const SoonTag(),
            const Spacer(),
            ApButton(
              small: true,
              kind: ApButtonKind.ghost,
              label: c.t('nav_services'),
              trailingIcon: ApIcons.chevR,
              onPressed: () => c.nav('services'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => Container(
              width: 118,
              padding: const EdgeInsets.all(14),
              decoration: cardBox(p, radius: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _soonIcons[items[i].$1] ?? ApIcons.grid,
                      color: p.ink2,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items[i].$2,
                    style: body(12.5, weight: FontWeight.w600, color: p.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
