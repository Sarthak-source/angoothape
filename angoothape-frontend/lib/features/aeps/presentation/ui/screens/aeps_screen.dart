import 'package:flutter/material.dart';

import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/fingerprint_pad.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class AepsScreen extends StatelessWidget {
  const AepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final layout = LayoutScope.of(context);
    final step = c.aeps.step;
    final idx = switch (step) {
      AepsStep.details => 0,
      AepsStep.auth => 1,
      AepsStep.processing || AepsStep.result => 2,
    };
    final stepper = step == AepsStep.processing
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StepperBar(
              labels: [
                c.t('step_details'),
                c.t('step_auth'),
                c.t('step_result'),
              ],
              index: idx,
              doneLast: step == AepsStep.result,
            ),
          );
    if (layout.stickyPrimary && step == AepsStep.details) {
      return AepsDetails(stepper: stepper);
    }
    return ScreenPad(
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (layout.showHeader && step != AepsStep.processing)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c.t('aeps_title'),
                      style: display(22, color: ap(context).ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const DevicePill(),
                ],
              ),
            ),
          stepper,
          switch (step) {
            AepsStep.details => const AepsDetails(),
            AepsStep.auth => const AepsAuth(),
            AepsStep.processing => const AepsProcessing(),
            AepsStep.result => const AepsResult(live: true),
          },
        ],
      ),
    );
  }
}

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
    final popular = banks.where((b) => b.popular).take(popularCount).toList();
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
    final scanner = const _Scanner();
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

