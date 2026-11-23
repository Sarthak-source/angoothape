import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../aeps/data/datasources/mock_biometric_port.dart';
import '../../../aeps/data/repositories/biometric_repository_impl.dart';
import '../../../aeps/domain/ports/biometric_port.dart';
import '../../../aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/responsive/layout_service.dart';
import '../controllers/app_controller.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final layoutServiceProvider = Provider<LayoutService>(
  (ref) => const LayoutService(),
);

final biometricPortProvider = Provider<BiometricPort>(
  (ref) => BiometricRepositoryImpl(MockBiometricPort()),
);

final captureFingerprintUseCaseProvider = Provider<CaptureFingerprintUseCase>(
  (ref) => CaptureFingerprintUseCase(ref.watch(biometricPortProvider)),
);

class ViewportWidth extends Notifier<double> {
  @override
  double build() => 390;

  void update(double width) {
    if ((state - width).abs() < 1) return;
    state = width;
  }
}

final viewportWidthProvider = NotifierProvider<ViewportWidth, double>(
  ViewportWidth.new,
);

final layoutProfileProvider = Provider<LayoutProfile>((ref) {
  final width = ref.watch(viewportWidthProvider);
  return ref.watch(layoutServiceProvider).resolve(width);
});

/// Owns the session controller and bumps a revision whenever it notifies,
/// so the widget tree rebuilds through Riverpod.
class Session extends Notifier<int> {
  late final AppController controller;

  @override
  int build() {
    controller = AppController(
      api: ref.watch(apiClientProvider),
      captureFingerprintUseCase: ref.watch(captureFingerprintUseCaseProvider),
    );
    controller.addListener(_onChange);
    ref.onDispose(() {
      controller.removeListener(_onChange);
      controller.dispose();
    });
    return 0;
  }

  void _onChange() => state++;
}

final sessionProvider = NotifierProvider<Session, int>(Session.new);
