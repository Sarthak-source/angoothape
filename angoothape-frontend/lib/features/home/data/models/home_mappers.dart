import '../../../../core/enums.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/entities/txn.dart';
import '../../domain/entities/wallet.dart';

TxStatus _status(Object? v) => switch (v) {
  'failed' => TxStatus.failed,
  'pending' => TxStatus.pending,
  _ => TxStatus.success,
};

DateTime parseTime(Object? v) =>
    v is String ? DateTime.tryParse(v) ?? DateTime.now() : DateTime.now();

MiniLine miniFromJson(Map<String, dynamic> j) => MiniLine(
  label: j['label'] as String? ?? '',
  date: parseTime(j['date'] ?? j['occurred_on']),
  amount: (j['amount'] as num?)?.toInt() ?? 0,
);

Txn txnFromJson(Map<String, dynamic> j) => Txn(
  t: parseTime(j['t']),
  svc: j['svc'] as String? ?? 'cw',
  amt: (j['amt'] as num?)?.toInt() ?? 0,
  bank: j['bank'] as String? ?? '',
  aadhaar4: j['aadhaar4'] as String? ?? '',
  mobile4: j['mobile4'] as String? ?? '',
  status: _status(j['status']),
  ref: j['ref'] as String? ?? '',
  rrn: j['rrn'] as String? ?? '',
  reason: j['reason'] as String?,
  bal: (j['bal'] as num?)?.toDouble(),
  unknown: j['unknown'] as bool? ?? false,
  earn: (j['earn'] as num?)?.toDouble() ?? 0,
  checks: (j['checks'] as num?)?.toInt() ?? 0,
  credited: j['credited'] as bool? ?? false,
  mini: [
    for (final x in j['mini'] as List? ?? [])
      miniFromJson(Map<String, dynamic>.from(x as Map)),
  ],
);

Wallet walletFromJson(Map<String, dynamic> j) => Wallet(
  main: (j['main'] as num?)?.toDouble() ?? 0,
  aeps: (j['aeps'] as num?)?.toDouble() ?? 0,
  earn: (j['earn'] as num?)?.toDouble() ?? 0,
);

BankAccount accountFromJson(Map<String, dynamic> j) => BankAccount(
  id: j['id'].toString(),
  bank: j['bank'] as String? ?? '',
  last4: j['last4'] as String? ?? '',
  holder: j['holder'] as String? ?? '',
  ifsc: j['ifsc'] as String? ?? '',
  status: j['status'] as String? ?? 'pending',
  primary: j['primary'] as bool? ?? false,
  note: j['note'] as String?,
);

Settlement settlementFromJson(Map<String, dynamic> j) => Settlement(
  id: j['id'].toString(),
  t: parseTime(j['t']),
  amt: (j['amt'] as num?)?.toInt() ?? 0,
  acct: j['acct'] as String? ?? '',
  status: j['status'] as String? ?? 'processing',
  utr: j['utr'] as String?,
  note: j['note'] as String?,
);
