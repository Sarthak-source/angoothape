enum ApButtonKind { primary, accent, outline, soft, ghost }

enum NoticeTone { info, warn, err, ok }

enum PadState { neutral, place, capturing, good, bad }

enum TxStatus { success, failed, pending }

enum AepsStep { details, auth, processing, result }

enum CapturePhase { idle, capturing, ok, failed, locked }

enum DeviceState { ready, disconnected, permission }

enum OutcomeKind { success, failed, pending, network }

enum SheetKind {
  bank,
  receipt,
  settle,
  addBank,
  scenarios,
  profile,
  password,
  topup,
}

enum ViewportClass { mobile, tablet, desktop }

enum BankPickerPresentation { sheet, dialog }

enum HistoryPresentation { dayCards, table }

enum ReceiptPresentation { shareAndPrint, downloadAndPrint }

enum SummaryPlacement { fingerprintStage, liveSidePanel }
