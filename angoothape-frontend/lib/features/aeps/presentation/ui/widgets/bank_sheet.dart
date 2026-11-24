import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/responsive/layout_scope.dart';
import '../../../../../core/theme/ap_icons.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/sheet_chrome.dart';
import '../../../../session/domain/entities/session_entities.dart';

class BankSheet extends StatefulWidget {
  const BankSheet({super.key});
  @override
  State<BankSheet> createState() => BankSheetState();
}

class BankSheetState extends State<BankSheet> {
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
        SheetHead(c.t('choose_bank')),
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
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 80,
                      ),
                  children: [
                    for (final b in pop)
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
                                  color: c.aeps.bank == b.id
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
