abstract class SessionRepository {
  Future<void> restore();
  bool get signedIn;
  Future<void> persistTokens(String token, {String? mfaToken});
  Future<void> clearTokens();
  Future<Map<String, dynamic>> catalog();
  Future<Map<String, dynamic>> me();
  Future<void> savePreferences({
    required String lang,
    required bool dark,
    required double scale,
  });
  Future<void> resetDemo();
}
