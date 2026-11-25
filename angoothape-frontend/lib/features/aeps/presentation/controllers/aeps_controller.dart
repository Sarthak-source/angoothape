import 'dart:async';

import '../../../../core/api/api_exception.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/format.dart';
import '../../../home/data/models/home_mappers.dart';
import '../../../session/domain/entities/app_data.dart';
import '../../../session/domain/entities/sheet_model.dart';
import '../../data/datasources/aeps_api.dart';
import '../../domain/entities/aeps_draft.dart';
import '../../domain/entities/scenario.dart';
import '../../domain/usecases/capture_fingerprint_usecase.dart';

mixin AepsController {
  AepsApi get aepsApi;
  CaptureFingerprintUseCase get captureFingerprintUseCase;
  AepsDraft aeps = AepsDraft();
  int _seq = 0;

  Scenario get scenario;
  AppData get data;
  SheetModel? get sheet;
  set sheet(SheetModel? value);
  bool get inflight;
  set inflight(bool value);
  String get route;

  void emit();
  void go(String next, {Map<String, String>? params});
  void toast(String msg, {bool sim = false});
  String t(String key);
  void applyWallet(Map<String, dynamic>? json);

  void startAeps(String svc) {
    if (inflight) {
      toast(t('in_progress'));
      return;
    }
    aeps = AepsDraft()..service = svc;
    go('aeps');
  }

  void setService(String svc) {
    aeps.service = svc;
    emit();
  }

  Map<String, String> aepsErrors({
    String? mobile,
    String? aadhaar,
    String? idType,
    String? bank,
    String? amount,
    String? service,
  }) {
    final m = mobile ?? aeps.mobile;
    final id = aadhaar ?? aeps.aadhaar;
    final type = idType ?? aeps.idType;
    final b = bank ?? aeps.bank;
    final amt = amount ?? aeps.amount;
    final svc = service ?? aeps.service;
    final e = <String, String>{};
    if (!validMobile(m)) e['mobile'] = t('e_mobile');
    if (type == 'aadhaar') {
      if (!looksLikeAadhaar(id)) {
        e['aadhaar'] = t('e_aadhaar');
      } else if (!verhoeffOk(id)) {
        e['aadhaar'] = t('e_aadhaar_chk');
      }
    } else if (!validVid(id)) {
      e['aadhaar'] = t('e_vid');
    }
    if (b == null || b.isEmpty) e['bank'] = t('e_bank');
    if (svc == 'cw') {
      final n = int.tryParse(amt);
      if (n == null || n < 100 || n > 10000) e['amount'] = t('e_amount');
    }
    return e;
  }

  void saveAepsDetails({
    required String mobile,
    required String aadhaar,
    required String amount,
  }) {
    aeps.mobile = mobile;
    aeps.aadhaar = aadhaar;
    aeps.amount = amount;
  }

  bool reviewAeps({
    required String mobile,
    required String aadhaar,
    required String amount,
  }) {
    saveAepsDetails(mobile: mobile, aadhaar: aadhaar, amount: amount);
    aeps.tried = true;
    if (aepsErrors().isNotEmpty) {
      emit();
      return false;
    }
    aeps.step = AepsStep.auth;
    aeps.capture = CapturePhase.idle;
    aeps.attempts = 0;
    aeps.consentTried = false;
    emit();
    return true;
  }

  void editAeps() {
    aeps.step = AepsStep.details;
    emit();
  }

  void setIdType(String type) {
    aeps.idType = type;
    aeps.aadhaar = '';
    emit();
  }

  void toggleShowId() {
    aeps.showId = !aeps.showId;
    emit();
  }

  void fillSample() {
    aeps.mobile = '9876543210';
    aeps.idType = 'aadhaar';
    aeps.aadhaar = sampleAadhaar();
    aeps.bank = 'sbi';
    aeps.showId = false;
    if (aeps.service == 'cw') aeps.amount = '2000';
    emit();
  }

  void pickBank(String id) {
    aeps.bank = id;
    sheet = null;
    emit();
  }

  void setConsent(bool v) {
    aeps.consent = v;
    emit();
  }

  void openBankSheet() {
    sheet = SheetModel(SheetKind.bank);
    emit();
  }

  Future<void> capture() async {
    if (!aeps.consent) {
      aeps.consentTried = true;
      emit();
      return;
    }
    if (scenario.device != DeviceState.ready) {
      emit();
      return;
    }
    if (aeps.capture == CapturePhase.capturing) return;
    aeps.capture = CapturePhase.capturing;
    emit();
    final captured = await captureFingerprintUseCase(
      failFirstAttempt: scenario.captureRetry,
      attemptsSoFar: aeps.attempts,
    );
    if (route != 'aeps' || aeps.step != AepsStep.auth) return;
    final fail = !captured.ok;
    if (fail) {
      aeps.attempts++;
      aeps.capture = aeps.attempts >= 3
          ? CapturePhase.locked
          : CapturePhase.failed;
      emit();
      return;
    }
    aeps.capture = CapturePhase.ok;
    emit();
    await Future.delayed(const Duration(milliseconds: 550));
    await submitAeps();
  }

  Future<void> submitAeps() async {
    if (inflight) return;
    final token = ++_seq;
    inflight = true;
    aeps.step = AepsStep.processing;
    aeps.procStep = 0;
    aeps.offline = false;
    final reqSvc = aeps.service;
    final reqAmt = int.tryParse(aeps.amount) ?? 0;
    final reqBank = aeps.bank ?? 'sbi';
    final mobile4 = aeps.mobile.length >= 4
        ? aeps.mobile.substring(aeps.mobile.length - 4)
        : aeps.mobile;
    final aadhaar4 = aeps.aadhaar.length >= 4
        ? aeps.aadhaar.substring(aeps.aadhaar.length - 4)
        : '';
    aeps.aadhaar = '';
    aeps.showId = false;
    emit();

    Future<void> step(int i, int ms) async {
      await Future.delayed(Duration(milliseconds: ms));
      if (token != _seq || aeps.step != AepsStep.processing) return;
      aeps.procStep = i;
      emit();
    }

    unawaited(step(1, 700));
    unawaited(step(2, 1500));
    if (scenario.outcome == OutcomeKind.network) {
      unawaited(() async {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (token != _seq || aeps.step != AepsStep.processing) return;
        aeps.offline = true;
        emit();
      }());
    }

    try {
      final res = await aepsApi.submit({
        'svc': reqSvc,
        'amount': reqAmt,
        'bank': reqBank,
        'aadhaar4': aadhaar4,
        'mobile4': mobile4,
        'outcome': scenario.outcome.name,
        'failReason': scenario.failReason,
      });
      if (token != _seq) return;
      final x = txnFromJson(Map<String, dynamic>.from(res['tx'] as Map));
      data.prependTx(x);
      applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      inflight = false;
      aeps.step = AepsStep.result;
      aeps.resultRef = x.ref;
      emit();
    } on ApiException catch (e) {
      if (token != _seq) return;
      inflight = false;
      aeps.step = AepsStep.auth;
      aeps.capture = CapturePhase.idle;
      toast(e.message);
      emit();
    }
  }

  Future<void> checkDevice() async {
    aeps.devChecking = true;
    emit();
    await Future.delayed(const Duration(milliseconds: 900));
    aeps.devChecking = false;
    emit();
    if (scenario.device != DeviceState.ready) toast(t('device_still'));
  }

  void restartAeps({bool keep = true}) {
    final prev = aeps;
    aeps = keep ? prev.copyKeep() : AepsDraft();
    emit();
  }

  void doneAeps() {
    aeps = AepsDraft();
    go('dash');
  }

  void openScenarios() {
    sheet = SheetModel(SheetKind.scenarios);
    emit();
  }

  void setOutcome(OutcomeKind v) {
    scenario.outcome = v;
    emit();
  }

  void setFailReason(String v) {
    scenario.failReason = v;
    emit();
  }

  void setPendingResolve(String v) {
    scenario.pendingResolve = v;
    emit();
  }

  void setCaptureRetry(bool v) {
    scenario.captureRetry = v;
    emit();
  }
}
