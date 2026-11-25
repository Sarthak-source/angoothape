import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/palette.dart';
import 'core/widgets/app_widgets.dart';
import 'core/di.dart';
import 'features/auth/presentation/ui/screens/auth_host.dart';
import 'features/home/presentation/ui/screens/home_shell.dart';
import 'features/onboarding/presentation/ui/screens/join_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AngoothaPeApp()));
}

class AngoothaPeApp extends ConsumerWidget {
  const AngoothaPeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appProvider);
    final controller = ref.read(appProvider.notifier);
    return AppScope(
      session: session,
      controller: controller,
      child: MaterialApp(
        title: 'angoothaPe',
        debugShowCheckedModeBanner: false,
        theme: apTheme(ApPalette.light, Brightness.light),
        darkTheme: apTheme(ApPalette.dark, Brightness.dark),
        themeMode: session.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          final scaler = MediaQuery.textScalerOf(context);
          final next = scaler.scale(1) * session.scale;
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(next.clamp(1, 1.6))),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: ToastListener(
          child: session.booting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : session.authed
              ? const HomeShell()
              : session.route == 'join'
              ? const JoinScreen()
              : const AuthHost(),
        ),
      ),
    );
  }
}
