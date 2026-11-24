class BankAccount {
  BankAccount({
    required this.id,
    required this.bank,
    required this.last4,
    required this.holder,
    required this.ifsc,
    required this.status,
    this.primary = false,
    this.note,
  });
  final String id;
  final String bank;
  final String last4;
  final String holder;
  final String ifsc;
  final String status;
  final bool primary;
  final String? note;
}
