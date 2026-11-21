/// Shared layout rules for phone, tablet, and desktop web.
///
/// Breakpoints match the prototype:
/// mobile < 700, tablet 700–1023, desktop ≥ 1024.
enum ViewportClass { mobile, tablet, desktop }

enum BankPickerPresentation { sheet, dialog }

enum HistoryPresentation { dayCards, table }

enum ReceiptPresentation { shareAndPrint, downloadAndPrint }

enum SummaryPlacement { fingerprintStage, liveSidePanel }

class LayoutProfile {
  const LayoutProfile({required this.width, required this.viewport});

  final double width;
  final ViewportClass viewport;

  bool get isMobile => viewport == ViewportClass.mobile;
  bool get isTablet => viewport == ViewportClass.tablet;
  bool get isDesktop => viewport == ViewportClass.desktop;

  /// Desktop sidebar and tablet compact rail. Mobile uses the bottom bar.
  bool get showSidebar => !isMobile;

  /// Desktop shows full labels in a wide sidebar. Tablet keeps a narrow rail with labels.
  bool get sidebarExpanded => isDesktop;

  /// Header with wallet balances, device status, and Help.
  bool get showHeader => showSidebar;

  bool get showBottomNav => isMobile;

  /// Primary action stays above the keyboard.
  bool get stickyPrimary => isMobile;

  /// Numeric keyboards for mobile, Aadhaar, and amount.
  bool get numericKeyboards => isMobile;

  /// Enter submits the AEPS details form.
  bool get enterSubmits => isDesktop;

  /// Arrow keys move the bank list; Enter selects.
  bool get arrowKeyBankPicker => isDesktop;

  BankPickerPresentation get bankPicker =>
      isDesktop ? BankPickerPresentation.dialog : BankPickerPresentation.sheet;

  HistoryPresentation get history =>
      isDesktop ? HistoryPresentation.table : HistoryPresentation.dayCards;

  ReceiptPresentation get receipt => isMobile
      ? ReceiptPresentation.shareAndPrint
      : ReceiptPresentation.downloadAndPrint;

  /// Desktop keeps a live summary beside the form. Tablet and mobile show it on the fingerprint step.
  SummaryPlacement get aepsSummary => isDesktop
      ? SummaryPlacement.liveSidePanel
      : SummaryPlacement.fingerprintStage;

  bool get twoColumnForms => !isMobile;

  /// Mobile reaches device, help, and profile through More.
  bool get nestUnderMore => isMobile;
}

class LayoutService {
  const LayoutService();

  static const mobileBelow = 700.0;
  static const desktopFrom = 1024.0;

  LayoutProfile resolve(double width) {
    final viewport = width < mobileBelow
        ? ViewportClass.mobile
        : width < desktopFrom
        ? ViewportClass.tablet
        : ViewportClass.desktop;
    return LayoutProfile(width: width, viewport: viewport);
  }
}
