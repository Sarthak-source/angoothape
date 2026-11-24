import '../../domain/repositories/support_repository.dart';
import '../datasources/support_api.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._api);
  final SupportApi _api;

  @override
  Future<Map<String, dynamic>> createTicket({
    required String type,
    required String message,
    String? ref,
  }) {
    return _api.createTicket(type: type, message: message, ref: ref);
  }

  @override
  Future<Map<String, dynamic>> device() => _api.device();

  @override
  Future<void> patchDevice({required String state}) =>
      _api.patchDevice(state: state);

  @override
  Future<void> testDevice() => _api.testDevice();

  @override
  Future<void> deviceRequest({required String kind}) =>
      _api.deviceRequest(kind: kind);

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String shop,
    required String city,
    required String mobile,
  }) {
    return _api.updateProfile(
      name: name,
      shop: shop,
      city: city,
      mobile: mobile,
    );
  }

  @override
  Future<void> changePassword({
    required String current,
    required String next,
  }) {
    return _api.changePassword(current: current, next: next);
  }
}
