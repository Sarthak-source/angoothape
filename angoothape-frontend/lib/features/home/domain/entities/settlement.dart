class Settlement {
  Settlement({
    required this.id,
    required this.t,
    required this.amt,
    required this.acct,
    required this.status,
    this.utr,
    this.note,
  });
  final String id;
  final DateTime t;
  final int amt;
  final String acct;
  final String status;
  final String? utr;
  final String? note;
}
