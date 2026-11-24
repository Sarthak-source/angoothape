import '../../domain/entities/bank.dart';
import '../../domain/entities/reason_copy.dart';

Bank bankFromJson(Map<String, dynamic> j) => Bank(
  id: j['id'] as String? ?? '',
  name: j['name'] as String? ?? '',
  short: j['short'] as String? ?? '',
  color: (j['color'] as num?)?.toInt() ?? 0xFF1D4F91,
  popular: j['popular'] as bool? ?? false,
  ifscPrefix: j['ifscPrefix'] as String?,
);

ReasonCopy reasonFromJson(Map<String, dynamic> j) => ReasonCopy(
  en: (j['en'] is Map ? (j['en'] as Map)['text'] : j['en'])?.toString() ?? '',
  hi: (j['hi'] is Map ? (j['hi'] as Map)['text'] : j['hi'])?.toString() ?? '',
  nextEn: (j['en'] is Map ? (j['en'] as Map)['next'] : null)?.toString() ?? '',
  nextHi: (j['hi'] is Map ? (j['hi'] as Map)['next'] : null)?.toString() ?? '',
);
