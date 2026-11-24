abstract class HomeRepository {
  Future<Map<String, dynamic>> transactions({
    required String q,
    required String status,
    required String svc,
    required String range,
  });

  Future<Map<String, dynamic>> checkTransaction(
    String ref, {
    Map<String, dynamic>? body,
  });

  Future<Map<String, dynamic>> settle({required int amount});

  Future<Map<String, dynamic>> addAccount({
    required String holder,
    required String acct,
    required String acct2,
    required String ifsc,
  });

  Future<Map<String, dynamic>> topup({required int amount});

  Future<void> receiptAction(String id, {required String kind});

  Future<void> exportCsv({required String range});
}
