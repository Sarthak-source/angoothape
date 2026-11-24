import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class AepsDetails extends StatefulWidget {
  const AepsDetails({super.key, this.stepper});

  /// When set, this form owns the scroll view and pins the primary button above the keyboard.
  final Widget? stepper;
  @override
  State<AepsDetails> createState() => _AepsDetailsState();
}

class _AepsDetailsState extends State<AepsDetails> {
  final mobile = TextEditingController();
  final idCtrl = TextEditingController();
  final amount = TextEditingController();
  String _extMobile = '\u0000';
  String _extId = '\u0000';
  String _extAmt = '\u0000';
  bool _extShow = false;
  String _extType = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final a = AppScope.of(context).aeps;
    if (a.mobile != _extMobile) {
      _extMobile = a.mobile;
      mobile.text = a.mobile;
    }
    if (a.aadhaar != _extId || a.showId != _extShow || a.idType != _extType) {
      _extId = a.aadhaar;
      _extShow = a.showId;
      _extType = a.idType;
      idCtrl.text = a.showId ? _group(a.aadhaar) : a.aadhaar;
    }
    if (a.amount != _extAmt) {
      _extAmt = a.amount;
      amount.text = a.amount;
    }
  }

  @override
  void dispose() {
    mobile.dispose();
    idCtrl.dispose();
    amount.dispose();
    super.dispose();
  }

  String _digits(String v) => v.replaceAll(RegExp(r'\D'), '');
  String _group(String d) =>
      d.replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (m) => '${m[1]} ');

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final layout = LayoutScope.of(context);
    final errors = a.tried
        ? c.aepsErrors(
            mobile: mobile.text,
            aadhaar: _digits(idCtrl.text),
            amount: amount.text,
          )
        : const <String, String>{};
    final bank = bankById(a.bank);
    final liveSummary = layout.aepsSummary == SummaryPlacement.liveSidePanel;
    final popularCount = layout.isMobile ? 4 : 8;
    final popular = popularBanks.take(popularCount).toList();
    void review() => c.reviewAeps(
      mobile: mobile.text,
      aadhaar: _digits(idCtrl.text),
      amount: amount.text,
    );

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(c.t('service')),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: cardBox(p, radius: 22),
          child: Row(
            children: [
              for (final s in ['cw', 'be', 'ms'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: a.service == s
                            ? const [
                                BoxShadow(
                                  color: Color(0xB3302D70),
                                  blurRadius: 20,
                                  spreadRadius: -10,
                                  offset: Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: a.service == s ? p.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () => c.setService(s),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 58),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    c.t(s),
                                    style: body(
                                      13.5,
                                      weight: FontWeight.w600,
                                      color: a.service == s
                                          ? p.onPrimary
                                          : p.ink2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (s != 'cw')
                                    Text(
                                      c.t('to_confirm'),
                                      style: body(
                                        10.5,
                                        weight: FontWeight.w500,
                                        color: a.service == s
                                            ? p.onPrimary.withValues(
                                                alpha: 0.85,
                                              )
                                            : p.ink3,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (a.service != 'cw') HelpText(c.t('partner_confirm')),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: liveSummary
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!liveSummary) const DevicePill(compact: true),
            ApButton(
              small: true,
              kind: ApButtonKind.ghost,
              icon: ApIcons.sparkle,
              label: c.t('fill_sample'),
              onPressed: c.fillSample,
            ),
          ],
        ),
        const SizedBox(height: 14),
        ApTextField(
          label: c.t('cust_mobile'),
          controller: mobile,
          digits: 10,
          keyboardType: layout.numericKeyboards
              ? TextInputType.number
              : TextInputType.text,
          textInputAction: layout.enterSubmits
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: layout.enterSubmits ? (_) => review() : null,
          error: errors['mobile'],
          help: errors.containsKey('mobile') ? null : c.t('cust_mobile_h'),
          onChanged: (v) {
            c.aeps.mobile = v;
            _extMobile = v;
            if (liveSummary) setState(() {});
          },
          prefix: _textPrefix(
            Text(
              '+91',
              style: body(16, weight: FontWeight.w600, color: p.ink2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                a.idType == 'aadhaar' ? c.t('aadhaar') : c.t('vid'),
                style: body(14, weight: FontWeight.w600, color: p.ink),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(99),
                boxShadow: cardShadow(),
              ),
              child: Row(
                children: [
                  _idType(c, p, 'aadhaar', 'Aadhaar'),
                  _idType(c, p, 'vid', 'VID', assume: true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ApTextField(
          controller: idCtrl,
          keyboardType: layout.numericKeyboards
              ? TextInputType.number
              : TextInputType.text,
          textInputAction: layout.enterSubmits
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: layout.enterSubmits ? (_) => review() : null,
          obscure: !a.showId,
          invalid: errors.containsKey('aadhaar'),
          padding: EdgeInsets.zero,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(ApIcons.id, color: p.ink3, size: 20),
          ),
          suffix: IconButton(
            onPressed: c.toggleShowId,
            icon: Icon(a.showId ? ApIcons.eyeOff : ApIcons.eye),
          ),
          onChanged: (v) {
            final d = _digits(v);
            final max = a.idType == 'aadhaar' ? 12 : 16;
            final cut = d.length > max ? d.substring(0, max) : d;
            c.aeps.aadhaar = cut;
            _extId = cut;
            if (liveSummary) setState(() {});
            if (a.showId) {
              final g = _group(cut);
              if (idCtrl.text != g) {
                idCtrl.value = TextEditingValue(
                  text: g,
                  selection: TextSelection.collapsed(offset: g.length),
                );
              }
            }
          },
        ),
        if (errors['aadhaar'] != null)
          HelpText(errors['aadhaar']!, error: true)
        else
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ApIcons.lock, size: 13, color: p.ink2),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${c.t('aadhaar_h')}${a.idType == 'vid' ? ' · VID support subject to integration confirmation.' : ''}',
                    style: body(12.5, color: p.ink2),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        FieldLabel(c.t('bank')),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: cardShadow(),
          ),
          child: Material(
            color: p.card,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: c.openBankSheet,
              child: Container(
                constraints: const BoxConstraints(minHeight: 66),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: errors.containsKey('bank')
                        ? p.error
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    if (bank != null)
                      BankMono(bank)
                    else
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(ApIcons.bank, size: 20, color: p.ink3),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bank?.name ?? c.t('choose_bank'),
                        style: body(
                          16,
                          weight: bank == null
                              ? FontWeight.w400
                              : FontWeight.w700,
                          color: bank == null ? p.ink3 : p.ink,
                        ),
                      ),
                    ),
                    Icon(ApIcons.chevD, size: 20, color: p.ink2),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 80,
          ),
          children: [
            for (final b in popular)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: cardShadow(),
                ),
                child: Material(
                  color: p.card,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => c.pickBank(b.id),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: a.bank == b.id
                              ? p.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BankMono(b, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            b.short,
                            style: body(11.5, weight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (errors['bank'] != null) HelpText(errors['bank']!, error: true),
        if (a.service == 'cw') ...[
          const SizedBox(height: 12),
          ApTextField(
            label: c.t('amount'),
            controller: amount,
            digits: 5,
            keyboardType: layout.numericKeyboards
                ? TextInputType.number
                : TextInputType.text,
            textInputAction: layout.enterSubmits
                ? TextInputAction.done
                : TextInputAction.next,
            onSubmitted: layout.enterSubmits ? (_) => review() : null,
            style: display(32, weight: FontWeight.w700, color: p.ink),
            invalid: errors.containsKey('amount'),
            padding: const EdgeInsets.only(bottom: 8),
            onChanged: (v) {
              c.aeps.amount = v;
              _extAmt = v;
              setState(() {});
            },
            prefix: _textPrefix(Text('₹', style: display(26, color: p.ink2))),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in [500, 1000, 2000, 3000, 5000])
                ApChip(
                  label: '₹${groupIn(v, dec: 0)}',
                  selected: amount.text == '$v',
                  onTap: () {
                    amount.text = '$v';
                    c.aeps.amount = '$v';
                    _extAmt = '$v';
                    setState(() {});
                  },
                ),
            ],
          ),
          HelpText(
            errors['amount'] ?? c.t('amount_h'),
            error: errors.containsKey('amount'),
          ),
        ],
        if (!layout.stickyPrimary && !liveSummary) ...[
          const SizedBox(height: 18),
          ApButton(
            label: c.t('review_fp'),
            icon: ApIcons.chevR,
            expand: true,
            onPressed: review,
          ),
        ],
      ],
    );

    final amt = double.tryParse(amount.text) ?? 0;
    final idDigits = _digits(idCtrl.text);
    final summary = Container(
      padding: const EdgeInsets.all(22),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.t('summary'),
                  style: display(16, weight: FontWeight.w700, color: p.ink),
                ),
              ),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  c.t(a.service),
                  style: body(12, weight: FontWeight.w600, color: p.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (a.service == 'cw') ...[
            Text(c.t('amount'), style: body(12.5, color: p.ink2)),
            const SizedBox(height: 2),
            amt > 0
                ? AmountText(amt, size: 42, dec: 0)
                : AmountText(0, size: 42, dec: 0, color: p.inkDis),
          ] else
            Text(
              a.service == 'be'
                  ? c.both(
                      "The customer's balance will be shown from their bank.",
                      'ग्राहक का बैलेंस बैंक से दिखाया जाएगा।',
                    )
                  : c.both(
                      'Last 5–10 transactions will be shown (depends on bank).',
                      'पिछले 5–10 लेन-देन दिखाए जाएँगे (बैंक पर निर्भर)।',
                    ),
              style: body(12.5, color: p.ink2),
            ),
          const SizedBox(height: 14),
          _sum(
            p,
            c.t('mobile'),
            mobile.text.length == 10
                ? maskMobile(mobile.text.substring(6))
                : '—',
          ),
          _sum(
            p,
            a.idType == 'aadhaar' ? c.t('masked_id') : 'VID',
            idDigits.length >= 12
                ? maskAadhaar(idDigits.substring(idDigits.length - 4))
                : '—',
          ),
          _sum(p, c.t('bank'), bank?.name ?? '—'),
          const SizedBox(height: 14),
          Divider(height: 1, color: p.line),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerLeft, child: DevicePill()),
          const SizedBox(height: 14),
          ApButton(
            label: c.t('review_fp'),
            trailingIcon: ApIcons.chevR,
            expand: true,
            onPressed: review,
          ),
          const SizedBox(height: 14),
          HelpText(
            c.both(
              'Tip: press Enter to continue.',
              'Enter दबाकर भी आगे बढ़ सकते हैं।',
            ),
          ),
        ],
      ),
    );

    final fieldsView = liveSummary
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: fields),
              const SizedBox(width: 20),
              SizedBox(width: 360, child: summary),
            ],
          )
        : fields;

    final action = ApButton(
      label: c.t('review_fp'),
      icon: ApIcons.chevR,
      expand: true,
      onPressed: review,
    );
    if (widget.stepper != null) {
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              children: [widget.stepper!, fieldsView],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: action,
          ),
        ],
      );
    }
    return fieldsView;
  }

  Widget _sum(ApPalette p, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(k, style: body(13.5, color: p.ink2)),
        const SizedBox(width: 12),
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

  Widget _textPrefix(Widget child) => Padding(
    padding: const EdgeInsets.only(left: 16, right: 8),
    child: Center(widthFactor: 1, child: child),
  );

  Widget _idType(
    AppController c,
    ApPalette p,
    String id,
    String label, {
    bool assume = false,
  }) {
    final on = c.aeps.idType == id;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () => c.setIdType(id),
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: on ? p.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: body(
                12.5,
                weight: FontWeight.w600,
                color: on ? p.primary : p.ink2,
              ),
            ),
            if (assume) ...[
              const SizedBox(width: 4),
              Transform.scale(scale: 0.85, child: const AssumeTag(label: '?')),
            ],
          ],
        ),
      ),
    );
  }
}
