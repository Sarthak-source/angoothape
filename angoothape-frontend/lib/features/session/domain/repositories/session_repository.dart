abstract class SessionRepository {
  Future<Map<String, dynamic>> catalog();
  Future<Map<String, dynamic>> me();
  Future<void> savePreferences({
    required String lang,
    required bool dark,
    required double scale,
  });
  Future<void> resetDemo();
}
