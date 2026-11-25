import '../../../../core/responsive/layout_service.dart';
import '../../../aeps/domain/entities/aeps_draft.dart';
import '../../../aeps/domain/entities/scenario.dart';
import '../../../auth/domain/entities/login_draft.dart';
import '../../../home/domain/entities/txn.dart';
import '../../../onboarding/domain/entities/join_draft.dart';
import '../../../support/domain/entities/new_req.dart';
import 'app_data.dart';
import 'sheet_model.dart';

/// Snapshot of the running app. A new instance is published on every emit
/// so Riverpod listeners rebuild even when nested drafts are mutated in place.
class AppSession {
  const AppSession({
    required this.lang,
    required this.authed,
    required this.booting,
    required this.dark,
    required this.scale,
    required this.route,
    required this.params,
    required this.layout,
    required this.inflight,
    required this.data,
    required this.join,
    required this.aeps,
    required this.login,
    required this.hist,
    required this.sheet,
    required this.scenario,
    required this.checking,
    required this.helpTab,
    required this.newReq,
    required this.devTab,
    required this.devTest,
  });

  factory AppSession.initial() => AppSession(
    lang: 'en',
    authed: false,
    booting: true,
    dark: false,
    scale: 1,
    route: 'welcome',
    params: const {},
    layout: const LayoutService().resolve(400),
    inflight: false,
    data: emptyAppData(),
    join: JoinDraft(),
    aeps: AepsDraft(),
    login: LoginDraft(),
    hist: HistFilter(),
    sheet: null,
    scenario: Scenario(),
    checking: {},
    helpTab: 'faq',
    newReq: NewReq(),
    devTab: 'android',
    devTest: 'idle',
  );

  final String lang;
  final bool authed;
  final bool booting;
  final bool dark;
  final double scale;
  final String route;
  final Map<String, String> params;
  final LayoutProfile layout;
  final bool inflight;
  final AppData data;
  final JoinDraft join;
  final AepsDraft aeps;
  final LoginDraft login;
  final HistFilter hist;
  final SheetModel? sheet;
  final Scenario scenario;
  final Map<String, bool> checking;
  final String helpTab;
  final NewReq newReq;
  final String devTab;
  final String devTest;

  bool get hi => lang == 'hi';
  bool get isMobile => layout.isMobile;
}
