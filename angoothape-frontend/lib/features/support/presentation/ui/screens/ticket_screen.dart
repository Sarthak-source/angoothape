import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final k = c.data.ticketById[c.params['id']];
    if (k == null) return const SizedBox.shrink();
    final fresh = c.params['fresh'] == '1';
    return ScreenPad(
      child: Column(
        children: [
          Icon(ApIcons.check, size: 72, color: p.success),
          Text(
            fresh ? c.t('req_created') : k.id,
            style: display(24, color: p.ink),
            textAlign: TextAlign.center,
          ),
          Text('${k.id} · ${k.status}', style: body(13, color: p.ink2)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardBox(p),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c.t('issue_type')}: ${k.type}',
                  style: body(14, weight: FontWeight.w600),
                ),
                if (k.ref != null)
                  TextButton(
                    onPressed: () => c.go('txn', params: {'ref': k.ref!}),
                    child: Text(k.ref!),
                  ),
                Text(fmtDt(k.t, c.lang), style: body(12, color: p.ink2)),
                const SizedBox(height: 8),
                Text('“${k.msg}”', style: body(14, color: p.ink2)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Notice(
            tone: NoticeTone.info,
            child: Text(
              c.both(
                'You will get updates by SMS and in My requests. Expected response within 24 hours (example).',
                'अपडेट SMS और “मेरे अनुरोध” में मिलेगा। अपेक्षित जवाब 24 घंटे में (उदाहरण)।',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ApButton(
            label: c.t('my_req'),
            expand: true,
            onPressed: () {
              c.setHelpTab('req');
              c.go('help');
            },
          ),
          const SizedBox(height: 8),
          ApButton(
            label: c.t('nav_home'),
            kind: ApButtonKind.outline,
            expand: true,
            onPressed: () => c.go('dash'),
          ),
        ],
      ),
    );
  }
}
