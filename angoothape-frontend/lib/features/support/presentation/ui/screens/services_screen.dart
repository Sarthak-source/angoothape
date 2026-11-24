import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final items = futureServices(c.lang);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('nav_services'), style: display(22, color: p.ink)),
          Text(
            c.both(
              'AEPS comes first. Other services are future modules.',
              'पहले AEPS पर ध्यान। बाकी सेवाएँ भविष्य के मॉड्यूल हैं।',
            ),
            style: body(13, color: p.ink2),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              _tile(
                p,
                ApIcons.fingerprint,
                'AEPS',
                live: c.both('Live', 'उपलब्ध'),
                onTap: () => c.startAeps('cw'),
              ),
              for (final s in items) _tile(p, ApIcons.grid, s.$2, soon: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(
    ApPalette p,
    IconData icon,
    String label, {
    String? live,
    bool soon = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: live != null ? const Color(0xFFF2662F) : p.ink3,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: body(13, weight: FontWeight.w600),
              ),
              if (live != null)
                Text(
                  live,
                  style: body(11, weight: FontWeight.w700, color: p.success),
                ),
              if (soon) const SoonTag(),
            ],
          ),
        ),
      ),
    );
  }
}
