enum TxStatus { success, failed, pending }

enum AepsStep { details, auth, processing, result }

enum CapturePhase { idle, capturing, ok, failed, locked }

enum DeviceState { ready, disconnected, permission }

enum OutcomeKind { success, failed, pending, network }

class Bank {
  Bank({
    required this.id,
    required this.name,
    required this.short,
    required this.color,
    required this.popular,
    this.ifscPrefix,
  });
  final String id;
  final String name;
  final String short;
  final int color;
  final bool popular;
  final String? ifscPrefix;

  late final String nameLower = name.toLowerCase();
  late final String shortLower = short.toLowerCase();
}

List<Bank> banks = <Bank>[];
List<Bank> popularBanks = const <Bank>[];
final Map<String, Bank> _banksById = {};

Bank? bankById(String? id) => id == null ? null : _banksById[id];

Map<String, String> ifscBank = <String, String>{};

Map<String, List<(String, String)>> faqs = {
  'en': [],
  'hi': [],
};

Map<String, List<String>> issues = {
  'en': [],
  'hi': [],
};

Map<String, List<(String, String)>> _futureServices = {
  'en': [],
  'hi': [],
};

List<(String, String)> futureServices(String lang) =>
    _futureServices[lang] ?? _futureServices['en']!;

void applyCatalog({
  required List<Bank> nextBanks,
  required Map<String, List<(String, String)>> nextFaqs,
  required Map<String, List<String>> nextIssues,
  required Map<String, List<(String, String)>> nextFuture,
  Map<String, Map<String, List<String>>> nextGuides = const {},
  Map<String, List<(String, List<String>)>> nextDeviceFaqs = const {},
  Map<String, ReasonCopy> nextReasons = const {},
}) {
  banks
    ..clear()
    ..addAll(nextBanks);
  _banksById
    ..clear()
    ..addEntries(nextBanks.map((b) => MapEntry(b.id, b)));
  popularBanks = [for (final b in nextBanks) if (b.popular) b];
  ifscBank
    ..clear()
    ..addAll({
      for (final b in nextBanks)
        if (b.ifscPrefix != null && b.ifscPrefix!.isNotEmpty)
          b.ifscPrefix!: b.id,
    });
  faqs
    ..clear()
    ..addAll(nextFaqs);
  issues
    ..clear()
    ..addAll(nextIssues);
  _futureServices
    ..clear()
    ..addAll(nextFuture);
  if (nextGuides.isNotEmpty) {
    deviceGuides
      ..clear()
      ..addAll(nextGuides);
  }
  if (nextDeviceFaqs.isNotEmpty) {
    deviceFaqs
      ..clear()
      ..addAll(nextDeviceFaqs);
  }
  if (nextReasons.isNotEmpty) {
    reasons
      ..clear()
      ..addAll(nextReasons);
  }
}

class Retailer {
  Retailer({
    required this.id,
    required this.name,
    required this.shop,
    required this.city,
    required this.mobile,
    this.mobileFull = '',
    required this.role,
    required this.distributor,
  });

  final String id;
  final String name;
  final String shop;
  final String city;
  final String mobile;
  final String mobileFull;
  final String role;
  final String distributor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AP';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w.padRight(2, 'P')).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Retailer empty() => Retailer(
    id: '',
    name: '',
    shop: '',
    city: '',
    mobile: '',
    mobileFull: '',
    role: '',
    distributor: '',
  );
}

List<String> deviceGuide(String platform, String lang) =>
    (deviceGuides[platform]?[lang] ?? deviceGuides[platform]?['en'] ?? const []);

Map<String, Map<String, List<String>>> deviceGuides = {};

Map<String, List<(String, List<String>)>> deviceFaqs = {
  'en': [],
  'hi': [],
};

class MiniLine {
  MiniLine({required this.label, required this.date, required this.amount});
  final String label;
  final DateTime date;
  final int amount;
}

class Txn {
  Txn({
    required this.t,
    required this.svc,
    required this.amt,
    required this.bank,
    required this.aadhaar4,
    required this.mobile4,
    required this.status,
    required this.ref,
    required this.rrn,
    this.reason,
    this.bal,
    this.unknown = false,
    this.earn = 0,
    this.checks = 0,
    this.credited = false,
    this.mini = const [],
  });

