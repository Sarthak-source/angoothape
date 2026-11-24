import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../controllers/join_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class BusinessStep extends StatefulWidget {
  const BusinessStep({super.key});
  @override
  State<BusinessStep> createState() => BusinessStepState();
}

class BusinessStepState extends State<BusinessStep> {
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
    final JoinController flow = AppScope.of(context);
    final src = flow.join.f;
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
    final JoinController flow = c;
    final p = ap(context);
    final j = flow.join;
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
            onPressed: () => flow.joinNext(collect()),
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
    final title = Row(
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
    );
    if (!showSide) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formMax),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 14),
              card,
            ],
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: card),
                const SizedBox(width: 28),
                SizedBox(
                  width: 280,
                  child: BusinessAside(
                    onContinue: () => flow.joinNext(collect()),
                  ),
                ),
              ],
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

class BusinessAside extends StatelessWidget {
  const BusinessAside({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/business_shop.jpg',
            height: 200,
            width: 280,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
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
