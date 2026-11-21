import 'dart:math';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _monthsHi = [
  'जन',
  'फ़र',
  'मार्च',
  'अप्रै',
  'मई',
  'जून',
  'जुल',
  'अग',
  'सित',
  'अक्टू',
  'नव',
  'दिस',
];
const _week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekHi = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];

/// Indian digit grouping, e.g. 18450.5 → 18,450.50
String groupIn(num n, {int dec = 2}) {
  final neg = n < 0;
  final fixed = n.abs().toStringAsFixed(dec);
  final parts = fixed.split('.');
  final digits = parts[0];
  String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final chunks = <String>[];
    while (rest.length > 2) {
      chunks.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) chunks.insert(0, rest);
    grouped = '${chunks.join(',')},$last3';
  }
  final frac = dec > 0 ? '.${parts[1]}' : '';
  return '${neg ? '-' : ''}$grouped$frac';
}

String inr(num n, {int dec = 2}) => '₹${groupIn(n, dec: dec)}';

String fmtDt(DateTime ts, String lang) {
  final d = ts.toLocal();
  final mon = (lang == 'hi' ? _monthsHi : _months)[d.month - 1];
  final h24 = d.hour;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final ap = h24 < 12 ? 'am' : 'pm';
  final min = d.minute.toString().padLeft(2, '0');
  return '${d.day} $mon ${d.year}, $h:$min $ap';
}

String fmtT(DateTime ts) {
  final d = ts.toLocal();
  final h24 = d.hour;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final ap = h24 < 12 ? 'am' : 'pm';
  final min = d.minute.toString().padLeft(2, '0');
  return '$h:$min $ap';
}

String dayLabel(DateTime ts, String lang, String today, String yesterday) {
  final d = DateTime(ts.year, ts.month, ts.day);
  final n = DateTime.now();
  final today0 = DateTime(n.year, n.month, n.day);
  final diff = today0.difference(d).inDays;
  if (diff == 0) return today;
  if (diff == 1) return yesterday;
  final w = (lang == 'hi' ? _weekHi : _week)[ts.weekday - 1];
  final mon = (lang == 'hi' ? _monthsHi : _months)[ts.month - 1];
  return '$w, ${ts.day} $mon';
}

String maskAadhaar(String last4) => 'XXXX XXXX $last4';
String maskMobile(String last4) => '+91 ••••••$last4';

const _vd = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];
const _vp = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];
const _vinv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

bool verhoeffOk(String n) {
  var c = 0;
  final digits = n.split('').map(int.parse).toList().reversed.toList();
  for (var i = 0; i < digits.length; i++) {
    c = _vd[c][_vp[i % 8][digits[i]]];
  }
  return c == 0;
}

int verhoeffDigit(String n) {
  var c = 0;
  final digits = n.split('').map(int.parse).toList().reversed.toList();
  for (var i = 0; i < digits.length; i++) {
    c = _vd[c][_vp[(i + 1) % 8][digits[i]]];
  }
  return _vinv[c];
}

String sampleAadhaar([Random? random]) {
  final r = random ?? Random();
  final buf = StringBuffer('${2 + r.nextInt(8)}');
  for (var i = 0; i < 10; i++) {
    buf.write(r.nextInt(10));
  }
  final body = buf.toString();
  return body + verhoeffDigit(body).toString();
}

final _mobileRe = RegExp(r'^[6-9]\d{9}$');
final _aadhaarRe = RegExp(r'^[2-9]\d{11}$');
final _vidRe = RegExp(r'^\d{16}$');
final _panRe = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');
final _pinRe = RegExp(r'^[1-9]\d{5}$');
final _ifscRe = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
final _acctRe = RegExp(r'^\d{9,18}$');

bool validMobile(String v) => _mobileRe.hasMatch(v);
bool validPan(String v) => _panRe.hasMatch(v);
bool validPin(String v) => _pinRe.hasMatch(v);
bool validIfsc(String v) => _ifscRe.hasMatch(v);
bool validAccount(String v) => _acctRe.hasMatch(v);
bool validVid(String v) => _vidRe.hasMatch(v);
bool looksLikeAadhaar(String v) => _aadhaarRe.hasMatch(v);
