import 'dart:async';

import 'package:flutter/material.dart';

import '../../../aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/session_mapper.dart';
import '../../../../core/l10n/strings.dart';
import '../../../../core/responsive/layout_service.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/session_entities.dart';

class ToastMsg {
  ToastMsg(this.text, this.sim);
  final String text;
  final bool sim;
}

class AppController extends ChangeNotifier {
  AppController({required this.api, required this.captureFingerprintUseCase}) {
    unawaited(_boot());
  }

  final ApiClient api;
  final CaptureFingerprintUseCase captureFingerprintUseCase;

  String lang = 'en';
  bool authed = false;
  bool booting = true;
  bool dark = false;
  double scale = 1;
  String route = 'welcome';
  Map<String, String> params = {};
  LayoutProfile layout = const LayoutService().resolve(400);
  bool inflight = false;

  final scenario = Scenario();
  AppData data = emptyAppData();
  AepsDraft aeps = AepsDraft();
  final login = LoginDraft();
  JoinDraft join = JoinDraft();
  final hist = HistFilter();
  String helpTab = 'faq';
  NewReq newReq = NewReq();
  String devTab = 'android';
  String devTest = 'idle';
  SheetModel? sheet;
  final Map<String, bool> checking = {};
  final _toasts = StreamController<ToastMsg>.broadcast();
  Stream<ToastMsg> get toasts => _toasts.stream;

  int _seq = 0;

  Future<void> _boot() async {
    await api.restore();
    try {
      applyCatalogJson(await api.get('/catalog'));
    } catch (_) {}
    if (api.token != null && api.token!.isNotEmpty) {
      try {
        await refreshSession();
        authed = true;
        route = 'dash';
      } catch (_) {
        await api.clearToken();
      }
    }
    booting = false;
    notifyListeners();
  }

  bool get hi => lang == 'hi';
  bool get isMobile => layout.isMobile;
  String t(String key) => tr(lang, key);
  String both(String en, String hindi) => hi ? hindi : en;

  /// Updates navigation parents when the viewport class changes.
  /// Width itself is published by [LayoutScope] during build.
  void bindLayout(LayoutProfile next) {
    if (next.viewport == layout.viewport) return;
    layout = next;
    notifyListeners();
  }

  void toast(String msg, {bool sim = false}) {
    _toasts.add(ToastMsg(msg, sim));
  }

  @override
  void dispose() {
    _toasts.close();
    super.dispose();
  }

  void go(String next, {Map<String, String>? params}) {
    if (inflight && next != route) {
      toast(t('in_progress'));
      return;
    }
    if (next == 'hist') {
      hist.loading = true;
      api
          .get(
            '/api/transactions',
            query: {
              'q': hist.q,
              'status': hist.status,
              'svc': hist.svc,
              'range': hist.range,
            },
          )
          .then((res) {
            data.tx
              ..clear()
              ..addAll([
                for (final x in res['tx'] as List? ?? [])
                  txnFromJson(Map<String, dynamic>.from(x as Map)),
              ]);
            hist.loading = false;
            if (route == 'hist') notifyListeners();
          })
          .catchError((_) {
            hist.loading = false;
            if (route == 'hist') notifyListeners();
          });
    }
    route = next;
    this.params = params ?? {};
    sheet = null;
    notifyListeners();
  }

  void nav(String next) {
    if (next == 'aeps' && aeps.step == AepsStep.result && !inflight) {
      aeps = AepsDraft();
    }
    go(next);
  }

  String? parentOf(String r) {
    switch (r) {
      case 'txn':
        return 'hist';
      case 'help-new':
      case 'ticket':
        return 'help';
      case 'banks':
        return layout.nestUnderMore ? 'more' : 'wallet';
      case 'services':
        return layout.nestUnderMore ? 'more' : 'dash';
      case 'device':
      case 'help':
      case 'profile':
        return layout.nestUnderMore ? 'more' : 'dash';
      case 'login':
        return 'welcome';
      case 'otp':
        return 'login';
      case 'forgot':
        return 'login';
      case 'forgot-otp':
        return 'forgot';
      case 'join':
        return 'welcome';
      case 'more':
        return 'dash';
      default:
        return null;
    }
  }

  void back() {
    if (inflight) return;
    if (route == 'aeps' && aeps.step == AepsStep.auth) {
      aeps.step = AepsStep.details;
      notifyListeners();
      return;
    }
    if (route == 'aeps' &&
        (aeps.step == AepsStep.result || aeps.step == AepsStep.processing)) {
      return;
    }
    if (route == 'join' && join.step > 0) {
      join.step--;
      join.tried = false;
      notifyListeners();
      return;
    }
    final p = parentOf(route);
    if (p != null) go(p);
  }

