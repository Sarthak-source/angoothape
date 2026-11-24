class LoginDraft {
  String id = '';
  String pw = '';
  bool showPw = false;
  String err = '';
  String otp = '';
  String totp = '';
  String otpErr = '';
  String? demoOtp;
  String? demoTotp;
  String? challengeId;
  String? qrDataUrl;
  String? emailMasked;
  bool enroll = false;
  DateTime resendAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool busy = false;
}
