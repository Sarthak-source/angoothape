import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/aeps/data/datasources/aeps_api.dart';
import '../features/aeps/data/datasources/mock_biometric_port.dart';
import '../features/aeps/data/repositories/biometric_repository_impl.dart';
import '../features/aeps/domain/ports/biometric_port.dart';
import '../features/aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../features/auth/data/datasources/auth_api.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../features/auth/domain/usecases/verify_totp_usecase.dart';
import '../features/home/data/datasources/home_api.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/load_transactions_usecase.dart';
import '../features/onboarding/data/datasources/join_api.dart';
import '../features/onboarding/data/repositories/join_repository_impl.dart';
import '../features/onboarding/domain/repositories/join_repository.dart';
import '../features/onboarding/domain/usecases/start_ekyc_usecase.dart';
import '../features/onboarding/domain/usecases/submit_join_usecase.dart';
import '../features/session/data/datasources/session_api.dart';
import '../features/session/data/repositories/session_repository_impl.dart';
import '../features/session/domain/entities/app_session.dart';
import '../features/session/domain/repositories/session_repository.dart';
import '../features/session/domain/usecases/refresh_session_usecase.dart';
import '../features/session/presentation/controllers/app_controller.dart';
import '../features/support/data/datasources/support_api.dart';
import '../features/support/data/repositories/support_repository_impl.dart';
import '../features/support/domain/repositories/support_repository.dart';
import '../features/support/domain/usecases/create_ticket_usecase.dart';
import 'di/core_module.dart';

export 'di/core_module.dart';

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(httpClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authApiProvider)),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>(
  (ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);

final verifyTotpUseCaseProvider = Provider<VerifyTotpUseCase>(
  (ref) => VerifyTotpUseCase(ref.watch(authRepositoryProvider)),
);

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)),
);

final sessionApiProvider = Provider<SessionApi>(
  (ref) => SessionApi(ref.watch(httpClientProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepositoryImpl(ref.watch(sessionApiProvider)),
);

final refreshSessionUseCaseProvider = Provider<RefreshSessionUseCase>(
  (ref) => RefreshSessionUseCase(ref.watch(sessionRepositoryProvider)),
);

final homeApiProvider = Provider<HomeApi>(
  (ref) => HomeApi(ref.watch(httpClientProvider)),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(homeApiProvider)),
);

final loadTransactionsUseCaseProvider = Provider<LoadTransactionsUseCase>(
  (ref) => LoadTransactionsUseCase(ref.watch(homeRepositoryProvider)),
);

final aepsApiProvider = Provider<AepsApi>(
  (ref) => AepsApi(ref.watch(httpClientProvider)),
);

final biometricPortProvider = Provider<BiometricPort>(
  (ref) => BiometricRepositoryImpl(MockBiometricPort()),
);

final captureFingerprintUseCaseProvider = Provider<CaptureFingerprintUseCase>(
  (ref) => CaptureFingerprintUseCase(ref.watch(biometricPortProvider)),
);

final joinApiProvider = Provider<JoinApi>(
  (ref) => JoinApi(ref.watch(httpClientProvider)),
);

final joinRepositoryProvider = Provider<JoinRepository>(
  (ref) => JoinRepositoryImpl(ref.watch(joinApiProvider)),
);

final submitJoinUseCaseProvider = Provider<SubmitJoinUseCase>(
  (ref) => SubmitJoinUseCase(ref.watch(joinRepositoryProvider)),
);

final startEkycUseCaseProvider = Provider<StartEkycUseCase>(
  (ref) => StartEkycUseCase(ref.watch(joinRepositoryProvider)),
);

final supportApiProvider = Provider<SupportApi>(
  (ref) => SupportApi(ref.watch(httpClientProvider)),
);

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(ref.watch(supportApiProvider)),
);

final createTicketUseCaseProvider = Provider<CreateTicketUseCase>(
  (ref) => CreateTicketUseCase(ref.watch(supportRepositoryProvider)),
);

final appProvider = NotifierProvider<AppController, AppSession>(
  AppController.new,
);