  bool showBack() {
    if (inflight) return false;
    if (route == 'aeps' &&
        (aeps.step == AepsStep.details ||
            aeps.step == AepsStep.result ||
            aeps.step == AepsStep.processing)) {
      return false;
    }
    const roots = {'dash', 'hist', 'wallet', 'more', 'welcome'};
    return !roots.contains(route);
  }

  void setLang(String value) {
    lang = value;
    notifyListeners();
    unawaited(_savePrefs());
  }

  void toggleLang() => setLang(lang == 'en' ? 'hi' : 'en');

  void toggleDark() {
    dark = !dark;
    notifyListeners();
    unawaited(_savePrefs());
  }

  void setScale(double value) {
    scale = value;
    notifyListeners();
    unawaited(_savePrefs());
  }

  Future<void> _savePrefs() async {
    if (!authed) return;
    try {
      await api.patch('/api/me/preferences', {
        'lang': lang,
        'dark': dark,
        'scale': scale,
      });
    } catch (_) {}
  }

  // ----- auth -----

  Future<void> submitLogin(String id, String pw) async {
    login.id = id;
    login.pw = pw;
    login.err = '';
    login.busy = true;
    notifyListeners();
    try {
      final res = await api.post('/auth/login', {
        'partnerId': id.trim().toUpperCase(),
        'password': pw,
      });
      login.busy = false;
      login.otp = '';
      login.otpErr = '';
      login.demoOtp = res['otp'] as String?;
      login.resendAt = DateTime.now().add(const Duration(seconds: 30));
      go('otp');
    } on ApiException catch (e) {
      login.busy = false;
      login.err = e.message;
      notifyListeners();
    }
  }

  void togglePw() {
    login.showPw = !login.showPw;
    notifyListeners();
  }

