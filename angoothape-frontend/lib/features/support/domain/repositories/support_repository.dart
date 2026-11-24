abstract class SupportRepository {
  Future<Map<String, dynamic>> createTicket({
    required String type,
    required String message,
    String? ref,
  });

  Future<Map<String, dynamic>> device();

  Future<void> patchDevice({required String state});

  Future<void> testDevice();

  Future<void> deviceRequest({required String kind});

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String shop,
    required String city,
    required String mobile,
  });

  Future<void> changePassword({
    required String current,
    required String next,
  });
}
