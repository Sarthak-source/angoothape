import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final list = faqs[c.lang] ?? faqs['en'] ?? const <(String, String)>[];
    final tks = [...c.data.tickets]..sort((a, b) => b.t.compareTo(a.t));
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.t('help_t'), style: display(22, color: p.ink)),
              ),
              ApButton(
                label: c.t('new_req'),
                icon: ApIcons.plus,
                onPressed: () => c.go('help-new'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardBox(p),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: p.accent,
                  child: const Icon(ApIcons.headset, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.t('helpline'),
                        style: body(14, weight: FontWeight.w700),
                      ),
                      Text(
                        c.both(
                          '1800 000 0000 · example number · 8am–10pm',
                          '1800 000 0000 · उदाहरण नंबर · 8am–10pm',
                        ),
                        style: body(12, color: p.ink2),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      copyText(context, '1800 000 0000', c.t('copied')),
                  icon: const Icon(ApIcons.copy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ApChip(
                label: c.t('faqs'),
                selected: c.helpTab == 'faq',
                onTap: () => c.setHelpTab('faq'),
              ),
              ApChip(
                label: '${c.t('my_req')} (${tks.length})',
                selected: c.helpTab == 'req',
                onTap: () => c.setHelpTab('req'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (c.helpTab == 'faq')
            for (final item in list)
              ExpansionTile(
                title: Text(item.$1, style: body(14, weight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(item.$2, style: body(14, color: p.ink2)),
                  ),
                ],
              )
          else
            Container(
              decoration: cardBox(p),
              child: Column(
                children: [
                  for (final k in tks)
                    ListTile(
                      leading: Icon(ApIcons.headset, color: p.primary),
                      title: Text(
                        '${k.id} · ${k.type}',
                        style: body(14, weight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${k.ref ?? ''} · ${fmtDt(k.t, c.lang)}',
                        style: body(12, color: p.ink2),
                      ),
                      trailing: Text(
                        k.status,
                        style: body(
                          12,
                          weight: FontWeight.w700,
                          color: p.primary,
                        ),
                      ),
                      onTap: () => c.go('ticket', params: {'id': k.id}),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
