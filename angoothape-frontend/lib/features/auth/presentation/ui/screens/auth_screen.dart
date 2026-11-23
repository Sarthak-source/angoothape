import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/responsive/layout_service.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/presentation/controllers/app_controller.dart';
import '../../../../../core/theme/ap_icons.dart';

class AuthHost extends StatelessWidget {
  const AuthHost({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, _) {
        if (c.route != 'welcome') c.back();
      },
      child: Scaffold(
        backgroundColor: ap(context).canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            switch (c.route) {
              'login' => const LoginScreen(),
              'otp' => const OtpScreen(),
              'join' => const SizedBox.shrink(),
              _ => const WelcomeScreen(),
            },
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final hero = _Hero(c: c, tall: wide);
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
                child: _LangCard(
                  title: 'English',
                  sub: 'English',
                  selected: c.lang == 'en',
                  onTap: () => c.setLang('en'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LangCard(
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
                child: _LangCard(
                  title: 'বাংলা',
                  sub: c.t('soon'),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LangCard(
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

class _Hero extends StatelessWidget {
  const _Hero({required this.c, required this.tall});
  final AppController c;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1B1944),
      child: Stack(
        fit: tall ? StackFit.expand : StackFit.loose,
        children: [
          const Positioned(
            right: -160,
            top: -160,
            width: 420,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x73F2662F), Color(0x00F2662F)],
                  stops: [0, 0.65],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -30,
            width: 150,
            height: 150,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xF2F2662F),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 80,
            top: 30,
            width: 18,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF4FB477),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: tall
                ? const EdgeInsets.all(56)
                : const EdgeInsets.fromLTRB(24, 36, 24, 30),
            child: Column(
              mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Wordmark(height: 42, onDark: true),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    c.t('welcome_t'),
                    style: display(
                      tall ? 34 : 26,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Text(
                    c.t('welcome_p'),
                    style: body(
                      15,
                      color: const Color(0xFFC6C4EC),
                      height: 1.5,
                    ),
                  ),
                ),
                if (tall) ...[
                  const SizedBox(height: 24),
                  _feat(ApIcons.fingerprint, c.t('f1')),
                  const SizedBox(height: 12),
                  _feat(ApIcons.doc, c.t('f2')),
                  const SizedBox(height: 12),
                  _feat(ApIcons.headset, c.t('f3')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feat(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: const Color(0xFFFBA078), size: 22),
      const SizedBox(width: 12),
      Expanded(
        child: Text(text, style: body(14, color: const Color(0xFFE2E1F5))),
      ),
    ],
  );
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.title,
    required this.sub,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });
  final String title;
  final String sub;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? p.primarySoft : p.card,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? p.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: display(17, color: p.ink)),
                Text(sub, style: body(12, color: p.ink2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
            onPressed: () => c.sim('forgot'),
            child: Text(c.t('forgot')),
          ),
        ],
      ),
    );
    if (!wide) {
      return ListView(children: [const _MiniHero(), form]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 3, child: _LoginArt()),
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

class _LoginArt extends StatelessWidget {
  const _LoginArt();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Image(
        image: AssetImage('assets/images/login_side.jpg'),
        fit: BoxFit.cover,
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final code = TextEditingController();
  final focus = FocusNode();
  Timer? timer;
  String _pushed = '';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final otp = AppScope.of(context).login.otp;
    if (otp != _pushed) {
      _pushed = otp;
      code.text = otp;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final left = c.login.resendAt
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 99);
    final wide = const LayoutService()
        .resolve(MediaQuery.sizeOf(context).width)
        .twoColumnForms;
    final form = Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(onPressed: c.back, child: Text(c.t('back'))),
          Text(c.t('otp_t'), style: display(24, color: p.ink)),
          const SizedBox(height: 6),
          Text(c.t('otp_sent'), style: body(14, color: p.ink2)),
          if (c.login.demoOtp != null) ...[
            const SizedBox(height: 8),
            Text(
              '${c.t('otp_demo')}: ${c.login.demoOtp}',
              style: body(13, color: p.accentText),
            ),
          ],
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => focus.requestFocus(),
            child: Stack(
              children: [
                Row(
                  children: List.generate(6, (i) {
                    final ch = i < code.text.length ? code.text[i] : '';
                    final cur = i == code.text.length;
                    return Expanded(
                      child: Container(
                        height: 58,
                        margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cur ? p.primarySoft : p.canvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cur ? p.primary : p.line,
                            width: 1.5,
                          ),
                        ),
                        child: Text(ch, style: display(24, color: p.ink)),
                      ),
                    );
                  }),
                ),
                Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: code,
                    focusNode: focus,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      setState(() {});
                      if (v.length == 6) c.submitOtp(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (c.login.otpErr.isNotEmpty) HelpText(c.login.otpErr, error: true),
          const SizedBox(height: 18),
          ApButton(
            label: c.t('verify'),
            expand: true,
            busy: c.login.busy,
            onPressed: () => c.submitOtp(code.text),
          ),
          const SizedBox(height: 12),
          Center(
            child: left > 0
                ? Text(
                    '${c.t('resend_in')} 0:${left.toString().padLeft(2, '0')}',
                    style: body(13, color: p.ink2),
                  )
                : TextButton(
                    onPressed: c.resendOtp,
                    child: Text(c.t('resend')),
                  ),
          ),
        ],
      ),
    );
    if (!wide) {
      return ListView(
        children: [
          const _MiniHero(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              decoration: cardBox(p),
              child: form,
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 3, child: _LoginArt()),
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
                  decoration: cardBox(p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Wordmark(height: 36),
                      ),
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

class _MiniHero extends StatelessWidget {
  const _MiniHero();
  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      color: const Color(0xFF1B1944),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wordmark(height: 36, onDark: true),
          const SizedBox(height: 12),
          Text(c.t('welcome_t'), style: display(22, color: Colors.white)),
        ],
      ),
    );
  }
}
