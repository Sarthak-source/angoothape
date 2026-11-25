import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_module.dart';
import '../data/datasources/join_api.dart';
import '../data/repositories/join_repository_impl.dart';
import '../domain/repositories/join_repository.dart';
import '../domain/usecases/start_ekyc_usecase.dart';
import '../domain/usecases/submit_join_usecase.dart';

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
