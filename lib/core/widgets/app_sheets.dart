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
    final c = AppScope.of(context);
    final sheet = c.sheet;
    if (sheet == null) return const SizedBox.shrink();
    final p = ap(context);
    final layout = LayoutScope.of(context);
    final dialog =
        sheet.kind == SheetKind.bank &&
        layout.bankPicker == BankPickerPresentation.dialog;
    return Positioned.fill(
      child: GestureDetector(
        onTap: c.closeSheet,
        child: Container(
          color: const Color(0x7312102E),
          alignment: dialog ? Alignment.center : Alignment.bottomCenter,
          padding: dialog ? const EdgeInsets.all(24) : EdgeInsets.zero,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: dialog
                    ? 640
                    : MediaQuery.sizeOf(context).height * 0.88,
                maxWidth: dialog ? 520 : 640,
              ),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: dialog
                    ? BorderRadius.circular(28)
                    : const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: switch (sheet.kind) {
                SheetKind.bank => const _BankSheet(),
                SheetKind.receipt => const _ReceiptSheet(),
                SheetKind.settle => const _SettleSheet(),
                SheetKind.addBank => const _AddBankSheet(),
                SheetKind.scenarios => const _ScenarioSheet(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHead extends StatelessWidget {
  const _SheetHead(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: display(18, color: ap(context).ink)),
          ),
          IconButton(
            onPressed: AppScope.of(context).closeSheet,
            icon: const Icon(ApIcons.close),
          ),
        ],
      ),
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

  List<Bank> get _matches => banks
      .where(
        (b) =>
            q.isEmpty ||
            b.name.toLowerCase().contains(q.toLowerCase()) ||
            b.short.toLowerCase().contains(q.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final layout = LayoutScope.of(context);
    final list = _matches;
    final pop = banks.where((b) => b.popular).toList();
    if (index >= list.length) index = 0;
    return Column(
      children: [
        _SheetHead(c.t('choose_bank')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (q.isEmpty) ...[
                Text(c.t('popular'), style: display(16, color: p.ink)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in pop)
                      InkWell(
                        onTap: () => c.pickBank(b.id),
                        child: Container(
                          width: 76,
                          padding: const EdgeInsets.all(8),
                          decoration: cardBox(p, radius: 16),
                          child: Column(
                            children: [
                              BankMono(b, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                b.short,
                                style: body(11, weight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(c.t('all_banks'), style: display(16, color: p.ink)),
              ],
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    c.both(
                      'No bank found. Try a shorter name.',
                      'कोई बैंक नहीं मिला।',
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (var i = 0; i < list.length; i++)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    selected: layout.arrowKeyBankPicker && i == index,
                    selectedTileColor: p.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: BankMono(list[i]),
                    title: Text(
                      list[i].name,
                      style: body(14, weight: FontWeight.w600),
                    ),
                    trailing: c.aeps.bank == list[i].id
                        ? Icon(ApIcons.check, color: p.primary)
                        : null,
                    onTap: () => c.pickBank(list[i].id),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDEDDE9)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Wordmark(height: 22),
                      const Spacer(),
                      Text(
                        '${c.t(x.svc)}\n${c.t('customer_copy')}',
                        textAlign: TextAlign.right,
                        style: body(11, color: const Color(0xFF56546B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: ApPalette.orange700),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEMO',
                        style: body(
                          10,
                          weight: FontWeight.w800,
                          color: ApPalette.orange700,
                        ),
                      ),
                    ),
                  ),
                  if (x.svc == 'cw')
                    AmountText(x.amt, size: 30, color: const Color(0xFF1B1A2E))
                  else
                    Text(
                      c.t(x.svc),
                      style: display(18, color: const Color(0xFF1B1A2E)),
                    ),
                  const SizedBox(height: 6),
                  StatusBadge(x.status),
                  const Divider(height: 22),
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
                    '${Retailer.shop}\n${Retailer.id} · ${Retailer.city}',
                  ),
                  const Divider(height: 22),
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
                    style: body(11, color: const Color(0xFF737189)),
                  ),
                  Text(
                    c.both(
                      'Demo receipt with mock data. Help: 1800 000 0000',
                      'मॉक डेटा वाली डेमो रसीद। सहायता: 1800 000 0000',
                    ),
                    textAlign: TextAlign.center,
                    style: body(11, color: const Color(0xFF737189)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: share
              ? Row(
                  children: [
                    Expanded(
                      child: ApButton(
                        label: c.t('share'),
                        icon: ApIcons.share,
                        onPressed: () => c.sim('share'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ApButton(
                        label:
                            '${c.t('print')} (${c.both('Bluetooth', 'ब्लूटूथ')})',
                        kind: ApButtonKind.outline,
                        icon: ApIcons.printer,
                        onPressed: () => c.sim('print'),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    TextButton(
                      onPressed: () => copyText(context, x.ref, c.t('copied')),
                      child: Text(c.t('copy_ref')),
                    ),
                    const Spacer(),
                    ApButton(
                      label: c.both('Download PDF', 'PDF डाउनलोड'),
                      kind: ApButtonKind.outline,
                      icon: ApIcons.download,
                      onPressed: () => c.sim('download'),
                    ),
                    const SizedBox(width: 8),
                    ApButton(
                      label: c.t('print'),
                      icon: ApIcons.printer,
                      onPressed: () => c.sim('print'),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHead(c.t('move_bank')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  prefix: const Text('₹'),
                ),
                TextButton(
                  onPressed: () => setState(
                    () => amt.text = c.data.wallet.aeps.floor().toString(),
                  ),
                  child: Text(
                    '${c.both('All', 'पूरा')} ${inr(c.data.wallet.aeps, dec: 0)}',
                  ),
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
                for (final a in active)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: bankById(a.bank) == null
                        ? null
                        : BankMono(bankById(a.bank)!),
                    title: Text('${bankById(a.bank)?.name ?? ''} ••${a.last4}'),
                    subtitle: Text(a.holder),
                    trailing: Icon(ApIcons.check, color: p.success),
                  ),
                Notice(
                  tone: NoticeTone.warn,
                  child: Text(
                    c.both(
                      'Settlement charges and timing depend on the partner and are not confirmed.',
                      'सेटलमेंट शुल्क और समय पार्टनर पर निर्भर हैं, अभी तय नहीं।',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: c.closeSheet,
                      child: Text(c.t('cancel')),
                    ),
                    const SizedBox(width: 8),
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
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHead(c.t('add_bank')),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: c.closeSheet,
                        child: Text(c.t('cancel')),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ApButton(
                          label: c.both(
                            'Add and verify',
                            'जोड़ें और सत्यापित करें',
                          ),
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
              ),
            ),
          ],
        ),
      ),
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _SheetHead(c.both('Demo scenarios', 'डेमो स्थितियाँ')),
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
                RadioListTile<DeviceState>(value: d, title: Text(_dev(c, d))),
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
              'Demo login: AP100245 / Demo@123 / OTP 246810. Aadhaar is cleared when a transaction is submitted and is never stored.',
              'डेमो: AP100245 / Demo@123 / OTP 246810। आधार सबमिट पर मिट जाता है और सेव नहीं होता।',
            ),
            style: body(12, color: ap(context).ink2),
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
