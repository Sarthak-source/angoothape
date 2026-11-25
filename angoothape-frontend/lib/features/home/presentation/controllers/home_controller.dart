import '../../../../core/api/api_exception.dart';
import '../../../../core/enums.dart';
import '../../../../core/utils/format.dart';
import '../../../aeps/domain/entities/bank.dart';
import '../../../aeps/domain/entities/scenario.dart';
import '../../../session/domain/entities/app_data.dart';
import '../../../session/domain/entities/sheet_model.dart';
import '../../data/models/home_mappers.dart';
import '../../domain/entities/txn.dart';
import '../../domain/repositories/home_repository.dart';

mixin HomeController {
  HomeRepository get homeRepository;
  AppData get data;
  HistFilter get hist;
  Scenario get scenario;
  SheetModel? get sheet;
  set sheet(SheetModel? value);
  Map<String, bool> get checking;
  String get route;

  void emit();
  void go(String next, {Map<String, String>? params});
  void toast(String msg, {bool sim = false});
  String both(String en, String hindi);
  String t(String key);
  void applyWallet(Map<String, dynamic>? json);

  Future<void> loadHistory() async {
    hist.loading = true;
    try {
      final res = await homeRepository.transactions(
        q: hist.q,
        status: hist.status,
        svc: hist.svc,
        range: hist.range,
      );
      data.replaceTx([
        for (final x in res['tx'] as List? ?? [])
          txnFromJson(Map<String, dynamic>.from(x as Map)),
      ]);
    } catch (_) {
    } finally {
      hist.loading = false;
      if (route == 'hist') emit();
    }
  }

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
          (b?.nameLower.contains(q) ?? false) ||
          x.aadhaar4.contains(q) ||
          x.mobile4.contains(q) ||
          x.rrn.contains(q);
    }).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Txn> todaysTx([DateTime? now]) {
    final n = now ?? DateTime.now();
    return data.tx.where((x) => _sameDay(x.t, n)).toList();
  }

  int todayCashValue([DateTime? now]) {
    return todaysTx(now)
        .where((x) => x.status == TxStatus.success && x.svc == 'cw')
        .fold<int>(0, (a, x) => a + x.amt);
  }

  String greeting({required bool hi, DateTime? now}) {
    if (hi) return 'नमस्ते';
    final hr = (now ?? DateTime.now()).hour;
    if (hr < 12) return 'Good morning';
    if (hr < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void setHist({String? q, String? status, String? svc, String? range}) {
    if (q != null) hist.q = q;
    if (status != null) hist.status = status;
    if (svc != null) hist.svc = svc;
    if (range != null) hist.range = range;
    emit();
  }

  void clearHist() {
    hist
      ..q = ''
      ..status = 'all'
      ..svc = 'all'
      ..range = '30';
    emit();
  }

  Txn? txnByRef(String? ref) => ref == null ? null : data.txByRef[ref];

  Future<void> checkStatus(String ref) async {
    final x = txnByRef(ref);
    if (x == null || checking[ref] == true) return;
    checking[ref] = true;
    emit();
    try {
      final res = await homeRepository.checkTransaction(
        ref,
        body: {'resolve': scenario.pendingResolve},
      );
      checking[ref] = false;
      final next = txnFromJson(Map<String, dynamic>.from(res['tx'] as Map));
      data.putTx(next);
      applyWallet(
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
      emit();
    } on ApiException catch (e) {
      checking[ref] = false;
      toast(e.message);
      emit();
    }
  }

  void openReceipt(String ref) {
    sheet = SheetModel(SheetKind.receipt)..ref = ref;
    emit();
  }

  void openSettle() {
    sheet = SheetModel(SheetKind.settle);
    emit();
  }

  void setSettleAmt(String v) {
    sheet?.amt = v;
    emit();
  }

  Future<void> submitSettle() async {
    final s = sheet;
    if (s == null) return;
    final n = int.tryParse(s.amt) ?? 0;
    s.tried = true;
    if (n < 100 || n > data.wallet.aeps) {
      emit();
      return;
    }
    try {
      final res = await homeRepository.settle(amount: n);
      data.settlements.insert(
        0,
        settlementFromJson(Map<String, dynamic>.from(res['settlement'] as Map)),
      );
      applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      sheet = null;
      emit();
      toast(both('Settlement requested', 'सेटलमेंट अनुरोध भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
      emit();
    }
  }

  void openAddBank() {
    sheet = SheetModel(SheetKind.addBank);
    emit();
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
      emit();
      return;
    }
    try {
      final res = await homeRepository.addAccount(
        holder: f['holder']!,
        acct: f['acct']!,
        acct2: f['acct2']!,
        ifsc: f['ifsc']!.toUpperCase(),
      );
      data.addAccount(
        accountFromJson(Map<String, dynamic>.from(res['account'] as Map)),
      );
      sheet = null;
      emit();
      toast(
        both(
          'Account added. Verification in progress.',
          'खाता जोड़ा गया, सत्यापन जारी।',
        ),
      );
    } on ApiException catch (e) {
      toast(e.message);
      emit();
    }
  }

  void openTopup() {
    sheet = SheetModel(SheetKind.topup);
    emit();
  }

  Future<void> submitTopup() async {
    final s = sheet;
    if (s == null) return;
    final n = int.tryParse(s.amt) ?? 0;
    s.tried = true;
    if (n < 100 || n > 50000) {
      emit();
      return;
    }
    try {
      final res = await homeRepository.topup(amount: n);
      applyWallet(
        res['wallet'] == null
            ? null
            : Map<String, dynamic>.from(res['wallet'] as Map),
      );
      sheet = null;
      emit();
      toast(both('Top-up recorded', 'टॉप-अप दर्ज हो गया'));
    } on ApiException catch (e) {
      toast(e.message);
      emit();
    }
  }

  Future<void> receiptAction(String kind, {String? ref}) async {
    final id = ref ?? sheet?.ref ?? '';
    if (id.isEmpty) return;
    try {
      await homeRepository.receiptAction(id, kind: kind);
      toast(
        t(switch (kind) {
          'print' => 'sim_print',
          'download' => 'sim_dl',
          _ => 'sim_share',
        }),
      );
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  Future<void> requestExport() async {
    try {
      await homeRepository.exportCsv(range: hist.range);
      toast(both('Export requested', 'एक्सपोर्ट अनुरोध भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
    }
  }
}
