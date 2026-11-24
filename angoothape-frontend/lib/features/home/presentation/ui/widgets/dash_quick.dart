import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class DashQuick extends StatelessWidget {
  const DashQuick({super.key, required this.c, required this.p, required this.devKey});
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
