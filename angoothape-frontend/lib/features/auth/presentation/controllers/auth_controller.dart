import '../../../../core/api/api_exception.dart';
import '../../domain/entities/login_draft.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../session/domain/repositories/session_repository.dart';

mixin AuthController {
  AuthRepository get authRepository;
  SessionRepository get sessionRepository;
  final login = LoginDraft();

  bool get authed;
  set authed(bool value);

  void emit();
  Future<void> refreshSession();
  void go(String next, {Map<String, String>? params});
  void toast(String msg, {bool sim = false});
  String both(String en, String hindi);

  Future<void> submitLogin(String id, String pw) async {
    login.id = id;
    login.pw = pw;
    login.err = '';
    login.busy = true;
    emit();
    try {
      final res = await authRepository.login(
        partnerId: id.trim().toUpperCase(),
        password: pw,
      );
      login.busy = false;
      login.otp = '';
      login.totp = '';
      login.otpErr = '';
      _applyMfaChallenge(res);
      login.resendAt = DateTime.now().add(const Duration(seconds: 30));
      go('mfa');
    } on ApiException catch (e) {
      login.busy = false;
      login.err = e.message;
      emit();
    }
  }

  void togglePw() {
    login.showPw = !login.showPw;
    emit();
  }

  void _applyMfaChallenge(Map<String, dynamic> res) {
    final mfa = Map<String, dynamic>.from(res['mfa'] as Map? ?? {});
    login.demoOtp = res['otp'] as String? ?? login.demoOtp;
    login.demoTotp = res['totp'] as String? ?? login.demoTotp;
    login.challengeId =
        mfa['challengeId'] as String? ?? res['challengeId'] as String?;
    login.qrDataUrl = mfa['qrDataUrl'] as String?;
    login.emailMasked = mfa['emailMasked'] as String?;
    login.enroll = mfa['enroll'] as bool? ?? login.qrDataUrl != null;
  }

  Future<void> _finishAuth(Map<String, dynamic> res) async {
    final token = res['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException(401, 'mfa_incomplete', 'Verification incomplete');
    }
    await sessionRepository.persistTokens(
      token,
      mfaToken: res['mfaToken'] as String?,
    );
    await refreshSession();
    login.busy = false;
    authed = true;
    go('dash');
  }

  Future<void> submitTotp(String totp) async {
    login.totp = totp;
    login.otpErr = '';
    login.busy = true;
    emit();
    try {
      final res = await authRepository.verifyTotp(
        partnerId: login.id.trim().toUpperCase(),
        totp: totp,
        challengeId: login.challengeId,
      );
      if (res['token'] is String) {
        await _finishAuth(res);
        return;
      }
      login.busy = false;
      _applyMfaChallenge(res);
      go('otp');
    } on ApiException catch (e) {
      login.busy = false;
      login.otpErr = e.message;
      emit();
    }
  }

  Future<void> submitOtp(String code) async {
    login.otp = code;
    login.otpErr = '';
    login.busy = true;
    emit();
    try {
      final res = await authRepository.verifyOtp(
        partnerId: login.id.trim().toUpperCase(),
        otp: code,
        challengeId: login.challengeId,
      );
      await _finishAuth(res);
    } on ApiException catch (e) {
      login.busy = false;
      login.otpErr = e.message;
      emit();
    }
  }

  Future<void> resendOtp() async {
    login.resendAt = DateTime.now().add(const Duration(seconds: 30));
    try {
      final res = await authRepository.resendOtp(
        partnerId: login.id.trim().toUpperCase(),
      );
      _applyMfaChallenge(res);
      toast(both('New code sent to email', 'ईमेल पर नया कोड भेजा गया'));
    } on ApiException catch (e) {
      toast(e.message);
    }
    emit();
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
    emit();
    try {
      final res = await authRepository.forgot(
        partnerId: id.trim().toUpperCase(),
      );
      login.busy = false;
      login.demoOtp = res['otp'] as String?;
      login.resendAt = DateTime.now().add(const Duration(seconds: 30));
      go('forgot-otp');
    } on ApiException catch (e) {
      login.busy = false;
      login.err = e.message;
      emit();
    }
  }

  Future<void> confirmForgot(String otp, String password) async {
    login.otp = otp;
    login.otpErr = '';
    login.busy = true;
    emit();
    try {
      await authRepository.confirmForgot(
        partnerId: login.id.trim().toUpperCase(),
        otp: otp,
        password: password,
      );
      login.busy = false;
      toast(
        both('Password reset. Sign in.', 'पासवर्ड रीसेट हो गया। लॉग इन करें।'),
      );
      go('login');
    } on ApiException catch (e) {
      login.busy = false;
      login.otpErr = e.message;
      emit();
    }
  }
}
