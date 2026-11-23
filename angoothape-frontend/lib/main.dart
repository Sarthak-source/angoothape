import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/palette.dart';
import 'core/widgets/app_widgets.dart';
import 'features/auth/presentation/ui/screens/auth_screen.dart';
import 'features/home/presentation/ui/screens/home_shell.dart';
import 'features/onboarding/presentation/ui/screens/join_screen.dart';
import 'features/session/presentation/providers/session_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AngoothaPeApp()));
}

class AngoothaPeApp extends ConsumerWidget {
  const AngoothaPeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionProvider);
    final controller = ref.read(sessionProvider.notifier).controller;
    return AppScope(
      controller: controller,
      child: MaterialApp(
        title: 'angoothaPe',
        debugShowCheckedModeBanner: false,
        theme: apTheme(ApPalette.light, Brightness.light),
        darkTheme: apTheme(ApPalette.dark, Brightness.dark),
        themeMode: controller.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          final scaler = MediaQuery.textScalerOf(context);
          final next = scaler.scale(1) * controller.scale;
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(next.clamp(1, 1.6))),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: ToastListener(
          child: controller.booting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : controller.authed
              ? const HomeShell()
              : controller.route == 'join'
              ? const JoinScreen()
              : const AuthHost(),
        ),
      ),
    );
  }
}
