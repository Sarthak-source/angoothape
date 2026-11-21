import 'dart:math';

import '../../../../core/utils/format.dart';

enum TxStatus { success, failed, pending }

enum AepsStep { details, auth, processing, result }

enum CapturePhase { idle, capturing, ok, failed, locked }

enum DeviceState { ready, disconnected, permission }

enum OutcomeKind { success, failed, pending, network }

class Bank {
  const Bank({
    required this.id,
    required this.name,
    required this.short,
    required this.color,
    required this.popular,
  });
  final String id;
  final String name;
  final String short;
  final int color;
  final bool popular;
}

const banks = <Bank>[
  Bank(
    id: 'sbi',
    name: 'State Bank of India',
    short: 'SBI',
    color: 0xFF1D4F91,
    popular: true,
  ),
  Bank(
    id: 'pnb',
    name: 'Punjab National Bank',
    short: 'PNB',
    color: 0xFFA3195B,
    popular: true,
  ),
  Bank(
    id: 'bob',
    name: 'Bank of Baroda',
    short: 'BoB',
    color: 0xFFE2611F,
    popular: true,
  ),
  Bank(
    id: 'boi',
    name: 'Bank of India',
    short: 'BoI',
    color: 0xFF1B6FB6,
    popular: true,
  ),
  Bank(
    id: 'ubi',
    name: 'Union Bank of India',
    short: 'Union',
    color: 0xFFC8102E,
    popular: true,
  ),
  Bank(
    id: 'cnb',
    name: 'Canara Bank',
    short: 'Canara',
    color: 0xFF0071BC,
    popular: true,
  ),
  Bank(
    id: 'cbi',
    name: 'Central Bank of India',
    short: 'Central',
    color: 0xFFB22234,
    popular: true,
  ),
  Bank(
    id: 'ib',
    name: 'Indian Bank',
    short: 'Indian',
    color: 0xFF1C3F94,
    popular: true,
  ),
  Bank(
    id: 'bom',
    name: 'Bank of Maharashtra',
    short: 'BoM',
    color: 0xFF2B5DA8,
    popular: false,
  ),
  Bank(
    id: 'iob',
    name: 'Indian Overseas Bank',
    short: 'IOB',
    color: 0xFF2C3E8F,
    popular: false,
  ),
  Bank(
    id: 'uco',
    name: 'UCO Bank',
    short: 'UCO',
    color: 0xFF1F5AA6,
    popular: false,
  ),
  Bank(
    id: 'psb',
    name: 'Punjab & Sind Bank',
    short: 'P&S',
    color: 0xFF2E7D32,
    popular: false,
  ),
  Bank(
    id: 'hdfc',
    name: 'HDFC Bank',
    short: 'HDFC',
    color: 0xFF004C8F,
    popular: false,
  ),
  Bank(
    id: 'icici',
    name: 'ICICI Bank',
    short: 'ICICI',
    color: 0xFFAE282E,
    popular: false,
  ),
  Bank(
    id: 'axis',
    name: 'Axis Bank',
    short: 'Axis',
    color: 0xFF97144D,
    popular: false,
  ),
  Bank(
    id: 'kotak',
    name: 'Kotak Mahindra Bank',
    short: 'Kotak',
    color: 0xFFED1C24,
    popular: false,
  ),
  Bank(
    id: 'idbi',
    name: 'IDBI Bank',
    short: 'IDBI',
    color: 0xFF00836C,
    popular: false,
  ),
  Bank(
    id: 'ippb',
    name: 'India Post Payments Bank',
    short: 'IPPB',
    color: 0xFFC1272D,
    popular: false,
  ),
  Bank(
    id: 'airtel',
    name: 'Airtel Payments Bank',
    short: 'Airtel',
    color: 0xFFE40000,
    popular: false,
  ),
  Bank(
    id: 'fino',
    name: 'Fino Payments Bank',
    short: 'Fino',
    color: 0xFF5A2D82,
    popular: false,
  ),
  Bank(
    id: 'bupb',
    name: 'Baroda UP Bank',
    short: 'BUPB',
    color: 0xFFE2611F,
    popular: false,
  ),
  Bank(
    id: 'aryb',
    name: 'Aryavart Bank',
    short: 'Aryavart',
    color: 0xFF00796B,
    popular: false,
  ),
  Bank(
    id: 'pupgb',
    name: 'Prathama UP Gramin Bank',
    short: 'Prathama',
    color: 0xFF6A1B9A,
    popular: false,
  ),
  Bank(
    id: 'federal',
    name: 'Federal Bank',
    short: 'Federal',
    color: 0xFF1A3F7A,
    popular: false,
  ),
  Bank(
    id: 'indus',
    name: 'IndusInd Bank',
    short: 'IndusInd',
    color: 0xFF8C1D40,
    popular: false,
  ),
  Bank(
    id: 'yes',
    name: 'Yes Bank',
    short: 'Yes',
    color: 0xFF0047AB,
    popular: false,
  ),
];

