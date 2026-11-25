import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_module.dart';
import '../data/datasources/session_api.dart';
import '../data/repositories/session_repository_impl.dart';
import '../domain/repositories/session_repository.dart';
import '../domain/usecases/refresh_session_usecase.dart';

final sessionApiProvider = Provider<SessionApi>(
  (ref) => SessionApi(ref.watch(httpClientProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepositoryImpl(ref.watch(sessionApiProvider)),
);

final refreshSessionUseCaseProvider = Provider<RefreshSessionUseCase>(
  (ref) => RefreshSessionUseCase(ref.watch(sessionRepositoryProvider)),
);