  Future<void> submitOtp(String code) async {
    login.otp = code;
    login.otpErr = '';
    login.busy = true;
    notifyListeners();
    try {
      final res = await api.post('/auth/otp', {
        'partnerId': login.id.trim().toUpperCase(),
        'otp': code,
      });
      await api.persistToken(res['token'] as String);
      await refreshSession();
      login.busy = false;
      authed = true;
      go('dash');
    } on ApiException catch (e) {
      login.busy = false;
      login.otpErr = e.message;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    login.resendAt = DateTime.now().add(const Duration(seconds: 30));
    try {
      final res = await api.post('/auth/resend', {
        'partnerId': login.id.trim().toUpperCase(),
      });
      login.demoOtp = res['otp'] as String?;
      toast(both('New code sent', 'नया कोड भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
    }
    notifyListeners();
  }

  Future<void> refreshSession() async {
    final res = await api.get('/api/me');
    data = appDataFromSession(res);
    final prefs = Map<String, dynamic>.from(res['prefs'] as Map? ?? {});
    if (prefs['lang'] is String) lang = prefs['lang'] as String;
    if (prefs['dark'] is bool) dark = prefs['dark'] as bool;
    if (prefs['scale'] is num) scale = (prefs['scale'] as num).toDouble();
    final device = prefs['deviceState'] as String?;
    scenario.device = switch (device) {
      'disconnected' => DeviceState.disconnected,
      'permission' => DeviceState.permission,
      _ => DeviceState.ready,
    };
  }

  void _applyWallet(Map<String, dynamic>? json) {
    if (json == null) return;
    data.wallet.main = (json['main'] as num?)?.toDouble() ?? data.wallet.main;
    data.wallet.aeps = (json['aeps'] as num?)?.toDouble() ?? data.wallet.aeps;
    data.wallet.earn = (json['earn'] as num?)?.toDouble() ?? data.wallet.earn;
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout');
    } catch (_) {}
    await api.clearToken();
    authed = false;
    login
      ..id = ''
      ..pw = ''
      ..showPw = false
      ..err = ''
      ..otp = ''
      ..otpErr = ''
      ..demoOtp = null
      ..busy = false;
    aeps = AepsDraft();
    data = emptyAppData();
    go('welcome');
  }

  Future<void> resetDemo() async {
    try {
      if (authed) await api.post('/api/demo/reset');
    } catch (_) {}
    await api.clearToken();
    final keepLang = lang;
    data = emptyAppData();
    aeps = AepsDraft();
    join = JoinDraft();
    hist
      ..q = ''
      ..status = 'all'
      ..svc = 'all'
      ..range = '30'
      ..loading = false;
    helpTab = 'faq';
    newReq = NewReq();
    sheet = null;
    inflight = false;
    checking.clear();
    dark = false;
    scale = 1;
    authed = false;
    lang = keepLang;
    route = 'welcome';
    params = {};
    notifyListeners();
    toast(both('Demo reset', 'डेमो रीसेट हो गया'));
  }

  // ----- join -----

  void startJoin() {
    join = JoinDraft();
    go('join');
  }

  void setRole(String role) {
    join.role = role;
    notifyListeners();
  }

  Future<void> joinNext(Map<String, String> fields) async {
    join.f.addAll(fields);
    join.tried = true;
    var ok = true;
    if (join.step == 1) {
      final req = [
        'name',
        'mobile',
        'biz',
        'type',
        'addr',
        'pin',
        'state',
        if (join.role != 'retailer') 'area',
      ];
      ok =
          req.every((k) => (join.f[k] ?? '').trim().isNotEmpty) &&
          validMobile(join.f['mobile'] ?? '') &&
          validPin(join.f['pin'] ?? '');
    }
    if (join.step == 2) {
      final docs = [
        'pancard',
        'shop',
        'cheque',
        if (join.role != 'retailer') 'gstc',
      ];
      ok =
          validPan(join.f['pan'] ?? '') &&
          join.ekyc &&
          join.agree &&
          docs.every((k) => join.docs.containsKey(k));
    }
    if (!ok) {
      notifyListeners();
      return;
    }
    if (join.step == 2) {
      join.busy = true;
      notifyListeners();
      try {
        final res = await api.post('/join', {
          'role': join.role,
          'fields': join.f,
          'docs': join.docs,
          'ekycId': join.ekycId,
        });
        final app = Map<String, dynamic>.from(res['application'] as Map);
        join.applicationId = app['id'] as String?;
        join.busy = false;
      } on ApiException catch (e) {
        join.busy = false;
        toast(e.message);
        notifyListeners();
        return;
      }
    }
    join.step++;
    join.tried = false;
    notifyListeners();
  }

  void setAgree(bool v) {
    join.agree = v;
    notifyListeners();
  }

  Future<void> runEkyc([String pan = '']) async {
    join.ekycBusy = true;
    notifyListeners();
    try {
      final value = pan.trim().toUpperCase().isEmpty
          ? (join.f['pan'] ?? '').trim().toUpperCase()
          : pan.trim().toUpperCase();
      join.f['pan'] = value;
      final res = await api.post('/join/ekyc', {
        'pan': value,
      });
      join.ekycId = (res['ekyc'] as Map?)?['id'] as String?;
      join.ekyc = true;
    } on ApiException catch (e) {
      toast(e.message);
    } finally {
      join.ekycBusy = false;
      notifyListeners();
    }
  }

  void attachDoc(String key, String name) {
    join.docs[key] = name;
    notifyListeners();
  }

  Future<void> simulateApproval() async {
    final id = join.applicationId;
    if (id == null) return;
    try {
      await api.post('/join/$id/approve');
      join.approved = true;
      notifyListeners();
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  // ----- aeps -----

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
    notifyListeners();
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
      notifyListeners();
      return false;
    }
    aeps.step = AepsStep.auth;
    aeps.capture = CapturePhase.idle;
    aeps.attempts = 0;
    aeps.consentTried = false;
    notifyListeners();
    return true;
  }

  void editAeps() {
    aeps.step = AepsStep.details;
    notifyListeners();
  }

  void setIdType(String type) {
    aeps.idType = type;
    aeps.aadhaar = '';
    notifyListeners();
  }

  void toggleShowId() {
    aeps.showId = !aeps.showId;
    notifyListeners();
  }

  void fillSample() {
    aeps.mobile = '9876543210';
    aeps.idType = 'aadhaar';
    aeps.aadhaar = sampleAadhaar();
    aeps.bank = 'sbi';
    aeps.showId = false;
    if (aeps.service == 'cw') aeps.amount = '2000';
    notifyListeners();
  }

  void pickBank(String id) {
    aeps.bank = id;
    sheet = null;
    notifyListeners();
  }

  void setConsent(bool v) {
    aeps.consent = v;
    notifyListeners();
  }

  void openBankSheet() {
    sheet = SheetModel(SheetKind.bank);
    notifyListeners();
  }

  Future<void> capture() async {
    if (!aeps.consent) {
      aeps.consentTried = true;
      notifyListeners();
      return;
    }
    if (scenario.device != DeviceState.ready) {
      notifyListeners();
      return;
    }
    if (aeps.capture == CapturePhase.capturing) return;
    aeps.capture = CapturePhase.capturing;
    notifyListeners();
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
      notifyListeners();
      return;
    }
    aeps.capture = CapturePhase.ok;
    notifyListeners();
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
    notifyListeners();

    Future<void> step(int i, int ms) async {
      await Future.delayed(Duration(milliseconds: ms));
      if (token != _seq || aeps.step != AepsStep.processing) return;
      aeps.procStep = i;
      notifyListeners();
    }

    unawaited(step(1, 700));
    unawaited(step(2, 1500));
    if (scenario.outcome == OutcomeKind.network) {
      unawaited(() async {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (token != _seq || aeps.step != AepsStep.processing) return;
        aeps.offline = true;
        notifyListeners();
      }());
    }

    try {
      final res = await api.post('/api/aeps', {
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
      data.tx.insert(0, x);
      _applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      inflight = false;
      aeps.step = AepsStep.result;
      aeps.resultRef = x.ref;
      notifyListeners();
    } on ApiException catch (e) {
      if (token != _seq) return;
      inflight = false;
      aeps.step = AepsStep.auth;
      aeps.capture = CapturePhase.idle;
      toast(e.message);
      notifyListeners();
    }
  }

  Future<void> checkDevice() async {
    aeps.devChecking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    aeps.devChecking = false;
    notifyListeners();
    if (scenario.device != DeviceState.ready) toast(t('device_still'));
  }

  void restartAeps({bool keep = true}) {
    final prev = aeps;
    aeps = keep ? prev.copyKeep() : AepsDraft();
    notifyListeners();
  }

  void doneAeps() {
    aeps = AepsDraft();
    go('dash');
  }

  Txn? txnByRef(String? ref) {
    if (ref == null) return null;
    for (final x in data.tx) {
      if (x.ref == ref) return x;
    }
    return null;
  }

  Future<void> checkStatus(String ref) async {
    final x = txnByRef(ref);
    if (x == null || checking[ref] == true) return;
    checking[ref] = true;
    notifyListeners();
    try {
      final res = await api.post('/api/transactions/$ref/check', {
        'resolve': scenario.pendingResolve,
      });
      checking[ref] = false;
      final next = txnFromJson(Map<String, dynamic>.from(res['tx'] as Map));
      final i = data.tx.indexWhere((t) => t.ref == ref);
      if (i >= 0) data.tx[i] = next;
      _applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      if (res['stillPending'] == true || next.status == TxStatus.pending) {
        toast(t('still_pending'));
      } else if (next.status == TxStatus.failed) {
        toast(t('fail_t'));
      } else {
        toast(t('ok_t'));
      }
      notifyListeners();
    } on ApiException catch (e) {
      checking[ref] = false;
      toast(e.message);
      notifyListeners();
    }
  }

  void openReceipt(String ref) {
    sheet = SheetModel(SheetKind.receipt)..ref = ref;
    notifyListeners();
  }

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

  // ----- history / wallet / banks / help -----

  List<Txn> filteredTx() {
    final q = hist.q.trim().toLowerCase();
    final now = DateTime.now();
    final days = int.tryParse(hist.range) ?? 30;
    return data.tx.where((x) {
      if (hist.status != 'all' && x.status.name != hist.status) return false;
      if (hist.svc != 'all' && x.svc != hist.svc) return false;
      if (days <= 1) {
        if (!_sameDay(x.t, now)) return false;
      } else if (now.difference(x.t) > Duration(days: days)) {
        return false;
      }
      if (q.isEmpty) return true;
      final b = bankById(x.bank);
      return x.ref.toLowerCase().contains(q) ||
          (b?.name.toLowerCase().contains(q) ?? false) ||
          x.aadhaar4.contains(q) ||
          x.mobile4.contains(q) ||
          x.rrn.contains(q);
    }).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void setHist({String? q, String? status, String? svc, String? range}) {
    if (q != null) hist.q = q;
    if (status != null) hist.status = status;
    if (svc != null) hist.svc = svc;
    if (range != null) hist.range = range;
    notifyListeners();
  }

  void clearHist() {
    hist
      ..q = ''
      ..status = 'all'
      ..svc = 'all'
      ..range = '30';
    notifyListeners();
  }

  void openSettle() {
    sheet = SheetModel(SheetKind.settle);
    notifyListeners();
  }

  void setSettleAmt(String v) {
    sheet?.amt = v;
    notifyListeners();
  }

  Future<void> submitSettle() async {
    final s = sheet;
    if (s == null) return;
    final n = int.tryParse(s.amt) ?? 0;
    s.tried = true;
    if (n < 100 || n > data.wallet.aeps) {
      notifyListeners();
      return;
    }
    try {
      final res = await api.post('/api/settlements', {'amount': n});
      data.settlements.insert(
        0,
        settlementFromJson(Map<String, dynamic>.from(res['settlement'] as Map)),
      );
      _applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      sheet = null;
      notifyListeners();
      toast(both('Settlement requested', 'सेटलमेंट अनुरोध भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
    }
  }

  void openAddBank() {
    sheet = SheetModel(SheetKind.addBank);
    notifyListeners();
  }

  Future<void> submitBank(Map<String, String> f) async {
    final s = sheet;
    if (s == null) return;
    s.f = f;
    s.tried = true;
    final ok =
        (f['holder'] ?? '').trim().isNotEmpty &&
        validAccount(f['acct'] ?? '') &&
        f['acct'] == f['acct2'] &&
        validIfsc(f['ifsc'] ?? '');
    if (!ok) {
      notifyListeners();
      return;
    }
    try {
      final res = await api.post('/api/accounts', {
        'holder': f['holder'],
        'acct': f['acct'],
        'acct2': f['acct2'],
        'ifsc': f['ifsc']!.toUpperCase(),
      });
      data.accounts.add(
        accountFromJson(Map<String, dynamic>.from(res['account'] as Map)),
      );
      sheet = null;
      notifyListeners();
      toast(
        both(
          'Account added. Verification in progress.',
          'खाता जोड़ा गया, सत्यापन जारी।',
        ),
      );
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
    }
  }

  void closeSheet() {
    sheet = null;
    notifyListeners();
  }

  void setHelpTab(String v) {
    helpTab = v;
    notifyListeners();
  }

  void setReqType(String v) {
    newReq.type = v;
    notifyListeners();
  }

  void unlinkReq() {
    newReq.ref = '';
    notifyListeners();
  }

  void setReqRef(String v) {
    newReq.ref = v;
    notifyListeners();
  }

  Future<bool> submitTicket(String msg) async {
    newReq.msg = msg;
    newReq.tried = true;
    if (newReq.type.isEmpty || msg.trim().length < 10) {
      notifyListeners();
      return false;
    }
    final labels = issues[lang] ?? issues['en'] ?? const <String>[];
    final idx = int.tryParse(newReq.type) ?? -1;
    if (idx < 0 || idx >= labels.length) {
      notifyListeners();
      return false;
    }
    final type = labels[idx];
    try {
      final res = await api.post('/api/tickets', {
        'type': type,
        'message': msg.trim(),
        'ref': newReq.ref,
      });
      final k = ticketFromJson(Map<String, dynamic>.from(res['ticket'] as Map));
      data.tickets.insert(0, k);
      go('ticket', params: {'id': k.id, 'fresh': '1'});
      return true;
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
      return false;
    }
  }

  void setDevTab(String v) {
    devTab = v;
    notifyListeners();
  }

  Future<void> testCapture() async {
    devTest = 'run';
    notifyListeners();
    try {
      await api.post('/api/device/test');
      if (route == 'device') {
        devTest = 'done';
        notifyListeners();
      }
    } on ApiException catch (e) {
      devTest = 'idle';
      toast(e.message);
      notifyListeners();
    }
  }

  Future<void> recheckDevicePage() async {
    try {
      final res = await api.get('/api/device');
      final state = res['state'] as String? ?? 'ready';
      scenario.device = switch (state) {
        'disconnected' => DeviceState.disconnected,
        'permission' => DeviceState.permission,
        _ => DeviceState.ready,
      };
    } catch (_) {}
    devTest = 'idle';
    notifyListeners();
    toast(
      scenario.device == DeviceState.ready
          ? t('dev_ready')
          : both('Device still not ready.', 'डिवाइस अभी भी तैयार नहीं है।'),
    );
  }

  void openScenarios() {
    sheet = SheetModel(SheetKind.scenarios);
    notifyListeners();
  }

  void setOutcome(OutcomeKind v) {
    scenario.outcome = v;
    notifyListeners();
  }

  void setFailReason(String v) {
    scenario.failReason = v;
    notifyListeners();
  }

  void setPendingResolve(String v) {
    scenario.pendingResolve = v;
    notifyListeners();
  }

  void setDevice(DeviceState v) {
    scenario.device = v;
    notifyListeners();
    if (!authed) return;
    unawaited(() async {
      try {
        await api.patch('/api/device', {'state': v.name});
      } catch (_) {}
    }());
  }

  void setCaptureRetry(bool v) {
    scenario.captureRetry = v;
    notifyListeners();
  }

  void openProfile() {
    sheet = SheetModel(SheetKind.profile);
    notifyListeners();
  }

  void openPassword() {
    sheet = SheetModel(SheetKind.password);
    notifyListeners();
  }

  void openTopup() {
    sheet = SheetModel(SheetKind.topup);
    notifyListeners();
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
      notifyListeners();
      return;
    }
    try {
      final res = await api.patch('/api/me', {
        'name': f['name']!.trim(),
        'shop': f['shop']!.trim(),
        'city': f['city']!.trim(),
        'mobile': f['mobile']!.trim(),
      });
      data.retailer = retailerFromJson(
        Map<String, dynamic>.from(res['retailer'] as Map),
      );
      sheet = null;
      notifyListeners();
      toast(both('Profile saved', 'प्रोफ़ाइल सेव हो गई'));
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
    }
  }

  Future<void> submitPassword(String current, String next) async {
    final s = sheet;
    if (s == null) return;
    s.tried = true;
    if (current.isEmpty || next.length < 8) {
      notifyListeners();
      return;
    }
    try {
      await api.post('/api/me/password', {'current': current, 'next': next});
      sheet = null;
      notifyListeners();
      toast(both('Password updated', 'पासवर्ड बदल गया'));
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
    }
  }

  Future<void> submitTopup() async {
    final s = sheet;
    if (s == null) return;
    final n = int.tryParse(s.amt) ?? 0;
    s.tried = true;
    if (n < 100 || n > 50000) {
      notifyListeners();
      return;
    }
    try {
      final res = await api.post('/api/wallet/topup', {'amount': n});
      _applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      sheet = null;
      notifyListeners();
      toast(both('Top-up recorded', 'टॉप-अप दर्ज हो गया'));
    } on ApiException catch (e) {
      toast(e.message);
      notifyListeners();
    }
  }

  Future<void> startForgot() async {
    login.err = '';
    login.otp = '';
    login.otpErr = '';
    login.demoOtp = null;
    go('forgot');
  }

  Future<void> submitForgot(String id) async {
    login.id = id;
    login.err = '';
    login.busy = true;
    notifyListeners();
    try {
      final res = await api.post('/auth/forgot', {
        'partnerId': id.trim().toUpperCase(),
      });
      login.busy = false;
      login.demoOtp = res['otp'] as String?;
      login.resendAt = DateTime.now().add(const Duration(seconds: 30));
      go('forgot-otp');
    } on ApiException catch (e) {
      login.busy = false;
      login.err = e.message;
      notifyListeners();
    }
  }

  Future<void> confirmForgot(String otp, String password) async {
    login.otp = otp;
    login.otpErr = '';
    login.busy = true;
    notifyListeners();
    try {
      await api.post('/auth/forgot/confirm', {
        'partnerId': login.id.trim().toUpperCase(),
        'otp': otp,
        'password': password,
      });
      login.busy = false;
      toast(both('Password reset. Sign in.', 'पासवर्ड रीसेट हो गया। लॉग इन करें।'));
      go('login');
    } on ApiException catch (e) {
      login.busy = false;
      login.otpErr = e.message;
      notifyListeners();
    }
  }

  Future<void> receiptAction(String kind, {String? ref}) async {
    final id = ref ?? sheet?.ref ?? '';
    if (id.isEmpty) return;
    try {
      await api.post('/api/receipts/$id/actions', {'kind': kind});
      toast(t(switch (kind) {
        'print' => 'sim_print',
        'download' => 'sim_dl',
        _ => 'sim_share',
      }));
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  Future<void> requestExport() async {
    try {
      await api.post('/api/exports', {'range': hist.range, 'format': 'csv'});
      toast(both('Export requested', 'एक्सपोर्ट अनुरोध भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  Future<void> deviceRequest(String kind) async {
    try {
      await api.post('/api/device/requests', {'kind': kind});
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
