abstract class JoinRepository {
  Future<Map<String, dynamic>> submit({
    required String role,
    required Map<String, String> fields,
    required Map<String, String> docs,
    String? ekycId,
  });

  Future<Map<String, dynamic>> startEkyc({required String pan});

  Future<void> approve(String applicationId);
}
