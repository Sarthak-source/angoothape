import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../controllers/home_controller.dart';
import '../../../../session/domain/entities/session_entities.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final HomeController home = c;
    final p = ap(context);
    final w = c.data.wallet;
    final items = [...c.data.settlements]..sort((a, b) => b.t.compareTo(a.t));
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('wallet_t'), style: display(22, color: p.ink)),
          const SizedBox(height: 4),
          Text(
            c.both(
              'Each balance is shown separately so they are never confused.',
              'तीनों बैलेंस अलग रखे गए हैं ताकि कोई भ्रम न हो।',
            ),
            style: body(13, color: p.ink2),
          ),
          const SizedBox(height: _gap),
          LayoutBuilder(
            builder: (context, box) {
              final row = box.maxWidth >= 720;
              final cards = [
                _bal(
                  p,
                  c.t('main_wallet'),
                  w.main,
                  c.t('main_wallet_h'),
                  ApButton(
                    label: c.both('Add money', 'पैसे जोड़ें'),
                    kind: ApButtonKind.outline,
                    small: true,
                    icon: ApIcons.plus,
                    onPressed: home.openTopup,
                  ),
                  fill: row,
                  icon: ApIcons.wallet,
                ),
                _bal(
                  p,
                  c.t('aeps_bal'),
                  w.aeps,
                  c.t('aeps_bal_h'),
                  ApButton(
                    label: c.t('move_bank'),
                    small: true,
                    icon: ApIcons.bank,
                    onPressed: home.openSettle,
                  ),
                  fill: row,
                  icon: ApIcons.fingerprintSimple,
                ),
                _bal(
                  p,
                  c.t('earnings'),
                  w.earn,
                  c.t('earnings_h'),
                  null,
                  tag: c.t('sample'),
                  fill: row,
                  icon: ApIcons.sparkle,
                ),
              ];
              if (row) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: _gap),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: _gap),
                    cards[i],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: _gap),
          Notice(
            tone: NoticeTone.info,
            child: Text(
              c.both(
                "A customer's bank balance never appears in your wallet. It is shown only on that transaction's result and receipt.",
                'ग्राहक का बैंक बैलेंस कभी आपके वॉलेट में नहीं दिखता। वह केवल लेन-देन परिणाम और रसीद पर दिखता है।',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(c.t('settlements'), style: display(16, color: p.ink)),
              const SizedBox(width: 8),
              const AssumeTag(),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: cardBox(p),
            child: Column(
              children: [
                for (final s in items)
                  Builder(
                    builder: (_) {
                      final (bg, fg, icon, label) = switch (s.status) {
                        'reversed' => (
                          p.errorBg,
                          p.error,
                          ApIcons.refresh,
                          c.both('Returned', 'वापस आया'),
                        ),
                        'processing' => (
                          p.warningBg,
                          p.warning,
                          ApIcons.clock,
                          c.both('Processing', 'प्रोसेसिंग'),
                        ),
                        _ => (
                          p.successBg,
                          p.success,
                          ApIcons.check,
                          c.both('Settled', 'सेटल'),
                        ),
                      };
                      final last4 = c.data.last4ByBank[s.acct];
                      return ApListRow(
                        leading: ApListRow.tile(ApIcons.bank, bg, fg),
                        title: Text(
                          '${s.id} · ${bankById(s.acct)?.short ?? ''} ••${last4 ?? '—'}',
                        ),
                        subtitle:
                            '${fmtDt(s.t, c.lang)}${s.utr != null ? ' · UTR ${s.utr}' : ''}${s.note != null ? ' · ${s.note}' : ''}',
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AmountText(s.amt, size: 17, dec: 0),
                            const SizedBox(height: 4),
                            ApBadge(label: label, icon: icon, bg: bg, fg: fg),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: ApButton(
              kind: ApButtonKind.ghost,
              icon: ApIcons.bank,
              trailingIcon: ApIcons.chevR,
              label: c.t('banks_t'),
              onPressed: () => c.nav('banks'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bal(
    ApPalette p,
    String title,
    double value,
    String help,
    Widget? action, {
    String? tag,
    bool fill = false,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16, color: p.ink2),
              Text(title, style: body(13, color: p.ink2)),
              if (tag != null) AssumeTag(label: tag),
            ],
          ),
          const SizedBox(height: 6),
          AmountText(value, size: 26),
          const SizedBox(height: 4),
          Text(help, style: body(12.5, color: p.ink2)),
          if (action != null) ...[
            const SizedBox(height: 16),
            if (fill) const Spacer(),
            Align(alignment: Alignment.centerLeft, child: action),
          ],
        ],
      ),
    );
  }
}

const double _pad = 20;
const double _gap = 16;
