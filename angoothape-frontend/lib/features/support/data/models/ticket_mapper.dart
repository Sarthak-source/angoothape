import '../../domain/entities/ticket.dart';
import '../../../home/data/models/home_mappers.dart';

Ticket ticketFromJson(Map<String, dynamic> j) => Ticket(
  id: j['id'].toString(),
  t: parseTime(j['t']),
  type: j['type'] as String? ?? '',
  status: j['status'] as String? ?? 'Open',
  msg: j['msg'] as String? ?? '',
  ref: j['ref'] as String?,
);
