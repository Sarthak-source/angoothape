import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_widgets.dart';
import '../../../../session/domain/entities/session_entities.dart';

import '../widgets/result_body.dart';

class AepsResult extends StatelessWidget {
  const AepsResult({super.key, required this.live, this.txn});
  final bool live;
  final Txn? txn;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final x = txn ?? c.txnByRef(c.aeps.resultRef);
    if (x == null) return const SizedBox.shrink();
    return ResultBody(tx: x, live: live);
  }
}
