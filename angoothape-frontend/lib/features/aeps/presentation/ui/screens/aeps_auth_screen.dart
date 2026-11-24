import 'package:flutter/material.dart';

import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/aeps_scanner.dart';

class AepsAuth extends StatelessWidget {
  const AepsAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final b = bankById(a.bank);
    final wide = LayoutScope.of(context).twoColumnForms;
    final review = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.t(a.service), style: body(12.5, color: p.ink2)),
                    if (a.service == 'cw')
                      AmountText(int.tryParse(a.amount) ?? 0, size: 32, dec: 0)
                    else
                      Text(b?.name ?? '', style: display(18, color: p.ink)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: c.editAeps,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 40),
                ),
                icon: const Icon(ApIcons.edit, size: 18),
                label: Text(c.t('edit')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _kv(p, c.t('bank'), b?.name ?? '—'),
          _kv(
            p,
            a.idType == 'aadhaar' ? c.t('masked_id') : 'VID',
            a.aadhaar.length >= 4
                ? 'XXXX XXXX ${a.aadhaar.substring(a.aadhaar.length - 4)}'
                : '—',
          ),
          _kv(
            p,
            c.t('mobile'),
            a.mobile.length == 10 ? maskMobile(a.mobile.substring(6)) : '—',
          ),
        ],
      ),
    );
    final consentErr = a.consentTried && !a.consent;
    final consent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p).copyWith(
        color: consentErr ? p.errorBg : p.card,
        border: consentErr ? Border.all(color: p.error) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.t('consent_t'),
            style: body(14, weight: FontWeight.w600, color: p.ink),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => c.setConsent(!a.consent),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: a.consent,
                    onChanged: (v) => c.setConsent(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(c.t('consent'), style: body(14, color: p.ink)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(c.t('consent_more'), style: body(12.5, color: p.ink2)),
              const AssumeTag(),
            ],
          ),
          if (consentErr) ...[
            const SizedBox(height: 6),
            HelpText(c.t('e_consent'), error: true),
          ],
        ],
      ),
    );
    final scanner = const AepsScanner();
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [review, const SizedBox(height: 16), consent],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: scanner),
        ],
      );
    }
    return Column(
      children: [
        review,
        const SizedBox(height: 16),
        consent,
        const SizedBox(height: 16),
        scanner,
      ],
    );
  }

  Widget _kv(ApPalette p, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: body(13.5, color: p.ink2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(13.5, weight: FontWeight.w600, color: p.ink),
          ),
        ),
      ],
    ),
  );
}

const double _pad = 22;
