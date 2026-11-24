import 'package:flutter/material.dart';

import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';
import '../../../../../core/theme/ap_icons.dart';

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
