import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/session_mapper.dart';
import '../../../../core/di.dart';
import '../../../../core/enums.dart';
import '../../../../core/l10n/strings.dart';
import '../../../../core/responsive/layout_service.dart';
import '../../../aeps/data/datasources/aeps_api.dart';
import '../../../aeps/domain/usecases/capture_fingerprint_usecase.dart';
import '../../../aeps/presentation/controllers/aeps_controller.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../onboarding/domain/repositories/join_repository.dart';
import '../../../onboarding/presentation/controllers/join_controller.dart';
import '../../../support/domain/repositories/support_repository.dart';
import '../../../support/presentation/controllers/support_controller.dart';
import '../../domain/entities/app_session.dart';
import '../../domain/entities/session_entities.dart';
import '../../domain/repositories/session_repository.dart';

class ToastMsg {
  ToastMsg(this.text, this.sim);
  final String text;
  final bool sim;
}

class AppController extends Notifier<AppSession>
    with
        JoinController,
        HomeController,
        AuthController,
        AepsController,
        SupportController {
  @override
  late AuthRepository authRepository;
  @override
  late SessionRepository sessionRepository;
  @override
  late SupportRepository supportRepository;
  @override
  late AepsApi aepsApi;
  @override
  late CaptureFingerprintUseCase captureFingerprintUseCase;
  @override
  late JoinRepository joinRepository;
  @override
  late HomeRepository homeRepository;

  bool _started = false;

  @override
  AppSession build() {
    authRepository = ref.watch(authRepositoryProvider);
    sessionRepository = ref.watch(sessionRepositoryProvider);
    supportRepository = ref.watch(supportRepositoryProvider);
    aepsApi = ref.watch(aepsApiProvider);
    captureFingerprintUseCase = ref.watch(captureFingerprintUseCaseProvider);
    joinRepository = ref.watch(joinRepositoryProvider);
    homeRepository = ref.watch(homeRepositoryProvider);
    if (!_started) {
      _started = true;
      ref.onDispose(_toasts.close);
      unawaited(_boot());
    }
    return snapshot();
  }

  AppSession snapshot() => AppSession(
    lang: lang,
    authed: authed,
    booting: booting,
    dark: dark,
    scale: scale,
    route: route,
    params: params,
    layout: layout,
    inflight: inflight,
    data: data,
    join: join,
    aeps: aeps,
    login: login,
    hist: hist,
    sheet: sheet,
    scenario: scenario,
    checking: checking,
    helpTab: helpTab,
    newReq: newReq,
    devTab: devTab,
    devTest: devTest,
  );

  @override
  void emit() => state = snapshot();

  @override
  String lang = 'en';
  @override
  bool authed = false;
  bool booting = true;
  bool dark = false;
  double scale = 1;
  @override
  String route = 'welcome';
  Map<String, String> params = {};
  LayoutProfile layout = const LayoutService().resolve(400);
  @override
  bool inflight = false;

  @override
  final scenario = Scenario();
  @override
  AppData data = emptyAppData();
  @override
  JoinDraft join = JoinDraft();
  @override
  final hist = HistFilter();
  @override
  SheetModel? sheet;
  @override
  final Map<String, bool> checking = {};
  final _toasts = StreamController<ToastMsg>.broadcast();
  Stream<ToastMsg> get toasts => _toasts.stream;

  Future<void> _boot() async {
    await sessionRepository.restore();
    try {
      applyCatalogJson(await sessionRepository.catalog());
    } catch (_) {}
    if (sessionRepository.signedIn) {
      try {
        await refreshSession();
        authed = true;
        route = 'dash';
      } catch (_) {
        await sessionRepository.clearTokens();
      }
    }
    booting = false;
    emit();
  }

  bool get hi => lang == 'hi';
  bool get isMobile => layout.isMobile;
  @override
  String t(String key) => tr(lang, key);
  @override
  String both(String en, String hindi) => hi ? hindi : en;

  /// Updates navigation parents when the viewport class changes.
  /// Width itself is published by [LayoutScope] during build.
  void bindLayout(LayoutProfile next) {
    if (next.viewport == layout.viewport) return;
    layout = next;
    emit();
  }

  @override
  void toast(String msg, {bool sim = false}) {
    _toasts.add(ToastMsg(msg, sim));
  }

  @override
  void go(String next, {Map<String, String>? params}) {
    if (inflight && next != route) {
      toast(t('in_progress'));
      return;
    }
    if (next == 'hist') hist.loading = true;
    route = next;
    this.params = params ?? {};
    sheet = null;
    emit();
    if (next == 'hist') unawaited(loadHistory());
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
      case 'mfa':
        return 'login';
      case 'otp':
        return 'mfa';
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
      emit();
      return;
    }
    if (route == 'aeps' &&
        (aeps.step == AepsStep.result || aeps.step == AepsStep.processing)) {
      return;
    }
    if (route == 'join' && joinStepBack()) return;
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
    emit();
    unawaited(_savePrefs());
  }

  void toggleLang() => setLang(lang == 'en' ? 'hi' : 'en');

  void toggleDark() {
    dark = !dark;
    emit();
    unawaited(_savePrefs());
  }

  void setScale(double value) {
    scale = value;
    emit();
    unawaited(_savePrefs());
  }

  Future<void> _savePrefs() async {
    if (!authed) return;
    try {
      await sessionRepository.savePreferences(
        lang: lang,
        dark: dark,
        scale: scale,
      );
    } catch (_) {}
  }

  @override
  Future<void> refreshSession() async {
    final res = await sessionRepository.me();
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

  @override
  void applyWallet(Map<String, dynamic>? json) {
    if (json == null) return;
    data.wallet.main = (json['main'] as num?)?.toDouble() ?? data.wallet.main;
    data.wallet.aeps = (json['aeps'] as num?)?.toDouble() ?? data.wallet.aeps;
    data.wallet.earn = (json['earn'] as num?)?.toDouble() ?? data.wallet.earn;
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {}
    await sessionRepository.clearTokens();
    authed = false;
    login
      ..id = ''
      ..pw = ''
      ..showPw = false
      ..err = ''
      ..otp = ''
      ..otpErr = ''
      ..demoOtp = null
      ..demoTotp = null
      ..challengeId = null
      ..qrDataUrl = null
      ..emailMasked = null
      ..enroll = false
      ..totp = ''
      ..busy = false;
    aeps = AepsDraft();
    data = emptyAppData();
    go('welcome');
  }

  Future<void> resetDemo() async {
    try {
      if (authed) await sessionRepository.resetDemo();
    } catch (_) {}
    await sessionRepository.clearTokens();
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
    emit();
    toast(both('Demo reset', 'डेमो रीसेट हो गया'));
  }

  void closeSheet() {
    sheet = null;
    emit();
  }
}
