Map<String, List<(String, String)>> faqs = {
  'en': [],
  'hi': [],
};

Map<String, List<String>> issues = {
  'en': [],
  'hi': [],
};

Map<String, List<(String, String)>> _futureServices = {
  'en': [],
  'hi': [],
};

List<(String, String)> futureServices(String lang) =>
    _futureServices[lang] ?? _futureServices['en']!;

List<String> deviceGuide(String platform, String lang) =>
    (deviceGuides[platform]?[lang] ?? deviceGuides[platform]?['en'] ?? const []);

Map<String, Map<String, List<String>>> deviceGuides = {};

Map<String, List<(String, List<String>)>> deviceFaqs = {
  'en': [],
  'hi': [],
};

void applySupportCatalog({
  required Map<String, List<(String, String)>> nextFaqs,
  required Map<String, List<String>> nextIssues,
  required Map<String, List<(String, String)>> nextFuture,
  Map<String, Map<String, List<String>>> nextGuides = const {},
  Map<String, List<(String, List<String>)>> nextDeviceFaqs = const {},
}) {
  faqs
    ..clear()
    ..addAll(nextFaqs);
  issues
    ..clear()
    ..addAll(nextIssues);
  _futureServices
    ..clear()
    ..addAll(nextFuture);
  if (nextGuides.isNotEmpty) {
    deviceGuides
      ..clear()
      ..addAll(nextGuides);
  }
  if (nextDeviceFaqs.isNotEmpty) {
    deviceFaqs
      ..clear()
      ..addAll(nextDeviceFaqs);
  }
}
