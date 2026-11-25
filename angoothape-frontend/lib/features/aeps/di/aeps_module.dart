import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_module.dart';
import '../data/datasources/aeps_api.dart';
import '../data/datasources/mock_biometric_port.dart';
import '../data/repositories/biometric_repository_impl.dart';
import '../domain/ports/biometric_port.dart';
import '../domain/usecases/capture_fingerprint_usecase.dart';

final aepsApiProvider = Provider<AepsApi>(
  (ref) => AepsApi(ref.watch(httpClientProvider)),
);

final biometricPortProvider = Provider<BiometricPort>(
  (ref) => BiometricRepositoryImpl(MockBiometricPort()),
);

final captureFingerprintUseCaseProvider = Provider<CaptureFingerprintUseCase>(
  (ref) => CaptureFingerprintUseCase(ref.watch(biometricPortProvider)),
);
