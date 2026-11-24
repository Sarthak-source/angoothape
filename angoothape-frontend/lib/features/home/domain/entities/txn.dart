import '../../../../core/enums.dart';

class MiniLine {
  MiniLine({required this.label, required this.date, required this.amount});
  final String label;
  final DateTime date;
  final int amount;
}

class Txn {
  Txn({
    required this.t,
    required this.svc,
    required this.amt,
    required this.bank,
    required this.aadhaar4,
    required this.mobile4,
    required this.status,
    required this.ref,
    required this.rrn,
    this.reason,
    this.bal,
    this.unknown = false,
    this.earn = 0,
    this.checks = 0,
    this.credited = false,
    this.mini = const [],
  });

  final DateTime t;
  final String svc;
  final int amt;
  final String bank;
  final String aadhaar4;
  final String mobile4;
  TxStatus status;
  final String ref;
  final String rrn;
  String? reason;
  double? bal;
  bool unknown;
  double earn;
  int checks;
  bool credited;
  List<MiniLine> mini;
}

class HistFilter {
  String q = '';
  String status = 'all';
  String svc = 'all';
  String range = '30';
  bool loading = false;
}
