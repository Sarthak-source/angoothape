class Ticket {
  Ticket({
    required this.id,
    required this.t,
    required this.type,
    required this.status,
    required this.msg,
    this.ref,
  });
  final String id;
  final DateTime t;
  final String type;
  final String status;
  final String msg;
  final String? ref;
}
