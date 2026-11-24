
import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';

import '../widgets/lang_card.dart';
import '../widgets/welcome_hero.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final hero = WelcomeHero(c: c, tall: wide);
    final form = Padding(
      padding: wide
          ? const EdgeInsets.all(48)
          : const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.t('choose_lang'), style: display(22, color: p.ink)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: LangCard(
                  title: 'English',
                  sub: 'English',
                  selected: c.lang == 'en',
                  onTap: () => c.setLang('en'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LangCard(
                  title: 'हिन्दी',
                  sub: 'Hindi',
                  selected: c.lang == 'hi',
                  onTap: () => c.setLang('hi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LangCard(
                  title: 'বাংলা',
                  sub: c.t('soon'),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LangCard(
                  title: 'मराठी',
                  sub: c.t('soon'),
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(c.t('more_langs'), style: body(12.5, color: p.ink2)),
          const SizedBox(height: 18),
          ApButton(
            label: c.t('login'),
            expand: true,
            onPressed: () => c.go('login'),
          ),
          const SizedBox(height: 10),
          ApButton(
            label: c.t('join'),
            kind: ApButtonKind.outline,
            expand: true,
            onPressed: c.startJoin,
          ),
        ],
      ),
    );
    final panel = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: form,
    );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 21, child: hero),
          Expanded(
            flex: 20,
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Center(child: panel),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: [
        hero,
        Center(child: panel),
      ],
    );
  }
}
