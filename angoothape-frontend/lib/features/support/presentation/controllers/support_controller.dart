import 'dart:async';

import '../../../../core/api/api_exception.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/format.dart';
import '../../../auth/data/models/retailer_mapper.dart';
import '../../../home/domain/entities/txn.dart';
import '../../../session/domain/entities/app_data.dart';
import '../../../session/domain/entities/sheet_model.dart';
import '../../../aeps/domain/entities/scenario.dart';
import '../../data/models/ticket_mapper.dart';
import '../../domain/entities/new_req.dart';
import '../../domain/entities/support_catalog.dart';
import '../../domain/repositories/support_repository.dart';

mixin SupportController {
  SupportRepository get supportRepository;
  String helpTab = 'faq';
  NewReq newReq = NewReq();
  String devTab = 'android';
  String devTest = 'idle';

  AppData get data;
  Scenario get scenario;
  SheetModel? get sheet;
  set sheet(SheetModel? value);
  String get lang;
  bool get authed;
  String get route;
  Txn? txnByRef(String? ref);

  void emit();
  void go(String next, {Map<String, String>? params});
  void toast(String msg, {bool sim = false});
  String both(String en, String hindi);
  String t(String key);

  void openSupport(String? ref) {
    final x = txnByRef(ref);
    var type = '';
    if (x != null) {
      if (x.status == TxStatus.pending) type = '2';
      if (x.status == TxStatus.failed) type = '1';
    }
    newReq = NewReq()
      ..ref = ref ?? ''
      ..type = type;
    go('help-new');
  }

  void setHelpTab(String v) {
    helpTab = v;
    emit();
  }

  void setReqType(String v) {
    newReq.type = v;
    emit();
  }

  void unlinkReq() {
    newReq.ref = '';
    emit();
  }

  void setReqRef(String v) {
    newReq.ref = v;
    emit();
  }

  Future<bool> submitTicket(String msg) async {
    newReq.msg = msg;
    newReq.tried = true;
    if (newReq.type.isEmpty || msg.trim().length < 10) {
      emit();
      return false;
    }
    final labels = issues[lang] ?? issues['en'] ?? const <String>[];
    final idx = int.tryParse(newReq.type) ?? -1;
    if (idx < 0 || idx >= labels.length) {
      emit();
      return false;
    }
    final type = labels[idx];
    try {
      final res = await supportRepository.createTicket(
        type: type,
        message: msg.trim(),
        ref: newReq.ref,
      );
      final k = ticketFromJson(Map<String, dynamic>.from(res['ticket'] as Map));
      data.prependTicket(k);
      go('ticket', params: {'id': k.id, 'fresh': '1'});
      return true;
    } on ApiException catch (e) {
      toast(e.message);
      emit();
      return false;
    }
  }

  void setDevTab(String v) {
    devTab = v;
    emit();
  }

  Future<void> testCapture() async {
    devTest = 'run';
    emit();
    try {
      await supportRepository.testDevice();
      if (route == 'device') {
        devTest = 'done';
        emit();
      }
    } on ApiException catch (e) {
      devTest = 'idle';
      toast(e.message);
      emit();
    }
  }

  Future<void> recheckDevicePage() async {
    try {
      final res = await supportRepository.device();
      final state = res['state'] as String? ?? 'ready';
      scenario.device = switch (state) {
        'disconnected' => DeviceState.disconnected,
        'permission' => DeviceState.permission,
        _ => DeviceState.ready,
      };
    } catch (_) {}
    devTest = 'idle';
    emit();
    toast(
      scenario.device == DeviceState.ready
          ? t('dev_ready')
          : both('Device still not ready.', 'डिवाइस अभी भी तैयार नहीं है।'),
    );
  }

  void setDevice(DeviceState v) {
    scenario.device = v;
    emit();
    if (!authed) return;
    unawaited(() async {
      try {
        await supportRepository.patchDevice(state: v.name);
      } catch (_) {}
    }());
  }

  void openProfile() {
    sheet = SheetModel(SheetKind.profile);
    emit();
  }

  void openPassword() {
    sheet = SheetModel(SheetKind.password);
    emit();
  }

  Future<void> submitProfile(Map<String, String> f) async {
    final s = sheet;
    if (s == null) return;
    s.f = f;
    s.tried = true;
    if ((f['name'] ?? '').trim().isEmpty ||
        (f['shop'] ?? '').trim().isEmpty ||
        (f['city'] ?? '').trim().isEmpty ||
        !validMobile(f['mobile'] ?? '')) {
      emit();
      return;
    }
    try {
      final res = await supportRepository.updateProfile(
        name: f['name']!.trim(),
        shop: f['shop']!.trim(),
        city: f['city']!.trim(),
        mobile: f['mobile']!.trim(),
      );
      data.retailer = retailerFromJson(
        Map<String, dynamic>.from(res['retailer'] as Map),
      );
      sheet = null;
      emit();
      toast(both('Profile saved', 'प्रोफ़ाइल सेव हो गई'));
    } on ApiException catch (e) {
      toast(e.message);
      emit();
    }
  }

  Future<void> submitPassword(String current, String next) async {
    final s = sheet;
    if (s == null) return;
    s.tried = true;
    if (current.isEmpty || next.length < 8) {
      emit();
      return;
    }
    try {
      await supportRepository.changePassword(current: current, next: next);
      sheet = null;
      emit();
      toast(both('Password updated', 'पासवर्ड बदल गया'));
    } on ApiException catch (e) {
      toast(e.message);
      emit();
    }
  }

  Future<void> deviceRequest(String kind) async {
    try {
      await supportRepository.deviceRequest(kind: kind);
      toast(
        kind == 'repair'
            ? both('Repair request sent', 'मरम्मत अनुरोध भेजा गया')
            : both('Device order request sent', 'डिवाइस ऑर्डर अनुरोध भेजा गया'),
      );
    } on ApiException catch (e) {
      toast(e.message);
    }
  }
}
