import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../aeps/data/datasources/mock_aeps_gateway.dart';
import '../../../aeps/data/datasources/mock_biometric_port.dart';
import '../../../aeps/data/repositories/aeps_repository_impl.dart';
import '../../../aeps/data/repositories/biometric_repository_impl.dart';
import '../../../aeps/domain/ports/aeps_gateway.dart';
import '../../../aeps/domain/ports/biometric_port.dart';
import '../../../aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../../../aeps/domain/usecases/check_aeps_status_usecase.dart';
import '../../../aeps/domain/usecases/submit_aeps_usecase.dart';
import '../../../../core/responsive/layout_service.dart';
import '../controllers/app_controller.dart';

final layoutServiceProvider = Provider<LayoutService>(
  (ref) => const LayoutService(),
);

final aepsGatewayProvider = Provider<AepsGateway>(
  (ref) => AepsRepositoryImpl(MockAepsGateway()),
);

final biometricPortProvider = Provider<BiometricPort>(
  (ref) => BiometricRepositoryImpl(MockBiometricPort()),
);

final submitAepsUseCaseProvider = Provider<SubmitAepsUseCase>(
  (ref) => SubmitAepsUseCase(ref.watch(aepsGatewayProvider)),
);

final checkAepsStatusUseCaseProvider = Provider<CheckAepsStatusUseCase>(
  (ref) => CheckAepsStatusUseCase(ref.watch(aepsGatewayProvider)),
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
      submitAepsUseCase: ref.watch(submitAepsUseCaseProvider),
      checkAepsStatusUseCase: ref.watch(checkAepsStatusUseCaseProvider),
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
