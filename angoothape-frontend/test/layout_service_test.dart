import 'package:angoothape/core/enums.dart';
import 'package:angoothape/core/responsive/layout_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = LayoutService();

  test('phone layout uses the bottom bar, sheet, and day cards', () {
    final p = service.resolve(699);
    expect(p.viewport, ViewportClass.mobile);
    expect(p.showBottomNav, isTrue);
    expect(p.stickyPrimary, isTrue);
    expect(p.numericKeyboards, isTrue);
    expect(p.bankPicker, BankPickerPresentation.sheet);
    expect(p.history, HistoryPresentation.dayCards);
    expect(p.receipt, ReceiptPresentation.shareAndPrint);
    expect(p.aepsSummary, SummaryPlacement.fingerprintStage);
    expect(p.nestUnderMore, isTrue);
  });

  test('tablet layout uses a labeled rail and two-column forms', () {
    final narrow = service.resolve(700);
    final wide = service.resolve(1023);
    for (final p in [narrow, wide]) {
      expect(p.viewport, ViewportClass.tablet);
      expect(p.showSidebar, isTrue);
      expect(p.sidebarExpanded, isFalse);
      expect(p.showHeader, isTrue);
      expect(p.twoColumnForms, isTrue);
      expect(p.aepsSummary, SummaryPlacement.fingerprintStage);
      expect(p.receipt, ReceiptPresentation.downloadAndPrint);
      expect(p.history, HistoryPresentation.dayCards);
    }
  });

  test('desktop layout uses the sidebar, live summary, dialog, and table', () {
    final p = service.resolve(1024);
    expect(p.viewport, ViewportClass.desktop);
    expect(p.sidebarExpanded, isTrue);
    expect(p.showHeader, isTrue);
    expect(p.enterSubmits, isTrue);
    expect(p.arrowKeyBankPicker, isTrue);
    expect(p.bankPicker, BankPickerPresentation.dialog);
    expect(p.history, HistoryPresentation.table);
    expect(p.aepsSummary, SummaryPlacement.liveSidePanel);
    expect(p.receipt, ReceiptPresentation.downloadAndPrint);
  });
}
