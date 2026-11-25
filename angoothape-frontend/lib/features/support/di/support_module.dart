import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_module.dart';
import '../data/datasources/support_api.dart';
import '../data/repositories/support_repository_impl.dart';
import '../domain/repositories/support_repository.dart';
import '../domain/usecases/create_ticket_usecase.dart';

final supportApiProvider = Provider<SupportApi>(
  (ref) => SupportApi(ref.watch(httpClientProvider)),
);

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(ref.watch(supportApiProvider)),
);

final createTicketUseCaseProvider = Provider<CreateTicketUseCase>(
  (ref) => CreateTicketUseCase(ref.watch(supportRepositoryProvider)),
);
