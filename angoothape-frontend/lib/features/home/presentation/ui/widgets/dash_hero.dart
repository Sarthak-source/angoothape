import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

import 'dash_glow.dart';

class DashHero extends StatelessWidget {
  const DashHero({super.key, 
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
            child: DashGlow(size: 340, color: Color(0xFFF2662F), alpha: 0.55),
          ),
          const Positioned(
            left: -120,
            bottom: -170,
            child: DashGlow(size: 300, color: Color(0xFFA5A1F0), alpha: 0.45),
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
