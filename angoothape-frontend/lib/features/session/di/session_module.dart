import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/app_session.dart';
import '../presentation/controllers/app_controller.dart';

export 'session_bindings.dart';

final appProvider = NotifierProvider<AppController, AppSession>(
  AppController.new,
);
