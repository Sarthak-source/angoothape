import '../../../../core/api/api_client.dart';

class HomeApi {
  HomeApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> transactions({
    required String q,
    required String status,
    required String svc,
    required String range,
  }) {
    return _client.get(
      '/api/transactions',
      query: {
        'q': q,
        'status': status,
        'svc': svc,
        'range': range,
      },
    );
  }

  Future<Map<String, dynamic>> checkTransaction(
    String ref, {
    Map<String, dynamic>? body,
  }) {
    return _client.post('/api/transactions/$ref/check', body);
  }

  Future<Map<String, dynamic>> settle({required int amount}) {
    return _client.post('/api/settlements', {'amount': amount});
  }

  Future<Map<String, dynamic>> addAccount({
    required String holder,
    required String acct,
    required String acct2,
    required String ifsc,
  }) {
    return _client.post('/api/accounts', {
      'holder': holder,
      'acct': acct,
      'acct2': acct2,
      'ifsc': ifsc,
    });
  }

  Future<Map<String, dynamic>> topup({required int amount}) {
    return _client.post('/api/wallet/topup', {'amount': amount});
  }

  Future<void> receiptAction(String id, {required String kind}) async {
    await _client.post('/api/receipts/$id/actions', {'kind': kind});
  }

  Future<void> exportCsv({required String range}) async {
    await _client.post('/api/exports', {'range': range, 'format': 'csv'});
  }
}