class _Scanner extends StatelessWidget {
  const _Scanner();

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final d = c.scenario.device;
    Widget panel;
    if (a.devChecking) {
      panel = Column(
        children: [
          const Icon(ApIcons.usb, size: 72),
          const SizedBox(height: 12),
          Text(c.t('checking_device'), style: display(18, color: p.ink)),
        ],
      );
    } else if (d != DeviceState.ready) {
      final off = d == DeviceState.disconnected;
      panel = Column(
        children: [
          Icon(
            off ? ApIcons.usb : ApIcons.alert,
            size: 64,
            color: off ? p.warning : p.error,
          ),
          const SizedBox(height: 10),
          Text(
            c.t(off ? 'dev_off_t' : 'dev_perm_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            c.t(off ? 'dev_off_p' : 'dev_perm_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ApButton(
                label: c.t('check_again'),
                icon: ApIcons.refresh,
                onPressed: c.checkDevice,
              ),
              ApButton(
                label: c.t('device_help'),
                kind: ApButtonKind.soft,
                onPressed: () => c.nav('device'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.t('entries_kept'), style: body(12.5, color: p.ink2)),
        ],
      );
    } else if (a.capture == CapturePhase.capturing) {
      panel = Column(
        children: [
          const _Finger(phase: CapturePhase.capturing),
          const SizedBox(height: 12),
          Text(c.t('capturing'), style: display(18, color: p.ink)),
          Text(
            c.t('place_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (a.capture == CapturePhase.ok) {
      panel = Column(
        children: [
          const _Finger(phase: CapturePhase.ok),
          const SizedBox(height: 12),
          Text(c.t('cap_ok'), style: display(18, color: p.ink)),
          Text(c.t('sending'), style: body(14, color: p.ink2)),
        ],
      );
    } else if (a.capture == CapturePhase.locked) {
      panel = Column(
        children: [
          const _Finger(phase: CapturePhase.failed),
          const SizedBox(height: 12),
          Text(
            c.t('cap_fail_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          Text(
            c.t('too_many'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ApButton(
                label: c.t('device_help'),
                kind: ApButtonKind.soft,
                onPressed: () => c.nav('device'),
              ),
              ApButton(
                label: c.t('retry_txn'),
                onPressed: () => c.restartAeps(),
              ),
            ],
          ),
        ],
      );
    } else if (a.capture == CapturePhase.failed) {
      final left = 3 - a.attempts;
      panel = Column(
        children: [
          const _Finger(phase: CapturePhase.failed),
          const SizedBox(height: 12),
          Text(c.t('cap_fail_t'), style: display(18, color: p.ink)),
          Text(
            c.t('cap_fail_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('$left ${c.t('attempts_left')}', style: body(13, color: p.ink2)),
          const SizedBox(height: 12),
          SlideToScan(label: c.t('try_again'), onConfirmed: c.capture),
        ],
      );
    } else {
      final short = a.service == 'cw'
          ? c.both(
              'Withdraw ${inr(int.tryParse(a.amount) ?? 0, dec: 0)}',
              '${inr(int.tryParse(a.amount) ?? 0, dec: 0)} निकालें',
            )
          : c.t('scan');
      panel = Column(
        children: [
          const _Finger(phase: CapturePhase.idle),
          const SizedBox(height: 12),
          Text(
            c.t('place_t'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          Text(
            c.t('place_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SlideToScan(label: short, onConfirmed: c.capture),
          const SizedBox(height: 8),
          Text(
            c.t('no_phone_fp'),
            style: body(12.5, color: p.ink2),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_pad),
      decoration: cardBox(p),
      child: panel,
    );
  }
}

class _Finger extends StatelessWidget {
  const _Finger({required this.phase});
  final CapturePhase phase;
  @override
  Widget build(BuildContext context) => FingerprintPad(
    state: switch (phase) {
      CapturePhase.failed || CapturePhase.locked => PadState.bad,
      CapturePhase.ok => PadState.good,
      CapturePhase.capturing => PadState.capturing,
      _ => PadState.place,
    },
  );
}

class SlideToScan extends StatefulWidget {
  const SlideToScan({
    super.key,
    required this.label,
    required this.onConfirmed,
  });
  final String label;
  final VoidCallback onConfirmed;
  @override
  State<SlideToScan> createState() => _SlideToScanState();
}

class _SlideToScanState extends State<SlideToScan> {
  double dx = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final max = (box.maxWidth - 68).clamp(1, 1000).toDouble();
            return GestureDetector(
              onHorizontalDragUpdate: (d) =>
                  setState(() => dx = (dx + d.delta.dx).clamp(0, max)),
              onHorizontalDragEnd: (_) {
                if (dx >= max * 0.85) {
                  setState(() => dx = max);
                  widget.onConfirmed();
                } else {
                  if (dx < 12) c.toast(c.t('slide_hint'));
                  setState(() => dx = 0);
                }
              },
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2662F),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2662F).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ((dx + 56) / box.maxWidth).clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ApPalette.orange700,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6 + dx,
                      top: 6,
                      child: Container(
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
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          widget.label,
                          style: display(
                            16,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(c.t('slide_help'), style: body(12.5, color: ap(context).ink2)),
      ],
    );
  }
}

class AepsProcessing extends StatelessWidget {
  const AepsProcessing({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final a = c.aeps;
    final title = a.offline
        ? c.t('net_t')
        : c.t(
            a.service == 'cw'
                ? 'proc_t'
                : a.service == 'be'
                ? 'proc_be'
                : 'proc_ms',
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: cardBox(p, radius: 56),
            alignment: Alignment.center,
            child: Icon(
              a.offline ? ApIcons.wifiOff : ApIcons.fingerprint,
              size: 48,
              color: a.offline ? p.warning : p.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: display(22, color: p.ink),
            textAlign: TextAlign.center,
          ),
          if (a.service == 'cw')
            AmountText(int.tryParse(a.amount) ?? 0, size: 30, dec: 0),
          const SizedBox(height: 8),
          Text(
            a.offline ? c.t('net_p') : c.t('proc_p'),
            style: body(14, color: p.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    i < a.procStep ? ApIcons.check : Icons.circle_outlined,
                    color: i < a.procStep
                        ? p.success
                        : i == a.procStep
                        ? p.primary
                        : p.ink3,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    c.t('ps${i + 1}'),
                    style: body(
                      15,
                      weight: i == a.procStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i == a.procStep ? p.primary : p.ink,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ApButton(
            label: c.t('txn_running'),
            icon: ApIcons.lock,
            kind: ApButtonKind.soft,
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class AepsResult extends StatelessWidget {
  const AepsResult({super.key, required this.live, this.txn});
  final bool live;
  final Txn? txn;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final x = txn ?? c.txnByRef(c.aeps.resultRef);
    if (x == null) return const SizedBox.shrink();
    return ResultBody(tx: x, live: live);
  }
}

class ResultBody extends StatelessWidget {
  const ResultBody({super.key, required this.tx, required this.live});
  final Txn tx;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final b = bankById(tx.bank);
    final busy = c.checking[tx.ref] == true;
    late Widget head;
    final extras = <Widget>[];
    final actions = <Widget>[];

    if (tx.status == TxStatus.success) {
      final title = tx.svc == 'cw'
          ? c.t('ok_t')
          : tx.svc == 'be'
          ? c.t('be_ok')
          : c.t('ms_ok');
      head = _Head(
        icon: ApIcons.check,
        color: p.success,
        bg: p.successBg,
        title: title,
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      if (tx.svc == 'cw') {
        extras.add(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1944),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(ApIcons.cash, color: Color(0xFFFBA078), size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.t('give_cash')}: ${inr(tx.amt, dec: 0)}',
                        style: display(
                          20,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        c.t('give_cash_p'),
                        style: body(13, color: const Color(0xFFC6C4EC)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (tx.svc == 'ms') extras.add(_Mini(tx: tx));
      extras.add(
        _Card(
          children: [
            _kv(p, c.t('cust_bal'), tx.bal == null ? '—' : inr(tx.bal!)),
            if (tx.svc == 'cw')
              _kv(
                p,
                c.t('wallet_credit'),
                '+ ${inr(tx.amt)}',
                valueColor: p.success,
              ),
            if (tx.svc == 'cw')
              _kv(p, c.t('your_earning'), inr(tx.earn), tag: c.t('sample')),
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('rrn'), tx.rrn),
          ],
        ),
      );
      actions.add(
        ApButton(
          label: c.t('view_receipt'),
          icon: ApIcons.doc,
          expand: true,
          onPressed: () => c.openReceipt(tx.ref),
        ),
      );
      actions.add(
        live
            ? ApButton(
                label: c.t('new_txn'),
                kind: ApButtonKind.outline,
                icon: ApIcons.plus,
                expand: true,
                onPressed: () => c.restartAeps(keep: false),
              )
            : ApButton(
                label: c.t('support_req'),
                kind: ApButtonKind.outline,
                icon: ApIcons.headset,
                expand: true,
                onPressed: () => c.openSupport(tx.ref),
              ),
      );
    } else if (tx.status == TxStatus.failed) {
      final reason = reasons[tx.reason];
      head = _Head(
        icon: ApIcons.close,
        color: p.error,
        bg: p.errorBg,
        title: tx.svc == 'cw'
            ? c.t('fail_t')
            : c.both('Transaction failed', 'लेन-देन असफल'),
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      extras.add(
        Notice(
          tone: NoticeTone.err,
          icon: ApIcons.alert,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tx.svc == 'cw' ? '${c.t('no_cash')} ' : ''}${reason?.text(c.lang) ?? ''}',
                style: body(14, weight: FontWeight.w700),
              ),
              Text(reason?.next(c.lang) ?? '', style: body(13)),
            ],
          ),
        ),
      );
      if (tx.svc == 'cw') {
        extras.add(
          Notice(
            tone: NoticeTone.info,
            child: Text(
              '${c.t('fail_debit')} ${c.both('If the customer says money was debited, raise a support request.', 'अगर ग्राहक कहे कि पैसा कटा है, तो सहायता अनुरोध करें।')}',
            ),
          ),
        );
      }
      extras.add(
        _Card(
          children: [
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('rrn'), tx.rrn),
            _kv(p, c.t('masked_id'), maskAadhaar(tx.aadhaar4)),
          ],
        ),
      );
      if (live) {
        actions.add(
          ApButton(
            label: c.t('retry_txn'),
            icon: ApIcons.refresh,
            expand: true,
            onPressed: () => c.restartAeps(),
          ),
        );
        actions.add(
          ApButton(
            label: c.t('get_help'),
            kind: ApButtonKind.outline,
            icon: ApIcons.headset,
            expand: true,
            onPressed: () => c.openSupport(tx.ref),
          ),
        );
      } else {
        actions.add(
          ApButton(
            label: c.t('receipt'),
            kind: ApButtonKind.outline,
            icon: ApIcons.doc,
            expand: true,
            onPressed: () => c.openReceipt(tx.ref),
          ),
        );
        actions.add(
          ApButton(
            label: c.t('support_req'),
            icon: ApIcons.headset,
            expand: true,
            onPressed: () => c.openSupport(tx.ref),
          ),
        );
      }
    } else {
      head = _Head(
        icon: tx.unknown ? ApIcons.wifiOff : ApIcons.clock,
        color: p.warning,
        bg: p.warningBg,
        title: tx.unknown ? c.t('net_res_t') : c.t('pend_t'),
        amount: tx.svc == 'cw' ? tx.amt : null,
        sub: '${b?.name ?? ''} · ${fmtDt(tx.t, c.lang)}',
      );
      extras.add(
        Notice(
          tone: NoticeTone.warn,
          icon: ApIcons.alert,
          child: Text(
            '${tx.unknown ? c.t('net_res_p') : c.t('pend_p')} ${c.both('Do not start a new withdrawal for this customer.', 'इसी ग्राहक के लिए नई निकासी शुरू न करें।')}',
          ),
        ),
      );
      extras.add(
        _Card(
          children: [
            _kv(p, c.t('ref'), tx.ref),
            _kv(p, c.t('masked_id'), maskAadhaar(tx.aadhaar4)),
            _kv(p, c.both('Status checks', 'जाँच की गई'), '${tx.checks}'),
          ],
        ),
      );
      actions.add(
        ApButton(
          label: busy ? c.t('checking') : c.t('check_status'),
          icon: ApIcons.refresh,
          busy: busy,
          expand: true,
          onPressed: busy ? null : () => c.checkStatus(tx.ref),
        ),
      );
      actions.add(
        ApButton(
          label: c.t('support_req'),
          kind: ApButtonKind.outline,
          icon: ApIcons.headset,
          expand: true,
          onPressed: () => c.openSupport(tx.ref),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        head,
        const SizedBox(height: 12),
        for (final w in extras) ...[w, const SizedBox(height: 12)],
        LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth > 520) {
              return Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  actions[i],
                ],
              ],
            );
          },
        ),
        if (live) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(onPressed: c.doneAeps, child: Text(c.t('done'))),
              if (tx.status == TxStatus.success)
                TextButton(
                  onPressed: () => c.openSupport(tx.ref),
                  child: Text(c.t('get_help')),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _kv(
    ApPalette p,
    String k,
    String v, {
    Color? valueColor,
    String? tag,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(k, style: body(14, color: p.ink2)),
              if (tag != null) AssumeTag(label: tag),
            ],
          ),
        ),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(
              14,
              weight: FontWeight.w700,
              color: valueColor ?? p.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Head extends StatelessWidget {
  const _Head({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.sub,
    this.amount,
  });
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String sub;
  final int? amount;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(icon, color: color, size: 46),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: display(24, color: p.ink),
          textAlign: TextAlign.center,
        ),
        if (amount != null) AmountText(amount!, size: 48, dec: 0),
        Text(
          sub,
          style: body(13, color: p.ink2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: cardBox(ap(context)),
    child: Column(children: children),
  );
}

class _Mini extends StatelessWidget {
  const _Mini({required this.tx});
  final Txn tx;
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final rows = tx.mini;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardBox(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('ms_ok'), style: display(16, color: p.ink)),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: body(14, weight: FontWeight.w600),
                        ),
                        Text(
                          fmtDt(row.date, c.lang).split(',').first,
                          style: body(12, color: p.ink2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${row.amount > 0 ? '+' : '−'} ${inr(row.amount.abs())}',
                    style: body(
                      14,
                      weight: FontWeight.w700,
                      color: row.amount > 0 ? p.success : p.ink,
                    ),
                  ),
                ],
              ),
            ),
          Text(c.t('fictional'), style: body(12, color: p.ink2)),
        ],
      ),
    );
  }
}
