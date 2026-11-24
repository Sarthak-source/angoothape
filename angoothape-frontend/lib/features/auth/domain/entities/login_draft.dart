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
