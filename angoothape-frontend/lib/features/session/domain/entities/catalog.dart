import '../../../aeps/domain/entities/bank.dart';
import '../../../aeps/domain/entities/reason_copy.dart';
import '../../../support/domain/entities/support_catalog.dart';

void applyCatalog({
  required List<Bank> nextBanks,
  required Map<String, List<(String, String)>> nextFaqs,
  required Map<String, List<String>> nextIssues,
  required Map<String, List<(String, String)>> nextFuture,
  Map<String, Map<String, List<String>>> nextGuides = const {},
  Map<String, List<(String, List<String>)>> nextDeviceFaqs = const {},
  Map<String, ReasonCopy> nextReasons = const {},
}) {
  applyBanks(nextBanks);
  applySupportCatalog(
    nextFaqs: nextFaqs,
    nextIssues: nextIssues,
    nextFuture: nextFuture,
    nextGuides: nextGuides,
    nextDeviceFaqs: nextDeviceFaqs,
  );
  applyReasons(nextReasons);
}