  final DateTime t;
  final String svc;
  final int amt;
  final String bank;
  final String aadhaar4;
  final String mobile4;
  TxStatus status;
  final String ref;
  final String rrn;
  String? reason;
  double? bal;
  bool unknown;
  double earn;
  int checks;
  bool credited;
  List<MiniLine> mini;
}

class Wallet {
  Wallet({required this.main, required this.aeps, required this.earn});
  double main;
  double aeps;
  double earn;
}

class Settlement {
  Settlement({
    required this.id,
    required this.t,
    required this.amt,
    required this.acct,
    required this.status,
    this.utr,
    this.note,
  });
  final String id;
  final DateTime t;
  final int amt;
  final String acct;
  final String status;
  final String? utr;
  final String? note;
}

class BankAccount {
  BankAccount({
    required this.id,
    required this.bank,
    required this.last4,
    required this.holder,
    required this.ifsc,
    required this.status,
    this.primary = false,
    this.note,
  });
  final String id;
  final String bank;
  final String last4;
  final String holder;
  final String ifsc;
  final String status;
  final bool primary;
  final String? note;
}

class Ticket {
  Ticket({
    required this.id,
    required this.t,
    required this.type,
    required this.status,
    required this.msg,
    this.ref,
  });
  final String id;
  final DateTime t;
  final String type;
  final String status;
  final String msg;
  final String? ref;
}

class AppData {
  AppData({
    required this.retailer,
    required this.tx,
    required this.wallet,
    required this.settlements,
    required this.accounts,
    required this.tickets,
  }) {
    index();
  }
  Retailer retailer;
  final List<Txn> tx;
  final Wallet wallet;
  final List<Settlement> settlements;
  final List<BankAccount> accounts;
  final List<Ticket> tickets;
  final Map<String, Txn> txByRef = {};
  final Map<String, Ticket> ticketById = {};
  final Map<String, List<Ticket>> ticketsByRef = {};
  final Map<String, String> last4ByBank = {};

  void index() {
    txByRef
      ..clear()
      ..addEntries(tx.map((x) => MapEntry(x.ref, x)));
    ticketById
      ..clear()
      ..addEntries(tickets.map((k) => MapEntry(k.id, k)));
    ticketsByRef.clear();
    for (final k in tickets) {
      final ref = k.ref;
      if (ref != null && ref.isNotEmpty) {
        (ticketsByRef[ref] ??= []).add(k);
      }
    }
    last4ByBank.clear();
    for (final a in accounts) {
      last4ByBank.putIfAbsent(a.bank, () => a.last4);
    }
  }

  void replaceTx(Iterable<Txn> next) {
    tx
      ..clear()
      ..addAll(next);
    txByRef
      ..clear()
      ..addEntries(tx.map((x) => MapEntry(x.ref, x)));
  }

  void prependTx(Txn x) {
    tx.insert(0, x);
    txByRef[x.ref] = x;
  }

  void putTx(Txn next) {
    final i = tx.indexWhere((t) => t.ref == next.ref);
    if (i >= 0) tx[i] = next;
    txByRef[next.ref] = next;
  }

  void addAccount(BankAccount a) {
    accounts.add(a);
    last4ByBank.putIfAbsent(a.bank, () => a.last4);
  }

  void prependTicket(Ticket k) {
    tickets.insert(0, k);
    ticketById[k.id] = k;
    final ref = k.ref;
    if (ref != null && ref.isNotEmpty) {
      (ticketsByRef[ref] ??= []).insert(0, k);
    }
  }
}

AppData emptyAppData() => AppData(
  retailer: Retailer.empty(),
  tx: [],
  wallet: Wallet(main: 0, aeps: 0, earn: 0),
  settlements: [],
  accounts: [],
  tickets: [],
);

