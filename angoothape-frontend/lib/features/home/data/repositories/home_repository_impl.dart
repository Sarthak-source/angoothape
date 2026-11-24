import '../../domain/repositories/home_repository.dart';
import '../datasources/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);
  final HomeApi _api;

  @override
  Future<Map<String, dynamic>> transactions({
    required String q,
    required String status,
    required String svc,
    required String range,
  }) {
    return _api.transactions(q: q, status: status, svc: svc, range: range);
  }

  @override
  Future<Map<String, dynamic>> checkTransaction(
    String ref, {
    Map<String, dynamic>? body,
  }) {
    return _api.checkTransaction(ref, body: body);
  }

  @override
  Future<Map<String, dynamic>> settle({required int amount}) {
    return _api.settle(amount: amount);
  }

  @override
  Future<Map<String, dynamic>> addAccount({
    required String holder,
    required String acct,
    required String acct2,
    required String ifsc,
  }) {
    return _api.addAccount(
      holder: holder,
      acct: acct,
      acct2: acct2,
      ifsc: ifsc,
    );
  }

  @override
  Future<Map<String, dynamic>> topup({required int amount}) {
    return _api.topup(amount: amount);
  }

  @override
  Future<void> receiptAction(String id, {required String kind}) {
    return _api.receiptAction(id, kind: kind);
  }

  @override
  Future<void> exportCsv({required String range}) {
    return _api.exportCsv(range: range);
  }
}
