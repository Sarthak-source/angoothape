import 'dart:async';

import 'package:flutter/material.dart';

import '../../../aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../../../aeps/domain/usecases/check_aeps_status_usecase.dart';
import '../../../aeps/domain/usecases/submit_aeps_usecase.dart';
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
  AppController({
    required this.submitAepsUseCase,
    required this.checkAepsStatusUseCase,
    required this.captureFingerprintUseCase,
  });

  final SubmitAepsUseCase submitAepsUseCase;
  final CheckAepsStatusUseCase checkAepsStatusUseCase;
  final CaptureFingerprintUseCase captureFingerprintUseCase;

  String lang = 'en';
  bool authed = false;
  bool dark = false;
  double scale = 1;
  String route = 'welcome';
  Map<String, String> params = {};
  LayoutProfile layout = const LayoutService().resolve(400);
  bool inflight = false;

  final scenario = Scenario();
  AppData data = seedData();
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
      Future.delayed(const Duration(milliseconds: 450), () {
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
  }

  void toggleLang() => setLang(lang == 'en' ? 'hi' : 'en');

  void toggleDark() {
    dark = !dark;
    notifyListeners();
  }

  void setScale(double value) {
    scale = value;
    notifyListeners();
  }

  // ----- auth -----

  Future<void> submitLogin(String id, String pw) async {
    login.id = id;
    login.pw = pw;
    if (id.trim().toUpperCase() == DemoLogin.id && pw == DemoLogin.password) {
      login.err = '';
      login.busy = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      login.busy = false;
      login.otp = '';
      login.otpErr = '';
      login.resendAt = DateTime.now().add(const Duration(seconds: 30));
      go('otp');
    } else {
      login.err = t('err_login');
      notifyListeners();
    }
  }

  void togglePw() {
    login.showPw = !login.showPw;
    notifyListeners();
  }

  Future<void> submitOtp(String code) async {
    login.otp = code;
    if (code == DemoLogin.otp) {
      login.busy = true;
      login.otpErr = '';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      login.busy = false;
      authed = true;
      go('dash');
    } else {
      login.otpErr = t('err_otp');
      notifyListeners();
    }
  }

  void resendOtp() {
    login.resendAt = DateTime.now().add(const Duration(seconds: 30));
    toast(both('New code sent (demo)', 'नया कोड भेजा गया (डेमो)'));
  }

  void logout() {
    authed = false;
    login
      ..id = ''
      ..pw = ''
      ..showPw = false
      ..err = ''
      ..otp = ''
      ..otpErr = ''
      ..busy = false;
    aeps = AepsDraft();
    go('welcome');
  }

  void resetDemo() {
    final keepLang = lang;
    final keepScenario = scenario;
    data = seedData();
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
    // scenario is the same object; keep user's demo switches
    assert(identical(keepScenario, scenario));
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

  void joinNext(Map<String, String> fields) {
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
    join.step++;
    join.tried = false;
    notifyListeners();
  }

  void setAgree(bool v) {
    join.agree = v;
    notifyListeners();
  }

  Future<void> runEkyc() async {
    join.ekycBusy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    join.ekycBusy = false;
    join.ekyc = true;
    notifyListeners();
  }

  void attachDoc(String key, String name) {
    join.docs[key] = name;
    notifyListeners();
  }

  void simulateApproval() {
    join.approved = true;
    notifyListeners();
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

    final result = await submitAepsUseCase(
      outcome: scenario.outcome,
      failReason: scenario.failReason,
    );
    if (token != _seq) return;

    final status = result.status;
    final reason = result.reason;
    final bal = result.balance;
    final unknown = result.unknown;

    final now = DateTime.now();
    final x = Txn(
      t: now,
      svc: reqSvc,
      amt: reqAmt,
      bank: reqBank,
      aadhaar4: aadhaar4,
      mobile4: mobile4,
      status: status,
      reason: reason,
      bal: bal,
      unknown: unknown,
      ref: newRef(now, data.tx.length),
      rrn: newRrn(),
    );
    if (x.status == TxStatus.success) _applySuccess(x);
    data.tx.insert(0, x);
    inflight = false;
    aeps.step = AepsStep.result;
    aeps.resultRef = x.ref;
    notifyListeners();
  }

  void _applySuccess(Txn x) {
    if (x.credited) return;
    if (x.svc == 'cw' && x.status == TxStatus.success) {
      x.earn = 5;
      data.wallet.aeps += x.amt;
      data.wallet.earn += x.earn;
      x.credited = true;
    } else {
      x.credited = true;
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
    final checksAfter = x.checks + 1;
    final result = await checkAepsStatusUseCase(
      unknown: x.unknown,
      checksAfterThis: checksAfter,
      pendingResolve: scenario.pendingResolve,
    );
    x.checks = checksAfter;
    checking[ref] = false;
    if (result.status == TxStatus.pending) {
      toast(t('still_pending'));
      notifyListeners();
      return;
    }
    x.status = result.status;
    x.unknown = false;
    if (result.status == TxStatus.failed) {
      x.reason = result.reason;
      toast(t('fail_t'));
    } else {
      x.bal = result.balance;
      _applySuccess(x);
      toast(t('ok_t'));
    }
    notifyListeners();
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

  void submitSettle() {
    final s = sheet;
    if (s == null) return;
    final n = int.tryParse(s.amt) ?? 0;
    s.tried = true;
    if (n < 100 || n > data.wallet.aeps) {
      notifyListeners();
      return;
    }
    data.wallet.aeps -= n;
    data.settlements.insert(
      0,
      Settlement(
        id: 'ST-${10450 + data.settlements.length}',
        t: DateTime.now(),
        amt: n,
        acct: 'sbi',
        status: 'processing',
      ),
    );
    sheet = null;
    notifyListeners();
    toast(
      both('Settlement requested (demo)', 'सेटलमेंट अनुरोध भेजा गया (डेमो)'),
    );
  }

  void openAddBank() {
    sheet = SheetModel(SheetKind.addBank);
    notifyListeners();
  }

  void submitBank(Map<String, String> f) {
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
    final ifsc = f['ifsc']!;
    final bank = ifscBank[ifsc.substring(0, 4)] ?? 'sbi';
    data.accounts.add(
      BankAccount(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        bank: bank,
        last4: f['acct']!.substring(f['acct']!.length - 4),
        holder: f['holder']!.toUpperCase(),
        ifsc: ifsc,
        status: 'pending',
      ),
    );
    sheet = null;
    notifyListeners();
    toast(
      both(
        'Account added. Verification in progress (demo).',
        'खाता जोड़ा गया, सत्यापन जारी (डेमो)',
      ),
    );
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

  bool submitTicket(String msg) {
    newReq.msg = msg;
    newReq.tried = true;
    if (newReq.type.isEmpty || msg.trim().length < 10) {
      notifyListeners();
      return false;
    }
    final type = issues[lang]![int.parse(newReq.type)];
    final k = Ticket(
      id: 'SR-${20900 + data.tickets.length}',
      t: DateTime.now(),
      type: type,
      ref: newReq.ref.isEmpty ? null : newReq.ref,
      status: 'Open',
      msg: msg.trim(),
    );
    data.tickets.insert(0, k);
    go('ticket', params: {'id': k.id, 'fresh': '1'});
    return true;
  }

  void setDevTab(String v) {
    devTab = v;
    notifyListeners();
  }

  Future<void> testCapture() async {
    devTest = 'run';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (route == 'device') {
      devTest = 'done';
      notifyListeners();
    }
  }

  void recheckDevicePage() {
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
  }

  void setCaptureRetry(bool v) {
    scenario.captureRetry = v;
    notifyListeners();
  }

  void sim(String key) {
    final msg = switch (key) {
      'print' => t('sim_print'),
      'download' => t('sim_dl'),
      'share' => t('sim_share'),
      'export' => both(
        'Simulated: production exports CSV/PDF.',
        'सिम्युलेटेड: असली ऐप में CSV/PDF एक्सपोर्ट होगा।',
      ),
      'topup' => both(
        'Simulated: wallet top-up is a future module.',
        'सिम्युलेटेड: वॉलेट टॉप-अप भविष्य का मॉड्यूल है।',
      ),
      'forgot' => both(
        'Simulated: password reset will use an OTP to your registered mobile.',
        'सिम्युलेटेड: पासवर्ड रीसेट OTP से होगा।',
      ),
      'repair' => both(
        'Simulated: device repair requests come later.',
        'सिम्युलेटेड: मरम्मत अनुरोध भविष्य में।',
      ),
      'buy' => both(
        'Simulated: device ordering comes later.',
        'सिम्युलेटेड: डिवाइस खरीद भविष्य में।',
      ),
      'pw' => both('Simulated in this prototype.', 'सिम्युलेटेड।'),
      _ => both('Simulated.', 'सिम्युलेटेड।'),
    };
    toast(msg, sim: true);
  }
}