class AepsDraft {
  AepsStep step = AepsStep.details;
  String service = 'cw';
  String mobile = '';
  String aadhaar = '';
  String idType = 'aadhaar';
  bool showId = false;
  String? bank;
  String amount = '';
  bool consent = false;
  bool consentTried = false;
  bool tried = false;
  CapturePhase capture = CapturePhase.idle;
  int attempts = 0;
  bool devChecking = false;
  String? resultRef;
  int procStep = 0;
  bool offline = false;

  AepsDraft copyKeep() => AepsDraft()
    ..service = service
    ..mobile = mobile
    ..bank = bank
    ..amount = amount;
}

class Scenario {
  OutcomeKind outcome = OutcomeKind.success;
  String failReason = 'insufficient';
  String pendingResolve = 'success';
  DeviceState device = DeviceState.ready;
  bool captureRetry = false;
}

class LoginDraft {
  String id = '';
  String pw = '';
  bool showPw = false;
  String err = '';
  String otp = '';
  String otpErr = '';
  String? demoOtp;
  DateTime resendAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool busy = false;
}

class JoinDraft {
  int step = 0;
  String role = 'retailer';
  Map<String, String> f = {};
  Map<String, String> docs = {};
  bool ekyc = false;
  bool agree = false;
  bool tried = false;
  bool approved = false;
  bool ekycBusy = false;
  bool busy = false;
  String? applicationId;
  String? ekycId;
}

class HistFilter {
  String q = '';
  String status = 'all';
  String svc = 'all';
  String range = '30';
  bool loading = false;
}

class NewReq {
  String ref = '';
  String type = '';
  String msg = '';
  bool tried = false;
}

enum SheetKind { bank, receipt, settle, addBank, scenarios, profile, password, topup }

class SheetModel {
  SheetModel(this.kind);
  final SheetKind kind;
  String q = '';
  String ref = '';
  String amt = '';
  bool tried = false;
  Map<String, String> f = {};
}

class ReasonCopy {
  const ReasonCopy({
    required this.en,
    required this.hi,
    required this.nextEn,
    required this.nextHi,
  });
  final String en;
  final String hi;
  final String nextEn;
  final String nextHi;
  String text(String lang) => lang == 'hi' ? hi : en;
  String next(String lang) => lang == 'hi' ? nextHi : nextEn;
}

final reasons = <String, ReasonCopy>{
  'insufficient': ReasonCopy(
    en: "Customer's account has insufficient balance.",
    hi: 'ग्राहक के खाते में पर्याप्त बैलेंस नहीं है।',
    nextEn: 'Ask the customer to try a smaller amount or check their balance.',
    nextHi: 'ग्राहक से कम राशि आज़माने या बैलेंस जाँचने को कहें।',
  ),
  'bio': ReasonCopy(
    en: "Fingerprint didn't match Aadhaar records.",
    hi: 'फ़िंगरप्रिंट आधार रिकॉर्ड से मेल नहीं खाया।',
    nextEn: 'Try another finger. If it keeps failing, the customer may need to update biometrics at an Aadhaar centre.',
    nextHi: 'दूसरी उंगली आज़माएँ। बार-बार असफल हो तो ग्राहक को आधार केंद्र पर बायोमेट्रिक अपडेट करवाना पड़ सकता है।',
  ),
  'bankdown': ReasonCopy(
    en: "Customer's bank is not responding right now.",
    hi: 'ग्राहक का बैंक अभी जवाब नहीं दे रहा।',
    nextEn: 'Try again in a few minutes or use another bank account if the customer has one.',
    nextHi: 'कुछ मिनट बाद फिर कोशिश करें या ग्राहक का दूसरा बैंक खाता इस्तेमाल करें।',
  ),
  'timeout': ReasonCopy(
    en: 'Bank did not confirm the transaction. It was marked failed.',
    hi: 'बैंक ने लेन-देन की पुष्टि नहीं की। इसे असफल माना गया।',
    nextEn: 'If the customer was debited, the bank reverses it automatically. Raise a support request to track it.',
    nextHi: 'अगर पैसा कटा है तो बैंक अपने-आप लौटा देगा। ट्रैक करने के लिए सहायता अनुरोध करें।',
  ),
};
