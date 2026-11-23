import '../../features/session/domain/entities/session_entities.dart';

TxStatus _status(Object? v) => switch (v) {
  'failed' => TxStatus.failed,
  'pending' => TxStatus.pending,
  _ => TxStatus.success,
};

DateTime _time(Object? v) =>
    v is String ? DateTime.tryParse(v) ?? DateTime.now() : DateTime.now();

MiniLine miniFromJson(Map<String, dynamic> j) => MiniLine(
  label: j['label'] as String? ?? '',
  date: _time(j['date'] ?? j['occurred_on']),
  amount: (j['amount'] as num?)?.toInt() ?? 0,
);

Txn txnFromJson(Map<String, dynamic> j) => Txn(
  t: _time(j['t']),
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

Retailer retailerFromJson(Map<String, dynamic> j) => Retailer(
  id: j['id'] as String? ?? '',
  name: j['name'] as String? ?? '',
  shop: j['shop'] as String? ?? '',
  city: j['city'] as String? ?? '',
  mobile: j['mobile'] as String? ?? '',
  role: j['role'] as String? ?? '',
  distributor: j['distributor'] as String? ?? '',
);

Bank bankFromJson(Map<String, dynamic> j) => Bank(
  id: j['id'] as String? ?? '',
  name: j['name'] as String? ?? '',
  short: j['short'] as String? ?? '',
  color: (j['color'] as num?)?.toInt() ?? 0xFF1D4F91,
  popular: j['popular'] as bool? ?? false,
  ifscPrefix: j['ifscPrefix'] as String?,
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
  t: _time(j['t']),
  amt: (j['amt'] as num?)?.toInt() ?? 0,
  acct: j['acct'] as String? ?? '',
  status: j['status'] as String? ?? 'processing',
  utr: j['utr'] as String?,
  note: j['note'] as String?,
);

Ticket ticketFromJson(Map<String, dynamic> j) => Ticket(
  id: j['id'].toString(),
  t: _time(j['t']),
  type: j['type'] as String? ?? '',
  status: j['status'] as String? ?? 'Open',
  msg: j['msg'] as String? ?? '',
  ref: j['ref'] as String?,
);

void applyCatalogJson(Map<String, dynamic> json) {
  Map<String, List<(String, String)>> langPairs(
    Object? raw, {
    required String a,
    required String b,
  }) {
    final map = Map<String, dynamic>.from(raw as Map? ?? {});
    return {
      for (final e in map.entries)
        e.key: [
          for (final x in e.value as List? ?? [])
            if (x is Map)
              ((x[a] ?? '').toString(), (x[b] ?? '').toString()),
        ],
    };
  }

  Map<String, List<String>> langStrings(Object? raw) {
    final map = Map<String, dynamic>.from(raw as Map? ?? {});
    return {
      for (final e in map.entries)
        e.key: [
          for (final x in e.value as List? ?? []) x.toString(),
        ],
    };
  }

  applyCatalog(
    nextBanks: [
      for (final x in json['banks'] as List? ?? [])
        bankFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    nextFaqs: langPairs(json['faqs'], a: 'q', b: 'a'),
    nextIssues: langStrings(json['issues']),
    nextFuture: langPairs(json['futureServices'], a: 'id', b: 'label'),
  );
}

AppData appDataFromSession(Map<String, dynamic> json) {
  final wallet = walletFromJson(
    Map<String, dynamic>.from(json['wallet'] as Map? ?? {}),
  );
  return AppData(
    retailer: retailerFromJson(
      Map<String, dynamic>.from(json['retailer'] as Map? ?? {}),
    ),
    tx: [
      for (final x in json['tx'] as List? ?? [])
        txnFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    wallet: wallet,
    settlements: [
      for (final x in json['settlements'] as List? ?? [])
        settlementFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    accounts: [
      for (final x in json['accounts'] as List? ?? [])
        accountFromJson(Map<String, dynamic>.from(x as Map)),
    ],
    tickets: [
      for (final x in json['tickets'] as List? ?? [])
        ticketFromJson(Map<String, dynamic>.from(x as Map)),
    ],
  );
}
