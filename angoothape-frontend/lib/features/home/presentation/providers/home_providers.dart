import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/home_api.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/load_transactions_usecase.dart';

final homeApiProvider = Provider<HomeApi>(
  (ref) => HomeApi(ref.watch(apiClientProvider)),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(homeApiProvider)),
);

final loadTransactionsUseCaseProvider = Provider<LoadTransactionsUseCase>(
  (ref) => LoadTransactionsUseCase(ref.watch(homeRepositoryProvider)),
);
