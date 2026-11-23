import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final steps = c.hi
        ? ['भूमिका', 'व्यवसाय', 'KYC', 'स्थिति']
        : ['Role', 'Business', 'KYC', 'Status'];
    return Scaffold(
      backgroundColor: p.canvas,
      body: SafeArea(
        child: ScreenPad(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: c.back,
                    icon: const Icon(ApIcons.chevL),
                    label: Text(c.t('back')),
                  ),
                  const Spacer(),
                  const Wordmark(height: 26),
                ],
              ),
              const SizedBox(height: 8),
              StepperBar(
                labels: steps,
                index: c.join.step,
                doneLast: c.join.step == 3 && c.join.approved,
              ),
              const SizedBox(height: 18),
              switch (c.join.step) {
                0 => const _RoleStep(),
                1 => const _BusinessStep(),
                2 => const _KycStep(),
                _ => const _StatusStep(),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleStep extends StatelessWidget {
  const _RoleStep();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final roles = [
      (
        'retailer',
        ApIcons.store,
        c.both('Retailer / Franchisee', 'रिटेलर / फ़्रैंचाइज़ी'),
        c.both(
          'Serve customers at your shop: AEPS cash withdrawal, balance enquiry and more.',
          'अपनी दुकान पर ग्राहकों को सेवा दें: AEPS नकद निकासी, बैलेंस जाँच और बहुत कुछ।',
        ),
      ),
      (
        'distributor',
        ApIcons.users,
        c.both('Distributor', 'डिस्ट्रीब्यूटर'),
        c.both(
          'Onboard and support retailers in your area, approve their applications and track performance.',
          'अपने क्षेत्र के रिटेलर जोड़ें, उनके आवेदन स्वीकृत करें और प्रदर्शन देखें।',
        ),
      ),
      (
        'super',
        ApIcons.network,
        c.both('Super Distributor', 'सुपर डिस्ट्रीब्यूटर'),
        c.both(
          'Manage distributors across districts or a state and oversee the network.',
          'ज़िलों या राज्य में डिस्ट्रीब्यूटर प्रबंधित करें और नेटवर्क की निगरानी करें।',
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.both(
            'How do you want to join?',
            'आप किस रूप में जुड़ना चाहते हैं?',
          ),
          style: display(22, color: p.ink),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              c.both(
                'Permissions and approval rules shown here are proposals.',
                'अनुमतियाँ और स्वीकृति नियम प्रस्तावित हैं।',
              ),
              style: body(13, color: p.ink2),
            ),
            const AssumeTag(),
          ],
        ),
        const SizedBox(height: 14),
        for (final r in roles) ...[
          _RoleCard(
            selected: c.join.role == r.$1,
            icon: r.$2,
            title: r.$3,
            blurb: r.$4,
            onTap: () => c.setRole(r.$1),
          ),
          const SizedBox(height: 10),
        ],
        Notice(
          tone: NoticeTone.info,
          child: Text(
            c.both(
              'Retailers are approved by their distributor; distributors and super distributors by the angoothaPe operations team.',
              'रिटेलर को उनका डिस्ट्रीब्यूटर स्वीकृत करता है; डिस्ट्रीब्यूटर और सुपर डिस्ट्रीब्यूटर को angoothaPe ऑपरेशंस टीम।',
            ),
          ),
        ),
        const SizedBox(height: 16),
        ApButton(
          label: c.t('cont'),
          expand: true,
          onPressed: () => c.joinNext(const {}),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String blurb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Material(
      color: selected ? p.primarySoft : p.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? p.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: display(16, color: p.ink)),
                    const SizedBox(height: 4),
                    Text(blurb, style: body(13, color: p.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessStep extends StatefulWidget {
  const _BusinessStep();
  @override
  State<_BusinessStep> createState() => _BusinessStepState();
}

class _BusinessStepState extends State<_BusinessStep> {
  final f = <String, TextEditingController>{};
  String type = '';
  String state = '';
  String size = '';

  @override
  void initState() {
    super.initState();
    for (final k in [
      'name',
      'mobile',
      'biz',
      'addr',
      'pin',
      'email',
      'dist',
      'area',
      'gst',
    ]) {
      f[k] = TextEditingController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final src = AppScope.of(context).join.f;
    for (final e in f.entries) {
      final v = src[e.key] ?? '';
      if (e.value.text.isEmpty && v.isNotEmpty) e.value.text = v;
    }
    type = type.isEmpty ? (src['type'] ?? '') : type;
    state = state.isEmpty ? (src['state'] ?? '') : state;
    size = size.isEmpty ? (src['size'] ?? '') : size;
  }

  @override
  void dispose() {
    for (final c in f.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> collect() => {
    for (final e in f.entries) e.key: e.value.text.trim(),
    'type': type,
    'state': state,
    'size': size,
  };

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final j = c.join;
    final retailer = j.role == 'retailer';
    String? err(String key, {String? custom, bool bad = false}) {
      if (!j.tried) return null;
      if (bad || (collect()[key] ?? '').isEmpty) {
        return custom ?? c.t('required');
      }
      return null;
    }

    final width = MediaQuery.sizeOf(context).width;
    final onCard = width >= 700;
    final showSide = width >= 1024;
    final formMax = showSide ? 720.0 : (onCard ? 680.0 : double.infinity);
    final fieldFill = onCard ? p.canvas : null;
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tf(
          c,
          p,
          'name',
          c.both('Full name (as on PAN)', 'पूरा नाम (PAN के अनुसार)'),
          error: err('name'),
          fill: fieldFill,
        ),
        _tf(
          c,
          p,
          'mobile',
          c.both('Mobile number', 'मोबाइल नंबर'),
          prefix: '+91',
          digits: 10,
          fill: fieldFill,
          error: j.tried && !validMobile(f['mobile']!.text)
              ? c.t('e_mobile')
              : null,
        ),
        _tf(
          c,
          p,
          'biz',
          c.both('Shop / business name', 'दुकान / व्यवसाय का नाम'),
          error: err('biz'),
          fill: fieldFill,
        ),
        _drop(
          c,
          p,
          c.both('Business type', 'व्यवसाय का प्रकार'),
          type,
          const [
            'Kirana / General store',
            'Mobile & recharge shop',
            'Common Service Centre (CSC)',
            'Pharmacy',
            'Other',
          ],
          (v) => setState(() => type = v ?? ''),
          error: err('type', bad: type.isEmpty),
          fill: fieldFill,
        ),
        _tf(
          c,
          p,
          'addr',
          c.both('Shop address', 'दुकान का पता'),
          error: err('addr'),
          fill: fieldFill,
        ),
        _tf(
          c,
          p,
          'pin',
          c.both('PIN code', 'पिन कोड'),
          digits: 6,
          fill: fieldFill,
          error: j.tried && !validPin(f['pin']!.text)
              ? c.both(
                  'Enter a valid 6-digit PIN code.',
                  'सही 6 अंकों का पिन कोड डालें।',
                )
              : null,
        ),
        _drop(
          c,
          p,
          c.both('State', 'राज्य'),
          state,
          const [
            'Uttar Pradesh',
            'Bihar',
            'Madhya Pradesh',
            'Rajasthan',
            'Maharashtra',
            'West Bengal',
            'Other',
          ],
          (v) => setState(() => state = v ?? ''),
          error: err('state', bad: state.isEmpty),
          fill: fieldFill,
        ),
        _tf(c, p, 'email', 'Email  (${c.t('optional')})', fill: fieldFill),
        if (retailer)
          _tf(
            c,
            p,
            'dist',
            c.both('Distributor code', 'डिस्ट्रीब्यूटर कोड'),
            assume: true,
            fill: fieldFill,
          )
        else
          _tf(
            c,
            p,
            'area',
            c.both('Operating area (districts)', 'कार्य क्षेत्र (ज़िले)'),
            assume: true,
            error: err('area'),
            fill: fieldFill,
          ),
        if (!retailer) _tf(c, p, 'gst', 'GSTIN', assume: true, fill: fieldFill),
        if (!retailer)
          _drop(
            c,
            p,
            c.both('Expected network size', 'अनुमानित नेटवर्क आकार'),
            size,
            j.role == 'super'
                ? const [
                    '5–20 distributors',
                    '20–50 distributors',
                    '50+ distributors',
                  ]
                : const [
                    '10–50 retailers',
                    '50–200 retailers',
                    '200+ retailers',
                  ],
            (v) => setState(() => size = v ?? ''),
            fill: fieldFill,
          ),
        if (!showSide) ...[
          const SizedBox(height: 8),
          ApButton(
            label: c.t('cont'),
            expand: true,
            onPressed: () => c.joinNext(collect()),
          ),
        ],
      ],
    );
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(width >= 700 ? 22 : 0),
      decoration: width >= 700 ? cardBox(p) : null,
      child: fields,
    );
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: p.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(ApIcons.store, color: p.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.both('Business details', 'व्यवसाय का विवरण'),
                    style: display(22, color: p.ink),
                  ),
                  Text(
                    c.both(
                      'Tell us about your business to set up your account.',
                      'खाता बनाने के लिए अपने व्यवसाय के बारे में बताएँ।',
                    ),
                    style: body(13.5, color: p.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        card,
      ],
    );
    if (!showSide) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formMax),
          child: form,
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: 28),
            SizedBox(
              width: 280,
              child: _BusinessAside(onContinue: () => c.joinNext(collect())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(
    AppController c,
    ApPalette p,
    String key,
    String label, {
    String? prefix,
    int? digits,
    String? error,
    bool assume = false,
    Color? fill,
  }) {
    return ApTextField(
      label: label,
      labelTrailing: assume ? const AssumeTag() : null,
      controller: f[key],
      digits: digits,
      error: error,
      fill: fill,
      prefix: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 14, right: 4),
              child: Text(prefix, style: body(16, weight: FontWeight.w600)),
            ),
    );
  }

  Widget _drop(
    AppController c,
    ApPalette p,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? error,
    Color? fill,
  }) {
    return ApDropdown<String>(
      label: label,
      value: value.isEmpty ? null : value,
      hint: c.both('Select', 'चुनें'),
      error: error,
      fill: fill,
      items: [
        for (final e in items) DropdownMenuItem(value: e, child: Text(e)),
      ],
      onChanged: onChanged,
    );
  }
}

class _BusinessAside extends StatelessWidget {
  const _BusinessAside({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/business_shop.jpg',
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 18),
        _point(
          p,
          'assets/images/icon_grow.jpg',
          c.both('Grow your business', 'व्यवसाय बढ़ाएँ'),
          c.both(
            'Accept payments and manage easily.',
            'भुगतान लें और आसानी से प्रबंधित करें।',
          ),
        ),
        _point(
          p,
          'assets/images/icon_secure.jpg',
          c.both('Secure & trusted', 'सुरक्षित और भरोसेमंद'),
          c.both(
            'Your business information stays safe.',
            'आपकी व्यवसाय जानकारी सुरक्षित रहती है।',
          ),
        ),
        _point(
          p,
          'assets/images/icon_track.jpg',
          c.both('Track & manage', 'ट्रैक करें और प्रबंधित करें'),
          c.both(
            'Keep a record of your transactions.',
            'अपने लेन-देन का रिकॉर्ड रखें।',
          ),
        ),
        const SizedBox(height: 8),
        ApButton(
          label: c.t('cont'),
          icon: ApIcons.sendMoney,
          expand: true,
          onPressed: onContinue,
        ),
      ],
    );
  }

  Widget _point(ApPalette p, String asset, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(asset, width: 44, height: 44, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: body(14, weight: FontWeight.w700, color: p.ink),
                ),
                Text(sub, style: body(12.5, color: p.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KycStep extends StatefulWidget {
  const _KycStep();
  @override
  State<_KycStep> createState() => _KycStepState();
}

class _KycStepState extends State<_KycStep> {
  final pan = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final v = AppScope.of(context).join.f['pan'] ?? '';
    if (pan.text.isEmpty && v.isNotEmpty) pan.text = v;
  }

  @override
  void dispose() {
    pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final j = c.join;
    final retailer = j.role == 'retailer';
    final docs = [
      ('pancard', c.both('PAN card photo', 'PAN कार्ड की फ़ोटो'), ApIcons.id),
      (
        'shop',
        c.both('Shop photo with signboard', 'दुकान की फ़ोटो (बोर्ड सहित)'),
        ApIcons.camera,
      ),
      (
        'cheque',
        c.both('Cancelled cheque or passbook', 'कैंसल चेक या पासबुक'),
        ApIcons.bank,
      ),
      if (!retailer)
        (
          'gstc',
          c.both(
            'GST certificate or address proof',
            'GST प्रमाणपत्र या पते का प्रमाण',
          ),
          ApIcons.doc,
        ),
    ];
    final panErr = j.tried && !validPan(pan.text.trim().toUpperCase());
    final width = MediaQuery.sizeOf(context).width;
    final onCard = width >= 700;
    final showSide = width >= 1024;
    final formMax = showSide ? 720.0 : (onCard ? 680.0 : double.infinity);
    final fieldFill = onCard ? p.canvas : null;
    void submit() => c.joinNext({'pan': pan.text.trim().toUpperCase()});
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              c.both(
                'KYC provider and required documents are to be confirmed.',
                'KYC प्रदाता और ज़रूरी दस्तावेज़ों की पुष्टि होनी है।',
              ),
              style: body(13, color: p.ink2),
            ),
            const AssumeTag(),
          ],
        ),
        const SizedBox(height: 14),
        ApTextField(
          label: 'PAN',
          controller: pan,
          caps: true,
          maxLength: 10,
          fill: fieldFill,
          error: panErr
              ? c.both(
                  'Enter a valid PAN, e.g. ABCDE1234F.',
                  'सही PAN डालें, जैसे ABCDE1234F.',
                )
              : null,
        ),
        const SizedBox(height: 8),
        FieldLabel(c.both('Aadhaar eKYC', 'आधार eKYC')),
        if (j.ekyc)
          Notice(
            tone: NoticeTone.ok,
            icon: ApIcons.shield,
            child: Text(
              c.both(
                'Verified. Aadhaar number was not stored.',
                'सत्यापित। आधार नंबर सेव नहीं किया गया।',
              ),
            ),
          )
        else
          ApButton(
            label: c.both(
              'Verify with Aadhaar OTP',
              'आधार OTP से सत्यापित करें',
            ),
            kind: ApButtonKind.outline,
            icon: ApIcons.shield,
            expand: true,
            busy: j.ekycBusy,
            onPressed: () => c.runEkyc(pan.text),
          ),
        if (j.tried && !j.ekyc)
          HelpText(
            c.both('Complete Aadhaar eKYC.', 'आधार eKYC पूरा करें।'),
            error: true,
          ),
        const SizedBox(height: 12),
        for (final d in docs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Upload(
              done: j.docs.containsKey(d.$1),
              title: d.$2,
              icon: d.$3,
              file: j.docs[d.$1],
              onTap: () => c.attachDoc(d.$1, '${d.$1}-demo.jpg'),
            ),
          ),
        if (j.tried && docs.any((d) => !j.docs.containsKey(d.$1)))
          HelpText(
            c.both('Add all documents.', 'सभी दस्तावेज़ जोड़ें।'),
            error: true,
          ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: j.agree,
          onChanged: (v) => c.setAgree(v ?? false),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          tileColor: j.tried && !j.agree ? p.errorBg : p.card,
          title: Text(
            c.both(
              'I agree to the partner agreement and terms (draft).',
              'मैं पार्टनर समझौते और शर्तों से सहमत हूँ (ड्राफ़्ट)।',
            ),
            style: body(14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (!showSide) ...[
          const SizedBox(height: 12),
          ApButton(
            label: c.both('Submit application', 'आवेदन जमा करें'),
            expand: true,
            onPressed: submit,
          ),
        ],
      ],
    );
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(width >= 700 ? 22 : 0),
      decoration: width >= 700 ? cardBox(p) : null,
      child: fields,
    );
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KYC', style: display(22, color: p.ink)),
        const SizedBox(height: 14),
        card,
      ],
    );
    if (!showSide) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formMax),
          child: form,
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: 28),
            SizedBox(width: 280, child: _KycAside(onSubmit: submit)),
          ],
        ),
      ),
    );
  }
}