Bank? bankById(String? id) {
  for (final b in banks) {
    if (b.id == id) return b;
  }
  return null;
}

const ifscBank = {
  'SBIN': 'sbi',
  'HDFC': 'hdfc',
  'PUNB': 'pnb',
  'BARB': 'bob',
  'BKID': 'boi',
  'UBIN': 'ubi',
  'CNRB': 'cnb',
  'CBIN': 'cbi',
  'IDIB': 'ib',
  'ICIC': 'icici',
  'UTIB': 'axis',
  'KKBK': 'kotak',
};

class Retailer {
  static const name = 'Ravi Sharma';
  static const shop = 'Sharma General Store';
  static const id = 'AP100245';
  static const city = 'Aminabad, Lucknow, UP';
  static const mobile = '98•••••521';
  static const role = 'Retailer / Franchisee';
  static const distributor = 'Verma Distribution (AD20031)';
}

class DemoLogin {
  static const id = 'AP100245';
  static const password = 'Demo@123';
  static const otp = '246810';
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
    required this.tx,
    required this.wallet,
    required this.settlements,
    required this.accounts,
    required this.tickets,
  });
  final List<Txn> tx;
  final Wallet wallet;
  final List<Settlement> settlements;
  final List<BankAccount> accounts;
  final List<Ticket> tickets;
}

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

enum SheetKind { bank, receipt, settle, addBank, scenarios }

class SheetModel {
  SheetModel(this.kind);
  final SheetKind kind;
  String q = '';
  String ref = '';
  String amt = '';
  bool tried = false;
  Map<String, String> f = {};
}

