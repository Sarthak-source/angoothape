import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/fingerprint_pad.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final d = c.scenario.device;
    final ready = d == DeviceState.ready;
    final steps = deviceGuide(c.devTab, c.lang);
    final faqs = deviceFaqs[c.lang] ?? deviceFaqs['en'] ?? const <(String, List<String>)>[];

    final scanner = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: cardBox(p),
      constraints: const BoxConstraints(minHeight: 280),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FingerprintPad(
            state: c.devTest == 'run'
                ? PadState.capturing
                : c.devTest == 'done'
                ? PadState.good
                : ready
                ? PadState.place
                : PadState.bad,
          ),
          const SizedBox(height: 14),
          Text(
            c.devTest == 'run'
                ? c.t('capturing')
                : c.devTest == 'done'
                ? c.both('Capture quality good', 'स्कैन अच्छा है')
                : c.t('test_cap'),
            style: display(18, color: p.ink),
            textAlign: TextAlign.center,
          ),
          if (c.devTest != 'run') ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                c.devTest == 'done'
                    ? c.both(
                        'Quality score 78/100 (demo)',
                        'गुणवत्ता स्कोर 78/100 (डेमो)',
                      )
                    : c.both(
                        'Place your own finger to check the scanner works.',
                        'अपनी उंगली रखकर जाँचें कि स्कैनर ठीक काम कर रहा है।',
                      ),
                style: body(14, color: p.ink2, height: 1.45),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            if (c.devTest == 'done')
              ApButton(
                label: c.t('test_cap'),
                kind: ApButtonKind.outline,
                onPressed: c.testCapture,
              )
            else if (ready)
              ApButton(
                label: c.t('test_cap'),
                icon: ApIcons.fingerprintSimple,
                onPressed: c.testCapture,
              )
            else
              ApButton(
                label: c.t('check_again'),
                icon: ApIcons.refresh,
                onPressed: c.recheckDevicePage,
              ),
          ],
        ],
      ),
    );

    final guide = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DevTabs(
          value: c.devTab,
          onChanged: c.setDevTab,
          items: const [
            ('web', 'Web (Windows)'),
            ('android', 'Android'),
            ('ios', 'iOS'),
          ],
        ),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            child: Text(
              '${i + 1}.  ${steps[i]}',
              style: body(14, color: p.ink, height: 1.5),
            ),
          ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              c.both(
                'Supported scanner models and platform support are an integration dependency to confirm.',
                'डिवाइस मॉडल और प्लेटफ़ॉर्म सपोर्ट एक इंटीग्रेशन निर्भरता है।',
              ),
              style: body(12.5, color: p.ink2),
            ),
            AssumeTag(label: c.both('Dependency', 'Dependency')),
          ],
        ),
      ],
    );

    return ScreenPad(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.t('device_t'), style: display(22, color: p.ink)),
            const SizedBox(height: 18),
            Notice(
              padding: const EdgeInsets.all(18),
              tone: ready
                  ? NoticeTone.ok
                  : d == DeviceState.disconnected
                  ? NoticeTone.warn
                  : NoticeTone.err,
              icon: ready
                  ? ApIcons.shield
                  : d == DeviceState.disconnected
                  ? ApIcons.usb
                  : ApIcons.alert,
              title: ready
                  ? c.t('dev_ready')
                  : c.t(
                      d == DeviceState.disconnected
                          ? 'dev_off_t'
                          : 'dev_perm_t',
                    ),
              child: Text(
                ready
                    ? c.both(
                        'L1 RD fingerprint scanner (demo) · RD Service running · checked just now',
                        'L1 RD फ़िंगरप्रिंट स्कैनर (डेमो) · RD Service चालू · आखिरी जाँच अभी',
                      )
                    : c.t(
                        d == DeviceState.disconnected
                            ? 'dev_off_p'
                            : 'dev_perm_p',
                      ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, box) {
                if (box.maxWidth < 700) {
                  return Column(
                    children: [scanner, const SizedBox(height: 16), guide],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: scanner),
                    const SizedBox(width: 16),
                    Expanded(child: guide),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 10),
              child: Text(c.t('trouble'), style: display(16, color: p.ink)),
            ),
            _Accord(items: faqs),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ApButton(
                  label: c.both('Request repair', 'मरम्मत अनुरोध'),
                  kind: ApButtonKind.outline,
                  icon: ApIcons.settings,
                  onPressed: () => c.deviceRequest('repair'),
                ),
                ApButton(
                  label: c.both('Get a device', 'नया डिवाइस'),
                  kind: ApButtonKind.ghost,
                  icon: ApIcons.device,
                  onPressed: () => c.deviceRequest('order'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DevTabs extends StatelessWidget {
  const _DevTabs({
    required this.value,
    required this.onChanged,
    required this.items,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          for (final item in items)
            InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: value == item.$1 ? p.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  item.$2,
                  style: body(
                    14,
                    weight: FontWeight.w600,
                    color: value == item.$1 ? p.primary : p.ink2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Accord extends StatefulWidget {
  const _Accord({required this.items});
  final List<(String, List<String>)> items;
  @override
  State<_Accord> createState() => _AccordState();
}

class _AccordState extends State<_Accord> {
  int? open;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.line),
            InkWell(
              onTap: () => setState(() => open = open == i ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      Icon(ApIcons.help, size: 20, color: p.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.items[i].$1,
                          style: body(
                            14,
                            weight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: open == i ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(ApIcons.chevD, size: 20, color: p.ink2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (open == i)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var n = 0; n < widget.items[i].$2.length; n++)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 6),
                        child: Text(
                          '${n + 1}.  ${widget.items[i].$2[n]}',
                          style: body(14, color: p.ink2, height: 1.55),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

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

class HelpNewScreen extends StatefulWidget {
  const HelpNewScreen({super.key});
  @override
  State<HelpNewScreen> createState() => _HelpNewScreenState();
}

class _HelpNewScreenState extends State<HelpNewScreen> {
  final msg = TextEditingController();
  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final r = c.newReq;
    final linked = c.txnByRef(r.ref.isEmpty ? null : r.ref);
    final typeErr = r.tried && r.type.isEmpty;
    final msgErr = r.tried && msg.text.trim().length < 10;
    final issueLabels = issues[c.lang] ?? issues['en'] ?? const <String>[];
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('new_req'), style: display(22, color: p.ink)),
          const SizedBox(height: 12),
          FieldLabel(c.t('linked_txn')),
          if (linked != null)
            ListTile(
              tileColor: p.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(linked.ref),
              subtitle: Text(
                '${c.t(linked.svc)} · ${bankById(linked.bank)?.short ?? ''}',
              ),
              trailing: IconButton(
                onPressed: c.unlinkReq,
                icon: const Icon(ApIcons.close),
              ),
            )
          else
            ApDropdown<String>(
              value: r.ref,
              padding: EdgeInsets.zero,
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(
                    c.both(
                      'None / choose a transaction',
                      'कोई लेन-देन नहीं / चुनें',
                    ),
                  ),
                ),
                for (final z in c.data.tx.take(10))
                  DropdownMenuItem(
                    value: z.ref,
                    child: Text(
                      '${z.ref} · ${c.t(z.svc)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => c.setReqRef(v ?? ''),
            ),
          const SizedBox(height: 12),
          FieldLabel(c.t('issue_type')),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < issueLabels.length; i++)
                ApChip(
                  label: issueLabels[i],
                  selected: r.type == '$i',
                  onTap: () => c.setReqType('$i'),
                ),
            ],
          ),
          if (typeErr)
            HelpText(
              c.both('Choose what went wrong.', 'समस्या का प्रकार चुनें।'),
              error: true,
            ),
          const SizedBox(height: 12),
          ApTextField(
            label: c.t('describe'),
            controller: msg,
            minLines: 3,
            maxLines: 5,
            invalid: msgErr,
            padding: EdgeInsets.zero,
            hint: c.both(
              'e.g. Customer says money was debited but they did not receive cash.',
              'जैसे: ग्राहक कहते हैं पैसा कटा पर नकद नहीं मिला।',
            ),
          ),
          HelpText(
            msgErr
                ? c.both(
                    'Write at least 10 characters.',
                    'कम से कम 10 अक्षर लिखें।',
                  )
                : c.both(
                    "Don't type the customer's Aadhaar number.",
                    'आधार नंबर न लिखें।',
                  ),
            error: msgErr,
          ),
          const SizedBox(height: 16),
          ApButton(
            label: c.t('submit_req'),
            expand: true,
            onPressed: () => c.submitTicket(msg.text),
          ),
        ],
      ),
    );
  }
}

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    Ticket? k;
    for (final t in c.data.tickets) {
      if (t.id == c.params['id']) k = t;
    }
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
                    onPressed: () => c.go('txn', params: {'ref': k!.ref!}),
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return ScreenPad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('profile_t'), style: display(22, color: p.ink)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardBox(p),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ApPalette.indigo,
                  child: Text(
                    c.data.retailer.initials,
                    style: body(
                      16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.data.retailer.name, style: display(18, color: p.ink)),
                      Text(
                        '${c.data.retailer.shop} · ${c.data.retailer.id}',
                        style: body(12.5, color: p.ink2),
                      ),
                      Text(c.data.retailer.city, style: body(12.5, color: p.ink2)),
                    ],
                  ),
                ),
                StatusBadge(TxStatus.success),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${c.both('Role', 'भूमिका')}: ${c.data.retailer.role}',
            style: body(14),
          ),
          Text(
            '${c.both('Distributor', 'डिस्ट्रीब्यूटर')}: ${c.data.retailer.distributor}',
            style: body(14, color: p.ink2),
          ),
          Text(
            '${c.t('mobile')}: ${c.data.retailer.mobile}',
            style: body(14, color: p.ink2),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(ApIcons.edit, color: p.primary),
            title: Text(
              c.both('Edit profile', 'प्रोफ़ाइल बदलें'),
              style: body(14, weight: FontWeight.w700),
            ),
            trailing: const Icon(ApIcons.chevR),
            onTap: c.openProfile,
          ),
          _row(
            p,
            ApIcons.globe,
            c.t('language'),
            c.lang == 'en' ? 'English' : 'हिन्दी',
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'hi', label: Text('हिं')),
              ],
              selected: {c.lang},
              onSelectionChanged: (s) => c.setLang(s.first),
            ),
          ),
          _row(
            p,
            ApIcons.keyboard,
            c.t('text_size'),
            c.both('For easier reading', 'पढ़ने में आसानी के लिए'),
            trailing: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1, label: Text('A')),
                ButtonSegment(value: 1.15, label: Text('A+')),
              ],
              selected: {c.scale},
              onSelectionChanged: (s) => c.setScale(s.first),
            ),
          ),
          SwitchListTile(
            value: c.dark,
            onChanged: (_) => c.toggleDark(),
            title: Text(
              c.t('dark_prev'),
              style: body(14, weight: FontWeight.w600),
            ),
            subtitle: Text(
              c.both(
                'Tokens ready; light mode is the primary design',
                'टोकन तैयार; मुख्य डिज़ाइन लाइट मोड है',
              ),
              style: body(12, color: p.ink2),
            ),
          ),
          ListTile(
            leading: Icon(ApIcons.sparkle, color: p.primary),
            title: Text(
              c.both('Demo scenarios', 'डेमो स्थितियाँ'),
              style: body(14, weight: FontWeight.w700),
            ),
            subtitle: Text(
              c.both(
                'Next outcome, device and fingerprint capture',
                'अगला परिणाम, डिवाइस और फ़िंगरप्रिंट',
              ),
              style: body(12, color: p.ink2),
            ),
            trailing: const Icon(ApIcons.chevR),
            onTap: c.openScenarios,
          ),
          ListTile(
            leading: const Icon(ApIcons.bank),
            title: Text(c.t('banks_t')),
            trailing: const Icon(ApIcons.chevR),
            onTap: () => c.nav('banks'),
          ),
          ListTile(
            leading: const Icon(ApIcons.fingerprint),
            title: Text(c.t('device_t')),
            trailing: const Icon(ApIcons.chevR),
            onTap: () => c.nav('device'),
          ),
          ListTile(
            leading: const Icon(ApIcons.lock),
            title: Text(c.both('Password & security', 'पासवर्ड और सुरक्षा')),
            onTap: c.openPassword,
          ),
          ListTile(
            leading: Icon(ApIcons.refresh, color: p.warning),
            title: Text(c.t('reset_demo')),
            onTap: c.resetDemo,
          ),
          ListTile(
            leading: Icon(ApIcons.logout, color: p.error),
            title: Text(
              c.t('logout'),
              style: body(14, weight: FontWeight.w700, color: p.error),
            ),
            onTap: c.logout,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              c.both('angoothaPe · live session data', 'angoothaPe · लाइव सेशन डेटा'),
              style: body(12, color: p.ink3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    ApPalette p,
    IconData icon,
    String title,
    String sub, {
    required Widget trailing,
  }) => ListTile(
    leading: Icon(icon, color: p.primary),
    title: Text(title, style: body(14, weight: FontWeight.w600)),
    subtitle: Text(sub, style: body(12, color: p.ink2)),
    trailing: trailing,
  );
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final dev = switch (c.scenario.device) {
      DeviceState.ready => c.t('dev_ready'),
      DeviceState.disconnected => c.t('dev_off'),
      DeviceState.permission => c.t('dev_perm'),
    };
    return ScreenPad(
      child: Column(
        children: [
          _item(
            context,
            ApIcons.device,
            c.t('nav_device'),
            dev,
            () => c.nav('device'),
          ),
          _item(
            context,
            ApIcons.bank,
            c.t('nav_banks'),
            c.both('Settlement accounts', 'सेटलमेंट खाते'),
            () => c.nav('banks'),
          ),
          _item(
            context,
            ApIcons.headset,
            c.t('nav_help'),
            c.both('FAQs, support requests', 'आम सवाल, अनुरोध'),
            () => c.nav('help'),
          ),
          _item(
            context,
            ApIcons.user,
            c.t('nav_profile'),
            c.both('Language, text size, log out', 'भाषा, अक्षर आकार, लॉग आउट'),
            () => c.nav('profile'),
          ),
          _item(
            context,
            ApIcons.grid,
            c.t('nav_services'),
            c.t('soon'),
            () => c.nav('services'),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    final p = ap(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: cardBox(p),
      child: ListTile(
        leading: Icon(icon, color: p.primary),
        title: Text(title, style: body(15, weight: FontWeight.w600)),
        subtitle: Text(sub, style: body(12, color: p.ink2)),
        trailing: const Icon(ApIcons.chevR),
        onTap: onTap,
      ),
    );
  }
}

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
