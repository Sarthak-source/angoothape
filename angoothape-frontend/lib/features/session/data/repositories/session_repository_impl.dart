import '../../domain/repositories/session_repository.dart';
import '../datasources/session_api.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._api);
  final SessionApi _api;

  @override
  Future<void> restore() => _api.restore();

  @override
  bool get signedIn => _api.signedIn;

  @override
  Future<void> persistTokens(String token, {String? mfaToken}) {
    return _api.persistTokens(token, mfaToken: mfaToken);
  }

  @override
  Future<void> clearTokens() => _api.clearTokens();

  @override
  Future<Map<String, dynamic>> catalog() => _api.catalog();

  @override
  Future<Map<String, dynamic>> me() => _api.me();

  @override
  Future<void> savePreferences({
    required String lang,
    required bool dark,
    required double scale,
  }) {
    return _api.savePreferences(lang: lang, dark: dark, scale: scale);
  }

  @override
  Future<void> resetDemo() => _api.resetDemo();
}
