import 'package:flutter/material.dart';

import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../controllers/home_controller.dart';
import '../../../../session/domain/entities/session_entities.dart';

class BanksScreen extends StatelessWidget {
  const BanksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.t('banks_t'), style: display(22, color: p.ink)),
              ),
              ApButton(
                label: c.t('add_bank'),
                small: true,
                icon: ApIcons.plus,
                onPressed: home.openAddBank,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: cardBox(p),
            child: Column(
              children: [
                for (final a in c.data.accounts)
                  Builder(
                    builder: (_) {
                      final b = bankById(a.bank);
                      final (bg, fg, icon, label) = switch (a.status) {
                        'active' => (
                          p.successBg,
                          p.success,
                          ApIcons.check,
                          c.both('Active', 'सक्रिय'),
                        ),
                        'pending' => (
                          p.warningBg,
                          p.warning,
                          ApIcons.clock,
                          c.both('Verifying', 'सत्यापन जारी'),
                        ),
                        _ => (
                          p.errorBg,
                          p.error,
                          ApIcons.close,
                          c.both('Rejected', 'अस्वीकृत'),
                        ),
                      };
                      return ApListRow(
                        leading: b == null
                            ? const SizedBox(width: 42)
                            : BankMono(b, size: 42),
                        title: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${b?.name ?? ''} ••${a.last4}'),
                            if (a.primary)
                              ApBadge(
                                small: true,
                                label: c.both('Primary', 'प्राथमिक'),
                                bg: p.primarySoft,
                                fg: p.primary,
                              ),
                          ],
                        ),
                        subtitle:
                            '${a.holder} · ${a.ifsc}${a.note != null ? ' · ${a.note}' : ''}',
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ApBadge(label: label, icon: icon, bg: bg, fg: fg),
                            if (a.status == 'rejected')
                              TextButton(
                                onPressed: home.openAddBank,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  textStyle: body(
                                    12.5,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                child: Text(c.both('Add again', 'फिर जोड़ें')),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                c.both(
                  'Verified by penny-drop (simulated). Only accounts in your or your shop’s name.',
                  'सत्यापन पेनी-ड्रॉप से (सिम्युलेटेड)। केवल अपने नाम या दुकान के नाम का खाता।',
                ),
                style: body(12.5, color: p.ink2),
              ),
              const AssumeTag(),
            ],
          ),
        ],
      ),
    );
  }
}
