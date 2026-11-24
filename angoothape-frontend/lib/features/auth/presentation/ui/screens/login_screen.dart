
import 'package:flutter/material.dart';

import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/theme/ap_icons.dart';

import '../widgets/auth_mini_hero.dart';
import '../widgets/login_art.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController();
  final pw = TextEditingController();
  String _pushedId = '';
  String _pushedPw = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppScope.of(context).login;
    if (l.id != _pushedId) {
      _pushedId = l.id;
      id.text = l.id;
    }
    if (l.pw != _pushedPw) {
      _pushedPw = l.pw;
      pw.text = l.pw;
    }
  }

  @override
  void dispose() {
    id.dispose();
    pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final wide = const LayoutService()
        .resolve(MediaQuery.sizeOf(context).width)
        .twoColumnForms;
    final fieldFill = wide ? p.canvas : null;
    final form = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: c.back,
            icon: const Icon(ApIcons.chevL),
            label: Text(c.t('back')),
          ),
          Text(c.t('login_t'), style: display(24, color: p.ink)),
          const SizedBox(height: 16),
          ApTextField(
            label: c.t('agent_id'),
            controller: id,
            caps: true,
            fill: fieldFill,
            padding: const EdgeInsets.only(bottom: 14),
            prefix: Icon(ApIcons.user, color: p.ink3),
          ),
          ApTextField(
            label: c.t('password'),
            controller: pw,
            obscure: !c.login.showPw,
            fill: fieldFill,
            error: c.login.err.isEmpty ? null : c.login.err,
            prefix: Icon(ApIcons.lock, color: p.ink3),
            suffix: TextButton(
              onPressed: c.togglePw,
              child: Text(c.login.showPw ? c.t('hide') : c.t('show')),
            ),
          ),
          const SizedBox(height: 16),
          ApButton(
            label: c.t('cont'),
            expand: true,
            busy: c.login.busy,
            onPressed: () => c.submitLogin(id.text, pw.text),
          ),
          TextButton(
            onPressed: c.startForgot,
            child: Text(c.t('forgot')),
          ),
        ],
      ),
    );
    if (!wide) {
      return ListView(children: [const AuthMiniHero(), form]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 3, child: LoginArt()),
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                  decoration: cardBox(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wordmark(height: 36),
                      const SizedBox(height: 8),
                      Text(c.t('welcome_t'), style: body(14, color: p.ink2)),
                      form,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