AppData seedData() {
  final now = DateTime.now();
  Txn mk({
    required Duration ago,
    required int amt,
    String svc = 'cw',
    required String bank,
    required String aadhaar4,
    required String mobile4,
    required TxStatus status,
    double? bal,
    String? reason,
  }) {
    return Txn(
      t: now.subtract(ago),
      svc: svc,
      amt: amt,
      bank: bank,
      aadhaar4: aadhaar4,
      mobile4: mobile4,
      status: status,
      ref: 'tmp',
      rrn: 'tmp',
      bal: bal,
      reason: reason,
      credited: true,
    );
  }

  final tx = <Txn>[
    mk(
      ago: const Duration(minutes: 36),
      amt: 2000,
      bank: 'pnb',
      aadhaar4: '7712',
      mobile4: '8841',
      status: TxStatus.success,
      bal: 14230.55,
    ),
    mk(
      ago: const Duration(minutes: 84),
      amt: 0,
      svc: 'be',
      bank: 'sbi',
      aadhaar4: '1094',
      mobile4: '2207',
      status: TxStatus.success,
      bal: 3810,
    ),
    mk(
      ago: const Duration(minutes: 132),
      amt: 5000,
      bank: 'bob',
      aadhaar4: '6630',
      mobile4: '5512',
      status: TxStatus.failed,
      reason: 'insufficient',
    ),
    mk(
      ago: const Duration(minutes: 186),
      amt: 1500,
      bank: 'cbi',
      aadhaar4: '2281',
      mobile4: '9930',
      status: TxStatus.pending,
    ),
    mk(
      ago: const Duration(hours: 4),
      amt: 3000,
      bank: 'ubi',
      aadhaar4: '5547',
      mobile4: '1176',
      status: TxStatus.success,
      bal: 22104.10,
    ),
    mk(
      ago: const Duration(days: 1, hours: 2),
      amt: 1000,
      bank: 'sbi',
      aadhaar4: '9018',
      mobile4: '4420',
      status: TxStatus.success,
      bal: 6620,
    ),
    mk(
      ago: const Duration(days: 1, hours: 5),
      amt: 0,
      svc: 'ms',
      bank: 'cnb',
      aadhaar4: '3375',
      mobile4: '6608',
      status: TxStatus.success,
      bal: 11250.40,
    ),
    mk(
      ago: const Duration(days: 1, hours: 7),
      amt: 2500,
      bank: 'ib',
      aadhaar4: '4402',
      mobile4: '7781',
      status: TxStatus.failed,
      reason: 'bio',
    ),
    mk(
      ago: const Duration(days: 2, hours: 3),
      amt: 500,
      bank: 'boi',
      aadhaar4: '8126',
      mobile4: '3349',
      status: TxStatus.success,
      bal: 1890.75,
    ),
    mk(
      ago: const Duration(days: 3, hours: 1),
      amt: 4000,
      bank: 'pnb',
      aadhaar4: '6619',
      mobile4: '2290',
      status: TxStatus.success,
      bal: 30410,
    ),
    mk(
      ago: const Duration(days: 4, hours: 6),
      amt: 2000,
      bank: 'ippb',
      aadhaar4: '7058',
      mobile4: '8014',
      status: TxStatus.success,
      bal: 9055.20,
    ),
    mk(
      ago: const Duration(days: 6, hours: 2),
      amt: 1000,
      bank: 'bupb',
      aadhaar4: '1563',
      mobile4: '5576',
      status: TxStatus.success,
      bal: 4400,
    ),
    mk(
      ago: const Duration(days: 12),
      amt: 3500,
      bank: 'sbi',
      aadhaar4: '2947',
      mobile4: '6631',
      status: TxStatus.success,
      bal: 17880,
    ),
    mk(
      ago: const Duration(days: 19),
      amt: 1000,
      bank: 'aryb',
      aadhaar4: '8833',
      mobile4: '1029',
      status: TxStatus.success,
      bal: 2600,
    ),
  ];
  var seq = 48211;
  final stamped = <Txn>[];
  for (final x in tx) {
    final yy = x.t.year.toString().substring(2);
    final mm = x.t.month.toString().padLeft(2, '0');
    final dd = x.t.day.toString().padLeft(2, '0');
    final ref = 'AP$yy$mm$dd${seq++}';
    final rrn =
        (600000000000 + (x.t.millisecondsSinceEpoch ~/ 1000) % 1000000000)
            .toString()
            .padLeft(12, '6');
    stamped.add(
      Txn(
        t: x.t,
        svc: x.svc,
        amt: x.amt,
        bank: x.bank,
        aadhaar4: x.aadhaar4,
        mobile4: x.mobile4,
        status: x.status,
        ref: ref,
        rrn: rrn,
        reason: x.reason,
        bal: x.bal,
        earn: x.status == TxStatus.success && x.svc == 'cw' ? 5 : 0,
        credited: true,
      ),
    );
  }
  stamped.sort((a, b) => b.t.compareTo(a.t));
  final pending = stamped
      .where((x) => x.status == TxStatus.pending)
      .firstOrNull;
  return AppData(
    tx: stamped,
    wallet: Wallet(main: 18450, aeps: 6500, earn: 412.50),
    settlements: [
      Settlement(
        id: 'ST-10432',
        t: now.subtract(const Duration(hours: 22)),
        amt: 12000,
        acct: 'sbi',
        status: 'settled',
        utr: 'SBIN226110987',
      ),
      Settlement(
        id: 'ST-10419',
        t: now.subtract(const Duration(days: 2)),
        amt: 8500,
        acct: 'sbi',
        status: 'settled',
        utr: 'SBIN226108874',
      ),
      Settlement(
        id: 'ST-10441',
        t: now.subtract(const Duration(hours: 2)),
        amt: 4000,
        acct: 'sbi',
        status: 'processing',
      ),
      Settlement(
        id: 'ST-10398',
        t: now.subtract(const Duration(days: 5)),
        amt: 3000,
        acct: 'cnb',
        status: 'reversed',
        note: 'Account details rejected by bank. Amount returned to AEPS balance.',
      ),
    ],
    accounts: [
      BankAccount(
        id: 'a1',
        bank: 'sbi',
        last4: '4521',
        holder: 'RAVI SHARMA',
        ifsc: 'SBIN0001876',
        status: 'active',
        primary: true,
      ),
      BankAccount(
        id: 'a2',
        bank: 'hdfc',
        last4: '0912',
        holder: 'SHARMA GENERAL STORE',
        ifsc: 'HDFC0002231',
        status: 'pending',
      ),
      BankAccount(
        id: 'a3',
        bank: 'cnb',
        last4: '7781',
        holder: 'R SHARMA',
        ifsc: 'CNRB0004410',
        status: 'rejected',
        note: 'Name on account does not match KYC name.',
      ),
    ],
    tickets: [
      Ticket(
        id: 'SR-20871',
        t: now.subtract(const Duration(days: 2)),
        type: 'Pending transaction',
        ref: pending?.ref,
        status: 'In review',
        msg: 'Customer says cash not received, status pending.',
      ),
    ],
  );
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

const reasons = <String, ReasonCopy>{
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

const faqs = <String, List<(String, String)>>{
  'en': [
    (
      'The transaction is pending. What should I do?',
      "Don't give cash and don't start another withdrawal for the same customer. Open the transaction and tap Check status. Most pending transactions resolve within a few minutes. If it still shows pending after 30 minutes, raise a support request from the transaction.",
    ),
    (
      'Money was debited from the customer but the transaction failed',
      'Failed transactions are usually reversed to the customer\'s account automatically by their bank. Share the reference number with the customer and raise a support request so we can track it.',
    ),
    (
      'Fingerprint keeps failing',
      'Clean the scanner glass and the customer\'s finger. Ask them to press flat without moving. Try a different finger. If the device shows an error, open Device → Troubleshooting.',
    ),
    (
      'When does my AEPS balance reach my bank?',
      'Settlement timing depends on the partner bank and is not confirmed yet. You can see every settlement and its status in Wallet → Settlements.',
    ),
  ],
  'hi': [
    (
      'लेन-देन पेंडिंग है। क्या करूँ?',
      'नकद न दें और उसी ग्राहक के लिए दूसरी निकासी शुरू न करें। लेन-देन खोलें और स्थिति जाँचें दबाएँ। ज़्यादातर पेंडिंग लेन-देन कुछ मिनटों में पूरे हो जाते हैं। 30 मिनट बाद भी पेंडिंग हो तो लेन-देन से सहायता अनुरोध करें।',
    ),
    (
      'ग्राहक के खाते से पैसा कटा पर लेन-देन असफल हुआ',
      'असफल लेन-देन में पैसा आमतौर पर बैंक अपने-आप लौटा देता है। ग्राहक को रेफ़रेंस नंबर दें और सहायता अनुरोध करें ताकि हम ट्रैक कर सकें।',
    ),
    (
      'फ़िंगरप्रिंट बार-बार असफल हो रहा है',
      'स्कैनर का शीशा और ग्राहक की उंगली साफ़ करें। सीधा दबाकर स्थिर रखने को कहें। दूसरी उंगली आज़माएँ। डिवाइस पर एरर दिखे तो डिवाइस → समस्या समाधान खोलें।',
    ),
    (
      'मेरा AEPS बैलेंस बैंक में कब आएगा?',
      'सेटलमेंट का समय पार्टनर बैंक पर निर्भर है और अभी तय नहीं है। हर सेटलमेंट और उसकी स्थिति वॉलेट → सेटलमेंट में देखें।',
    ),
  ],
};

const issues = <String, List<String>>{
  'en': [
    'Cash not given / customer dispute',
    'Customer debited but transaction failed',
    'Pending transaction',
    'Receipt or SMS issue',
    'Device issue',
    'Other',
  ],
  'hi': [
    'नकद नहीं दिया / ग्राहक विवाद',
    'पैसा कटा पर लेन-देन असफल',
    'पेंडिंग लेन-देन',
    'रसीद या SMS की समस्या',
    'डिवाइस की समस्या',
    'अन्य',
  ],
};

List<(String, String)> futureServices(String lang) => lang == 'hi'
    ? const [
        ('atm', 'माइक्रो एटीएम'),
        ('send', 'मनी ट्रांसफ़र'),
        ('bill', 'बिल भुगतान'),
        ('recharge', 'रिचार्ज'),
        ('pan', 'PAN सेवा'),
        ('shield', 'बीमा'),
        ('cash', 'कैश कलेक्शन'),
        ('topup', 'वॉलेट टॉप-अप'),
      ]
    : const [
        ('atm', 'Micro ATM'),
        ('send', 'Money transfer'),
        ('bill', 'Bill payments'),
        ('recharge', 'Recharge'),
        ('pan', 'PAN services'),
        ('shield', 'Insurance'),
        ('cash', 'Cash collection'),
        ('topup', 'Wallet top-up'),
      ];

List<(String, int)> miniStatement(DateTime t) {
  String d(int days) =>
      fmtDt(t.subtract(Duration(days: days)), 'en').split(',').first;
  return [
    (d(1), -340),
    (d(2), 8200),
    (d(3), -2000),
    (d(5), 2000),
    (d(6), -1000),
  ];
}

const miniLabels = [
  'UPI/ Kirana',
  'NEFT CR Salary',
  'ATM WDL',
  'PM-KISAN CR',
  'AEPS WDL',
];

double demoBalance() => (2500 + Random().nextDouble() * 24000);

String newRef(DateTime now, int count) {
  final yy = now.year.toString().substring(2);
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  return 'AP$yy$mm$dd${48300 + count}';
}

String newRrn() =>
    (600000000000 + (Random().nextDouble() * 299000000000).floor()).toString();
