import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/utils/format.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../controllers/join_controller.dart';

class KycStep extends StatefulWidget {
  const KycStep({super.key});
  @override
  State<KycStep> createState() => KycStepState();
}

class KycStepState extends State<KycStep> {
  final pan = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final JoinController flow = AppScope.of(context);
    final v = flow.join.f['pan'] ?? '';
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
    final JoinController flow = c;
    final p = ap(context);
    final j = flow.join;
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
    void submit() => flow.joinNext({'pan': pan.text.trim().toUpperCase()});
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
            onPressed: () => flow.runEkyc(pan.text),
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
            child: KycUpload(
              done: j.docs.containsKey(d.$1),
              title: d.$2,
              icon: d.$3,
              file: j.docs[d.$1],
              onTap: () => flow.attachDoc(d.$1, '${d.$1}-demo.jpg'),
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
          onChanged: (v) => flow.setAgree(v ?? false),
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
            SizedBox(width: 280, child: KycAside(onSubmit: submit)),
          ],
        ),
      ),
    );
  }
}

class KycAside extends StatelessWidget {
  const KycAside({super.key, required this.onSubmit});
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

class KycUpload extends StatelessWidget {
  const KycUpload({super.key, 
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
