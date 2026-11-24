import 'package:flutter/material.dart';

import '../../features/aeps/presentation/ui/widgets/bank_sheet.dart';
import '../../features/aeps/presentation/ui/widgets/scenario_sheet.dart';
import '../../features/home/presentation/ui/widgets/add_bank_sheet.dart';
import '../../features/home/presentation/ui/widgets/receipt_sheet.dart';
import '../../features/home/presentation/ui/widgets/settle_sheet.dart';
import '../../features/home/presentation/ui/widgets/topup_sheet.dart';
import '../../features/support/presentation/ui/widgets/password_sheet.dart';
import '../../features/support/presentation/ui/widgets/profile_sheet.dart';
import '../enums.dart';
import '../responsive/layout_scope.dart';
import '../theme/palette.dart';
import 'app_widgets.dart';

class AppSheet extends StatelessWidget {
  const AppSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sheet = AppScope.of(context).sheet;
    if (sheet == null) return const SizedBox.shrink();
    return _SheetLayer(key: ValueKey(sheet.kind), kind: sheet.kind);
  }
}

/// Overlay chrome from the HTML prototype: dim scrim, grab handle on
/// phones, 34px top corners, centred dialog from 700px with a zoom-in.
class _SheetLayer extends StatefulWidget {
  const _SheetLayer({super.key, required this.kind});
  final SheetKind kind;

  @override
  State<_SheetLayer> createState() => _SheetLayerState();
}

class _SheetLayerState extends State<_SheetLayer>
    with SingleTickerProviderStateMixin {
  static const _ease = Cubic(0.2, 0.7, 0.2, 1);
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();
  late final Animation<double> _t = CurvedAnimation(
    parent: _anim,
    curve: _ease,
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final mobile = LayoutScope.of(context).isMobile;
    final h = MediaQuery.sizeOf(context).height;
    final safe = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final radius = mobile
        ? const BorderRadius.vertical(top: Radius.circular(34))
        : BorderRadius.circular(30);
    final child = switch (widget.kind) {
      SheetKind.bank => const BankSheet(),
      SheetKind.receipt => const ReceiptSheet(),
      SheetKind.settle => const SettleSheet(),
      SheetKind.addBank => const AddBankSheet(),
      SheetKind.scenarios => const ScenarioSheet(),
      SheetKind.profile => const ProfileSheet(),
      SheetKind.password => const PasswordSheet(),
      SheetKind.topup => const TopupSheet(),
    };
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          return GestureDetector(
            onTap: c.closeSheet,
            child: ColoredBox(
              color: Color.fromRGBO(18, 16, 46, 0.45 * t),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboard),
                child: Align(
                  alignment: mobile ? Alignment.bottomCenter : Alignment.center,
                  child: GestureDetector(
                    onTap: () {},
                    child: Transform.translate(
                      offset: mobile ? Offset(0, 40 * (1 - t)) : Offset.zero,
                      child: Transform.scale(
                        scale: mobile ? 1 : 0.97 + 0.03 * t,
                        child: Opacity(
                          opacity: mobile ? 0.4 + 0.6 * t : t,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: h * (mobile ? 0.88 : 0.80),
                              maxWidth: mobile ? double.infinity : 560,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.card,
                                borderRadius: radius,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2912102E),
                                    blurRadius: 32,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: radius,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: safe),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (mobile)
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.lineStrong,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      Flexible(
                                        child: ApIdleOutline(child: child),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
