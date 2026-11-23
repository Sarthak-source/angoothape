import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/session/domain/entities/session_entities.dart';
import '../../features/session/presentation/controllers/app_controller.dart';
import '../responsive/layout_scope.dart';
import '../responsive/layout_service.dart';
import '../theme/palette.dart';
import '../utils/format.dart';
import 'app_widgets.dart';
import '../theme/ap_icons.dart';

class AppSheet extends StatelessWidget {
  const AppSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = AppScope.of(context).sheet;
    if (sheet == null) return const SizedBox.shrink();
    return _SheetLayer(key: ValueKey(sheet.kind), kind: sheet.kind);
  }
}

/// Overlay chrome from the HTML prototype: dim scrim, grab handle on
/// phones, 34px top corners, centred dialog from 700px with a zoom-in.
class _SheetLayer extends StatefulWidget {
  const _SheetLayer({super.key, required this.kind});
  final SheetKind kind;

  @override
  State<_SheetLayer> createState() => _SheetLayerState();
}

class _SheetLayerState extends State<_SheetLayer>
    with SingleTickerProviderStateMixin {
  static const _ease = Cubic(0.2, 0.7, 0.2, 1);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();
  late final Animation<double> _t = CurvedAnimation(
    parent: _anim,
    curve: _ease,
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final mobile = LayoutScope.of(context).isMobile;
    final h = MediaQuery.sizeOf(context).height;
    final safe = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final radius = mobile
        ? const BorderRadius.vertical(top: Radius.circular(34))
        : BorderRadius.circular(30);
    final child = switch (widget.kind) {
      SheetKind.bank => const _BankSheet(),
      SheetKind.receipt => const _ReceiptSheet(),
      SheetKind.settle => const _SettleSheet(),
      SheetKind.addBank => const _AddBankSheet(),
      SheetKind.scenarios => const _ScenarioSheet(),
      SheetKind.profile => const _ProfileSheet(),
      SheetKind.password => const _PasswordSheet(),
      SheetKind.topup => const _TopupSheet(),
    };
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          return GestureDetector(
            onTap: c.closeSheet,
            child: ColoredBox(
              color: Color.fromRGBO(18, 16, 46, 0.45 * t),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboard),
                child: Align(
                  alignment: mobile ? Alignment.bottomCenter : Alignment.center,
                  child: GestureDetector(
                    onTap: () {},
                    child: Transform.translate(
                      offset: mobile ? Offset(0, 40 * (1 - t)) : Offset.zero,
                      child: Transform.scale(
                        scale: mobile ? 1 : 0.97 + 0.03 * t,
                        child: Opacity(
                          opacity: mobile ? 0.4 + 0.6 * t : t,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: h * (mobile ? 0.88 : 0.80),
                              maxWidth: mobile ? double.infinity : 560,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.card,
                                borderRadius: radius,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2912102E),
                                    blurRadius: 32,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: radius,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: safe),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (mobile)
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.lineStrong,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      Flexible(
                                        child: ApIdleOutline(child: child),
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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetHead extends StatelessWidget {
  const _SheetHead(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: display(18, color: p.ink)),
          ),
          Material(
            color: p.card,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: AppScope.of(context).closeSheet,
              child: Ink(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.card,
                  boxShadow: cardShadow(),
                ),
                child: Icon(ApIcons.close, color: p.ink, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetFoot extends StatelessWidget {
  const _SheetFoot({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: Row(children: children),
    );
  }
}

class _BankSheet extends StatefulWidget {
  const _BankSheet();
  @override
  State<_BankSheet> createState() => _BankSheetState();
}

class _BankSheetState extends State<_BankSheet> {
  String q = '';
  int index = 0;
  late final FocusNode searchFocus;

  @override
  void initState() {
    super.initState();
    searchFocus = FocusNode(onKeyEvent: _onSearchKey);
  }

  @override
  void dispose() {
    searchFocus.dispose();
    super.dispose();
  }

  KeyEventResult _onSearchKey(FocusNode node, KeyEvent event) {
    final layout = LayoutScope.of(context);
    if (!layout.arrowKeyBankPicker || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final list = _matches;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && list.isNotEmpty) {
      setState(() => index = (index + 1) % list.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && list.isNotEmpty) {
      setState(() => index = (index - 1 + list.length) % list.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter && list.isNotEmpty) {
      AppScope.of(context).pickBank(list[index].id);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  List<Bank> get _matches {
    final needle = q.toLowerCase();
    if (needle.isEmpty) return banks;
    return [
      for (final b in banks)
        if (b.nameLower.contains(needle) || b.shortLower.contains(needle)) b,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final layout = LayoutScope.of(context);
    final list = _matches;
    final pop = popularBanks;
    if (index >= list.length) index = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.t('choose_bank')),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: ApTextField(
            focusNode: searchFocus,
            autofocus: true,
            hint: c.t('search_bank'),
            padding: EdgeInsets.zero,
            prefix: Icon(ApIcons.search, color: p.ink3),
            onChanged: (v) => setState(() {
              q = v;
              index = 0;
            }),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            children: [
              if (q.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(c.t('popular'), style: display(16, color: p.ink)),
                ),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                  children: [
                    for (final b in pop)
                      Material(
                        color: p.card,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => c.pickBank(b.id),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: c.aeps.bank == b.id
                                    ? p.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: cardShadow(),
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 10),
                  child: Text(
                    c.t('all_banks'),
                    style: display(16, color: p.ink),
                  ),
                ),
              ] else
                const SizedBox(height: 10),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    c.both(
                      'No bank found. Try a shorter name, like “Baroda”.',
                      'कोई बैंक नहीं मिला। दूसरा नाम आज़माएँ।',
                    ),
                    textAlign: TextAlign.center,
                    style: body(14, color: p.ink2),
                  ),
                )
              else
                for (var i = 0; i < list.length; i++)
                  Material(
                    color:
                        (layout.arrowKeyBankPicker && i == index) ||
                            c.aeps.bank == list[i].id
                        ? p.primarySoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => c.pickBank(list[i].id),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              BankMono(list[i]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  list[i].name,
                                  style: body(14.5, weight: FontWeight.w600),
                                ),
                              ),
                              if (c.aeps.bank == list[i].id)
                                Icon(ApIcons.check, color: p.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptSheet extends StatelessWidget {
  const _ReceiptSheet();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final x = c.txnByRef(c.sheet?.ref);
    if (x == null) return const SizedBox.shrink();
    final b = bankById(x.bank);
    final share =
        LayoutScope.of(context).receipt == ReceiptPresentation.shareAndPrint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.t('receipt')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDEDDE9)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFC4C3D4),
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Wordmark(height: 26),
                                const Spacer(),
                                Text(
                                  '${c.t(x.svc)}\n${c.t('customer_copy')}',
                                  textAlign: TextAlign.right,
                                  style: body(
                                    11,
                                    weight: FontWeight.w600,
                                    color: const Color(0xFF56546B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 12),
                        child: Column(
                          children: [
                            if (x.svc == 'cw')
                              AmountText(
                                x.amt,
                                size: 30,
                                color: const Color(0xFF1B1A2E),
                              )
                            else
                              Text(
                                c.t(x.svc),
                                style: display(
                                  18,
                                  color: const Color(0xFF1B1A2E),
                                ),
                              ),
                            const SizedBox(height: 6),
                            StatusBadge(x.status),
                          ],
                        ),
                      ),
                      _r(c.t('datetime'), fmtDt(x.t, c.lang)),
                      _r(c.t('ref'), x.ref),
                      _r(c.t('rrn'), x.rrn),
                      _r(c.t('bank'), b?.name ?? ''),
                      _r(c.t('masked_id'), maskAadhaar(x.aadhaar4)),
                      _r(c.t('mobile'), maskMobile(x.mobile4)),
                      if (x.status == TxStatus.success && x.bal != null)
                        _r(c.t('cust_bal'), inr(x.bal!)),
                      _r(
                        c.both('Retailer', 'रिटेलर'),
                        '${c.data.retailer.shop}\n${c.data.retailer.id} · ${c.data.retailer.city}',
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        height: 1.5,
                        thickness: 1.5,
                        color: Color(0xFFC4C3D4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        x.status == TxStatus.success
                            ? c.both(
                                'Confirmed by bank.',
                                'बैंक द्वारा पुष्टि की गई।',
                              )
                            : x.status == TxStatus.failed
                            ? c.both(
                                'Failed — no cash given to customer.',
                                'असफल — ग्राहक को नकद नहीं दिया गया।',
                              )
                            : c.both(
                                'Pending — do not give cash until confirmed.',
                                'पेंडिंग — परिणाम की पुष्टि होने तक नकद न दें।',
                              ),
                        textAlign: TextAlign.center,
                        style: body(
                          11,
                          color: const Color(0xFF737189),
                          height: 1.5,
                        ),
                      ),
                      Text(
                        c.both(
                          'Demo receipt with mock data. Help: 1800 000 0000',
                          'मॉक डेटा वाली डेमो रसीद। सहायता: 1800 000 0000',
                        ),
                        textAlign: TextAlign.center,
                        style: body(
                          11,
                          color: const Color(0xFF737189),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 58,
                  right: 14,
                  child: Transform.rotate(
                    angle: 8 * 3.1415926535 / 180,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFB8441A),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEMO',
                        style: display(
                          10,
                          weight: FontWeight.w700,
                          color: const Color(0xFFB8441A),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _SheetFoot(
          children: [
            if (share) ...[
              Expanded(
                child: ApButton(
                  label: c.t('share'),
                  icon: ApIcons.share,
                  onPressed: () => c.receiptAction('share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ApButton(
                  label: c.t('print'),
                  kind: ApButtonKind.outline,
                  icon: ApIcons.printer,
                  onPressed: () => c.receiptAction('print'),
                ),
              ),
            ] else ...[
              ApButton(
                label: c.t('copy_ref'),
                kind: ApButtonKind.ghost,
                icon: ApIcons.copy,
                onPressed: () => copyText(context, x.ref, c.t('copied')),
              ),
              const Spacer(),
              ApButton(
                label: c.t('download'),
                kind: ApButtonKind.outline,
                icon: ApIcons.download,
                onPressed: () => c.receiptAction('download'),
              ),
              const SizedBox(width: 10),
              ApButton(
                label: c.t('print'),
                icon: ApIcons.printer,
                onPressed: () => c.receiptAction('print'),
              ),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ApIcons.info, size: 16, color: ap(context).ink2),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.both(
                    'Each print, download or share is stored on your account.',
                    'हर प्रिंट, डाउनलोड या शेयर आपके खाते में दर्ज होता है।',
                  ),
                  style: body(12, color: ap(context).ink2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _r(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(k, style: body(12.5, color: const Color(0xFF56546B))),
        ),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: body(
              12.5,
              weight: FontWeight.w700,
              color: const Color(0xFF1B1A2E),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SettleSheet extends StatefulWidget {
  const _SettleSheet();
  @override
  State<_SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<_SettleSheet> {
  final amt = TextEditingController();
  @override
  void dispose() {
    amt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final n = int.tryParse(amt.text) ?? 0;
    final err =
        (c.sheet?.tried ?? false) && (n < 100 || n > c.data.wallet.aeps);
    final active = c.data.accounts.where((a) => a.status == 'active');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.t('move_bank')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApTextField(
                  label: c.both('Amount', 'राशि'),
                  controller: amt,
                  digits: 7,
                  invalid: err,
                  style: display(28, weight: FontWeight.w700),
                  padding: EdgeInsets.zero,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Center(
                      widthFactor: 1,
                      child: Text('₹', style: display(26, color: p.ink2)),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ApChip(
                      label:
                          '${c.both('All', 'पूरा')} ${inr(c.data.wallet.aeps, dec: 0)}',
                      selected: false,
                      onTap: () => setState(
                        () => amt.text = c.data.wallet.aeps.floor().toString(),
                      ),
                    ),
                  ],
                ),
                if (err)
                  HelpText(
                    c.both(
                      'Enter between ₹100 and ${inr(c.data.wallet.aeps, dec: 0)}.',
                      '₹100 से ${inr(c.data.wallet.aeps, dec: 0)} के बीच राशि डालें।',
                    ),
                    error: true,
                  )
                else
                  HelpText('${c.t('aeps_bal')}: ${inr(c.data.wallet.aeps)}'),
                const SizedBox(height: 10),
                Text(
                  c.both('To account', 'खाता'),
                  style: body(14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final a in active)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: cardBox(p, radius: 22),
                    child: Row(
                      children: [
                        if (bankById(a.bank) != null)
                          BankMono(bankById(a.bank)!),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bankById(a.bank)?.name ?? ''} ••${a.last4}',
                                style: body(14, weight: FontWeight.w700),
                              ),
                              Text(a.holder, style: body(12.5, color: p.ink2)),
                            ],
                          ),
                        ),
                        Icon(ApIcons.check, color: p.success, size: 20),
                      ],
                    ),
                  ),
                Notice(
                  tone: NoticeTone.warn,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        c.both(
                          'Settlement charges and timing depend on the partner and are not confirmed.',
                          'सेटलमेंट शुल्क और समय पार्टनर पर निर्भर हैं, अभी तय नहीं।',
                        ),
                      ),
                      const AssumeTag(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _SheetFoot(
          children: [
            ApButton(
              label: c.t('cancel'),
              kind: ApButtonKind.ghost,
              onPressed: c.closeSheet,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ApButton(
                label: c.t('move_bank'),
                onPressed: () {
                  c.sheet?.amt = amt.text;
                  c.submitSettle();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddBankSheet extends StatefulWidget {
  const _AddBankSheet();
  @override
  State<_AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends State<_AddBankSheet> {
  final holder = TextEditingController();
  final acct = TextEditingController();
  final acct2 = TextEditingController();
  final ifsc = TextEditingController();

  @override
  void dispose() {
    holder.dispose();
    acct.dispose();
    acct2.dispose();
    ifsc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final tried = c.sheet?.tried ?? false;
    final ifscOk = validIfsc(ifsc.text);
    final bankId = ifscOk ? ifscBank[ifsc.text.substring(0, 4)] : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.t('add_bank')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _f(
                  p,
                  c.both('Account holder name', 'खाताधारक का नाम'),
                  holder,
                  error: tried && holder.text.trim().isEmpty
                      ? c.both('Enter the name.', 'नाम डालें।')
                      : null,
                ),
                _f(
                  p,
                  c.both('Account number', 'खाता संख्या'),
                  acct,
                  digits: true,
                  error: tried && !validAccount(acct.text)
                      ? c.both(
                          'Enter a 9–18 digit account number.',
                          '9–18 अंकों का खाता नंबर डालें।',
                        )
                      : null,
                ),
                _f(
                  p,
                  c.both('Re-enter account number', 'खाता संख्या दोबारा'),
                  acct2,
                  digits: true,
                  error: tried && acct.text != acct2.text
                      ? c.both(
                          'Account numbers do not match.',
                          'दोनों नंबर मेल नहीं खाते।',
                        )
                      : null,
                ),
                _f(
                  p,
                  'IFSC',
                  ifsc,
                  caps: true,
                  error: tried && !ifscOk
                      ? c.both(
                          'Enter a valid IFSC, e.g. SBIN0001234.',
                          'सही IFSC डालें, जैसे SBIN0001234।',
                        )
                      : null,
                ),
                if (ifscOk)
                  HelpText(
                    c.both(
                      '${bankById(bankId)?.name ?? 'Bank found'} · Branch (demo)',
                      '${bankById(bankId)?.name ?? 'बैंक मिला'} · शाखा (डेमो)',
                    ),
                  ),
              ],
            ),
          ),
        ),
        _SheetFoot(
          children: [
            ApButton(
              label: c.t('cancel'),
              kind: ApButtonKind.ghost,
              onPressed: c.closeSheet,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ApButton(
                label: c.both('Add and verify', 'जोड़ें और सत्यापित करें'),
                onPressed: () => c.submitBank({
                  'holder': holder.text,
                  'acct': acct.text,
                  'acct2': acct2.text,
                  'ifsc': ifsc.text.toUpperCase(),
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _f(
    ApPalette p,
    String label,
    TextEditingController ctl, {
    bool digits = false,
    bool caps = false,
    String? error,
  }) {
    return ApTextField(
      label: label,
      controller: ctl,
      numeric: digits,
      caps: caps,
      error: error,
      padding: const EdgeInsets.only(bottom: 10),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _ScenarioSheet extends StatelessWidget {
  const _ScenarioSheet();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final s = c.scenario;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.both('Demo scenarios', 'डेमो स्थितियाँ')),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  c.both(
                    'These switches only change the next mock transaction. Nothing here is a real bank or device.',
                    'ये स्विच केवल अगले मॉक लेन-देन को बदलते हैं।',
                  ),
                  style: body(13, color: ap(context).ink2),
                ),
              ),
              _sec(c.both('Next transaction outcome', 'अगला परिणाम')),
              RadioGroup<OutcomeKind>(
                groupValue: s.outcome,
                onChanged: (v) {
                  if (v != null) c.setOutcome(v);
                },
                child: Column(
                  children: [
                    for (final o in OutcomeKind.values)
                      RadioListTile<OutcomeKind>(
                        value: o,
                        title: Text(_outcome(c, o)),
                      ),
                  ],
                ),
              ),
              if (s.outcome == OutcomeKind.failed) ...[
                _sec(c.both('Failure reason', 'असफलता का कारण')),
                RadioGroup<String>(
                  groupValue: s.failReason,
                  onChanged: (v) {
                    if (v != null) c.setFailReason(v);
                  },
                  child: Column(
                    children: [
                      for (final r in ['insufficient', 'bio', 'bankdown'])
                        RadioListTile<String>(
                          value: r,
                          title: Text(reasons[r]!.text(c.lang)),
                        ),
                    ],
                  ),
                ),
              ],
              if (s.outcome == OutcomeKind.pending ||
                  s.outcome == OutcomeKind.network) ...[
                _sec(
                  c.both(
                    'When status is checked, resolve as',
                    'स्थिति जाँच पर परिणाम',
                  ),
                ),
                RadioGroup<String>(
                  groupValue: s.pendingResolve,
                  onChanged: (v) {
                    if (v != null) c.setPendingResolve(v);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'success',
                        title: Text(c.t('s_success')),
                      ),
                      RadioListTile<String>(
                        value: 'failed',
                        title: Text(c.t('s_failed')),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    c.both(
                      'Pending needs 2 checks. A network-unknown resolves on the first check.',
                      'पेंडिंग के लिए 2 जाँच। नेटवर्क-अज्ञात पहली जाँच पर सुलझता है।',
                    ),
                    style: body(12, color: ap(context).ink2),
                  ),
                ),
              ],
              _sec(c.both('Fingerprint device', 'फ़िंगरप्रिंट डिवाइस')),
              RadioGroup<DeviceState>(
                groupValue: s.device,
                onChanged: (v) {
                  if (v != null) c.setDevice(v);
                },
                child: Column(
                  children: [
                    for (final d in DeviceState.values)
                      RadioListTile<DeviceState>(
                        value: d,
                        title: Text(_dev(c, d)),
                      ),
                  ],
                ),
              ),
              _sec(c.both('Fingerprint capture', 'फ़िंगरप्रिंट कैप्चर')),
              RadioGroup<bool>(
                groupValue: s.captureRetry,
                onChanged: (v) {
                  if (v != null) c.setCaptureRetry(v);
                },
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: false,
                      title: Text(c.both('Good first time', 'पहली बार साफ़')),
                    ),
                    RadioListTile<bool>(
                      value: true,
                      title: Text(
                        c.both('First attempt unclear', 'पहली कोशिश अस्पष्ट'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  c.both(
                    'Aadhaar is cleared when a transaction is submitted and is never stored.',
                    'आधार सबमिट पर मिट जाता है और सेव नहीं होता।',
                  ),
                  style: body(12, color: ap(context).ink2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Text(t, style: body(12, weight: FontWeight.w800)),
  );

  String _outcome(AppController c, OutcomeKind o) => switch (o) {
    OutcomeKind.success => c.t('s_success'),
    OutcomeKind.failed => c.t('s_failed'),
    OutcomeKind.pending => c.both('Pending (bank slow)', 'पेंडिंग (बैंक धीमा)'),
    OutcomeKind.network => c.both(
      'Network drop → unknown',
      'नेटवर्क टूटा → अज्ञात',
    ),
  };

  String _dev(AppController c, DeviceState d) => switch (d) {
    DeviceState.ready => c.t('dev_ready'),
    DeviceState.disconnected => c.t('dev_off'),
    DeviceState.permission => c.t('dev_perm'),
  };
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();
  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final name = TextEditingController();
  final shop = TextEditingController();
  final city = TextEditingController();
  final mobile = TextEditingController();
  var _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filled) return;
    _filled = true;
    final r = AppScope.of(context).data.retailer;
    name.text = r.name;
    shop.text = r.shop;
    city.text = r.city;
    mobile.text = r.mobileFull.isNotEmpty ? r.mobileFull : r.mobile;
  }

  @override
  void dispose() {
    name.dispose();
    shop.dispose();
    city.dispose();
    mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final tried = c.sheet?.tried ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.both('Edit profile', 'प्रोफ़ाइल बदलें')),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            child: Column(
              children: [
                ApTextField(
                  label: c.both('Name', 'नाम'),
                  controller: name,
                  error: tried && name.text.trim().isEmpty
                      ? c.both('Enter your name', 'नाम लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.both('Shop', 'दुकान'),
                  controller: shop,
                  error: tried && shop.text.trim().isEmpty
                      ? c.both('Enter shop name', 'दुकान का नाम लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.both('City', 'शहर'),
                  controller: city,
                  error: tried && city.text.trim().isEmpty
                      ? c.both('Enter city', 'शहर लिखें')
                      : null,
                ),
                ApTextField(
                  label: c.t('mobile'),
                  controller: mobile,
                  digits: 10,
                  error: tried && !validMobile(mobile.text)
                      ? c.t('e_mobile')
                      : null,
                ),
              ],
            ),
          ),
        ),
        _SheetFoot(
          children: [
            ApButton(
              label: c.both('Save', 'सेव करें'),
              expand: true,
              onPressed: () => c.submitProfile({
                'name': name.text,
                'shop': shop.text,
                'city': city.text,
                'mobile': mobile.text,
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();
  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final current = TextEditingController();
  final next = TextEditingController();
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final tried = c.sheet?.tried ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.both('Password & security', 'पासवर्ड और सुरक्षा')),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: Column(
            children: [
              ApTextField(
                label: c.both('Current password', 'वर्तमान पासवर्ड'),
                controller: current,
                obscure: true,
                error: tried && current.text.isEmpty
                    ? c.both('Enter current password', 'वर्तमान पासवर्ड लिखें')
                    : null,
              ),
              ApTextField(
                label: c.both('New password', 'नया पासवर्ड'),
                controller: next,
                obscure: true,
                error: tried && next.text.length < 8
                    ? c.both('Use at least 8 characters', 'कम से कम 8 अक्षर')
                    : null,
              ),
            ],
          ),
        ),
        _SheetFoot(
          children: [
            ApButton(
              label: c.both('Update password', 'पासवर्ड बदलें'),
              expand: true,
              onPressed: () => c.submitPassword(current.text, next.text),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopupSheet extends StatefulWidget {
  const _TopupSheet();
  @override
  State<_TopupSheet> createState() => _TopupSheetState();
}

class _TopupSheetState extends State<_TopupSheet> {
  final amt = TextEditingController();
  @override
  void dispose() {
    amt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final n = int.tryParse(amt.text) ?? 0;
    final err = (c.sheet?.tried ?? false) && (n < 100 || n > 50000);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHead(c.both('Wallet top-up', 'वॉलेट टॉप-अप')),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
          child: ApTextField(
            label: c.both('Amount', 'राशि'),
            controller: amt,
            digits: 7,
            invalid: err,
            onChanged: (v) {
              c.setSettleAmt(v);
              setState(() {});
            },
          ),
        ),
        if (err)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: HelpText(
              c.both('Enter between ₹100 and ₹50,000.', '₹100 से ₹50,000 के बीच लिखें।'),
              error: true,
            ),
          ),
        _SheetFoot(
          children: [
            ApButton(
              label: c.both('Add to wallet', 'वॉलेट में जोड़ें'),
              expand: true,
              onPressed: () {
                c.setSettleAmt(amt.text);
                c.submitTopup();
              },
            ),
          ],
        ),
      ],
    );
  }
}