class _KycAside extends StatelessWidget {
  const _KycAside({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.primarySoft,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(ApIcons.shield, size: 72, color: p.primary),
        ),
        const SizedBox(height: 18),
        _line(
          p,
          ApIcons.id,
          c.both('PAN and eKYC', 'PAN और eKYC'),
          c.both(
            'We check identity. The Aadhaar number is not stored.',
            'पहचान जाँची जाती है। आधार नंबर सेव नहीं होता।',
          ),
        ),
        _line(
          p,
          ApIcons.camera,
          c.both('Shop documents', 'दुकान के दस्तावेज़'),
          c.both(
            'PAN card, shop photo, and a cancelled cheque.',
            'PAN कार्ड, दुकान की फ़ोटो और कैंसल चेक।',
          ),
        ),
        _line(
          p,
          ApIcons.doc,
          c.both('Partner terms', 'पार्टनर शर्तें'),
          c.both(
            'The agreement shown here is a draft.',
            'यहाँ दिखाया समझौता एक ड्राफ़्ट है।',
          ),
        ),
        const SizedBox(height: 8),
        ApButton(
          label: c.both('Submit application', 'आवेदन जमा करें'),
          icon: ApIcons.sendMoney,
          expand: true,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  Widget _line(ApPalette p, IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: p.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: body(14, weight: FontWeight.w700, color: p.ink),
                ),
                Text(sub, style: body(12.5, color: p.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Upload extends StatelessWidget {
  const _Upload({
    required this.done,
    required this.title,
    required this.icon,
    required this.onTap,
    this.file,
  });
  final bool done;
  final String title;
  final IconData icon;
  final String? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final c = AppScope.of(context);
    return Material(
      color: done ? p.successBg : p.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: done ? p.success : p.line,
              width: 1.4,
              style: done ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Icon(
                done ? ApIcons.check : icon,
                color: done ? p.success : p.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: body(14, weight: FontWeight.w600)),
                    Text(
                      file ??
                          c.both(
                            'Tap to attach a demo file · JPG/PDF',
                            'डेमो फ़ाइल जोड़ने के लिए टैप करें · JPG/PDF',
                          ),
                      style: body(12.5, color: p.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final approved = c.join.approved;
    final approver = c.join.role == 'retailer'
        ? c.both(
            'Approval by your distributor',
            'डिस्ट्रीब्यूटर द्वारा स्वीकृति',
          )
        : c.both(
            'Approval by angoothaPe operations',
            'angoothaPe ऑपरेशंस द्वारा स्वीकृति',
          );
    final role = switch (c.join.role) {
      'distributor' => c.both('Distributor', 'डिस्ट्रीब्यूटर'),
      'super' => c.both('Super Distributor', 'सुपर डिस्ट्रीब्यूटर'),
      _ => c.both('Retailer / Franchisee', 'रिटेलर / फ़्रैंचाइज़ी'),
    };
    Widget line(IconData icon, Color color, String title, String sub) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: body(14, weight: FontWeight.w600)),
                    Text(sub, style: body(12.5, color: p.ink2)),
                  ],
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        Icon(
          approved ? ApIcons.check : ApIcons.clock,
          size: 72,
          color: approved ? p.success : p.warning,
        ),
        const SizedBox(height: 8),
        Text(
          approved
              ? c.both('Your account is active', 'आपका खाता सक्रिय है')
              : c.both('Application submitted', 'आवेदन जमा हो गया'),
          style: display(24, color: p.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '${c.both('Application no.', 'आवेदन संख्या')} ${c.join.applicationId ?? '—'} · $role',
          style: body(13, color: p.ink2),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: cardBox(p),
          child: Column(
            children: [
              line(
                ApIcons.check,
                p.success,
                c.both('Application submitted', 'आवेदन जमा'),
                fmtDt(DateTime.now(), c.lang),
              ),
              line(
                approved ? ApIcons.check : ApIcons.clock,
                approved ? p.success : p.warning,
                c.both('Document check', 'दस्तावेज़ जाँच'),
                approved
                    ? c.both('Completed', 'पूरा')
                    : c.both(
                        'Usually 1–2 working days (example)',
                        'आमतौर पर 1–2 कार्यदिवस (उदाहरण)',
                      ),
              ),
              line(
                approved ? ApIcons.check : Icons.radio_button_unchecked,
                approved ? p.success : p.ink3,
                approver,
                approved
                    ? c.both('Approved', 'स्वीकृत')
                    : c.both('Waiting', 'प्रतीक्षा में'),
              ),
              line(
                approved ? ApIcons.check : Icons.radio_button_unchecked,
                approved ? p.success : p.ink3,
                c.both(
                  'Account activated, device setup',
                  'खाता सक्रिय, डिवाइस सेटअप',
                ),
                approved ? c.both('Log in to start', 'लॉग इन करें') : '—',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Notice(
          tone: NoticeTone.info,
          child: Text(
            c.both(
              'We will SMS you when the status changes. If more documents are needed, you will see it here.',
              'स्थिति बदलने पर हम SMS भेजेंगे। अतिरिक्त दस्तावेज़ माँगे जाएँ तो यहाँ दिखेगा।',
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (approved)
          ApButton(
            label: c.t('login'),
            expand: true,
            onPressed: () => c.go('login'),
          )
        else
          ApButton(
            label: c.both(
              'Demo: simulate approval',
              'डेमो: स्वीकृति सिम्युलेट करें',
            ),
            kind: ApButtonKind.soft,
            icon: ApIcons.sparkle,
            expand: true,
            onPressed: c.simulateApproval,
          ),
      ],
    );
  }
}
