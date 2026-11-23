import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/session/domain/entities/session_entities.dart';
import '../../features/session/presentation/controllers/app_controller.dart';
import '../theme/palette.dart';
import '../utils/format.dart';
import 'top_snack_bar.dart';
import '../theme/ap_icons.dart';

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36, this.onDark = false});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: SvgPicture.asset(
        'assets/brand/logo_mark.svg',
        width: size,
        height: size,
        semanticsLabel: 'angoothaPe',
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.height = 28, this.onDark = false});

  /// Height of the visible mark; the SVG carries built-in margins around it.
  final double height;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final dark = onDark || Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      dark
          ? 'assets/brand/logo_horizontal_dark.svg'
          : 'assets/brand/logo_horizontal.svg',
      height: height * 1.6,
      semanticsLabel: 'angoothaPe',
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText(
    this.value, {
    super.key,
    this.size = 22,
    this.dec = 2,
    this.color,
    this.weight = FontWeight.w700,
  });
  final num value;
  final double size;
  final int dec;
  final Color? color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final c = color ?? ap(context).ink;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '₹',
            style: display(
              size * 0.55,
              weight: FontWeight.w500,
              color: c.withValues(alpha: 0.75),
            ),
          ),
          TextSpan(
            text: groupIn(value, dec: dec),
            style: display(size, weight: weight, color: c, letterSpacing: -0.8),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final TxStatus status;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final c = AppScope.of(context);
    late Color bg;
    late Color fg;
    late IconData icon;
    late String label;
    switch (status) {
      case TxStatus.success:
        bg = p.successBg;
        fg = p.success;
        icon = ApIcons.check;
        label = c.t('s_success');
      case TxStatus.failed:
        bg = p.errorBg;
        fg = p.error;
        icon = ApIcons.close;
        label = c.t('s_failed');
      case TxStatus.pending:
        bg = p.warningBg;
        fg = p.warning;
        icon = ApIcons.clock;
        label = c.t('s_pending');
    }
    return ApBadge(label: label, icon: icon, bg: bg, fg: fg);
  }
}

class ApBadge extends StatelessWidget {
  const ApBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
    this.small = false,
  });
  final String label;
  final IconData? icon;
  final Color bg;
  final Color fg;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
    height: small ? 20 : 28,
    padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: body(small ? 10.5 : 12, weight: FontWeight.w600, color: fg),
        ),
      ],
    ),
  );
}

class AssumeTag extends StatelessWidget {
  const AssumeTag({super.key, this.label});
  final String? label;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.warningBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label ?? AppScope.of(context).t('assumption'),
        style: body(10.5, weight: FontWeight.w700, color: p.warning),
      ),
    );
  }
}

class SoonTag extends StatelessWidget {
  const SoonTag({super.key});
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppScope.of(context).t('soon'),
        style: body(10.5, weight: FontWeight.w600, color: p.ink2),
      ),
    );
  }
}

class DevicePill extends StatelessWidget {
  const DevicePill({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final p = ap(context);
    final d = c.scenario.device;
    late Color bg;
    late Color fg;
    late String label;
    switch (d) {
      case DeviceState.ready:
        bg = p.successBg;
        fg = p.success;
        label = compact
            ? c.both('Device ready', 'डिवाइस तैयार')
            : c.t('dev_ready');
      case DeviceState.disconnected:
        bg = p.warningBg;
        fg = p.warning;
        label = c.t('dev_off');
      case DeviceState.permission:
        bg = p.errorBg;
        fg = p.error;
        label = c.t('dev_perm');
    }
    if (d != DeviceState.ready) label = '$label · ${c.t('fix')}';
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () => c.nav('device'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: body(13, weight: FontWeight.w600, color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApButton extends StatelessWidget {
  const ApButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ApButtonKind.primary,
    this.icon,
    this.busy = false,
    this.expand = false,
    this.small = false,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ApButtonKind kind;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool busy;
  final bool expand;

  /// Compact 40px pill used in headers and section titles.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final enabled = onPressed != null && !busy;
    final accent = kind == ApButtonKind.accent && !small;
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;
    List<BoxShadow>? shadow;
    switch (kind) {
      case ApButtonKind.primary:
        bg = enabled ? p.primary : p.surface2;
        fg = enabled ? p.onPrimary : p.inkDis;
        shadow = enabled
            ? const [
                BoxShadow(
                  color: Color(0xB3302D70),
                  blurRadius: 26,
                  spreadRadius: -12,
                  offset: Offset(0, 12),
                ),
              ]
            : null;
      case ApButtonKind.accent:
        bg = enabled ? p.accent : p.surface2;
        fg = enabled ? Colors.white : p.inkDis;
        shadow = enabled
            ? const [
                BoxShadow(
                  color: Color(0xBFF2662F),
                  blurRadius: 28,
                  spreadRadius: -12,
                  offset: Offset(0, 14),
                ),
              ]
            : null;
      case ApButtonKind.outline:
        bg = Colors.transparent;
        fg = enabled ? p.primary : p.inkDis;
        side = BorderSide(color: enabled ? p.primary : p.line, width: 2);
      case ApButtonKind.soft:
        bg = p.card;
        fg = p.ink;
        shadow = cardShadow();
      case ApButtonKind.ghost:
        bg = Colors.transparent;
        fg = enabled ? p.primary : p.inkDis;
    }
    final iconSize = small ? 18.0 : 20.0;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: body(
              small ? 14 : (accent ? 18 : 16),
              weight: accent ? FontWeight.w700 : FontWeight.w600,
              color: fg,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 6),
          Icon(trailingIcon, size: iconSize, color: fg),
        ],
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.fromBorderSide(side),
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: enabled ? onPressed : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: small ? 40 : (accent ? 60 : 56),
              minWidth: expand ? double.infinity : 0,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: small || kind == ApButtonKind.ghost ? 14 : 24,
                vertical: small ? 8 : 12,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

enum ApButtonKind { primary, accent, outline, soft, ghost }

class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.tone,
    required this.child,
    this.icon,
    this.title,
    this.padding = const EdgeInsets.all(16),
  });
  final NoticeTone tone;
  final Widget child;
  final IconData? icon;
  final String? title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final (bg, fg) = switch (tone) {
      NoticeTone.info => (p.infoBg, p.info),
      NoticeTone.warn => (p.warningBg, p.warning),
      NoticeTone.err => (p.errorBg, p.error),
      NoticeTone.ok => (p.successBg, p.success),
    };
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? ApIcons.info, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: display(16, weight: FontWeight.w600, color: p.ink),
                  ),
                  const SizedBox(height: 2),
                ],
                DefaultTextStyle.merge(
                  style: body(14, color: p.ink, height: 1.45),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum NoticeTone { info, warn, err, ok }

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: body(14, weight: FontWeight.w600, color: ap(context).ink),
    ),
  );
}

class HelpText extends StatelessWidget {
  const HelpText(this.text, {super.key, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error) ...[
            Icon(ApIcons.alert, size: 16, color: p.error),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text,
              style: body(12.5, color: error ? p.error : p.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

/// When present, idle fields draw [ApPalette.line] instead of a transparent
/// edge — used inside sheets, where fill matches the popup card.
class ApIdleOutline extends InheritedWidget {
  const ApIdleOutline({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApIdleOutline>() != null;

  @override
  bool updateShouldNotify(ApIdleOutline oldWidget) => false;
}

InputDecoration apInput(
  ApPalette p, {
  bool error = false,
  Widget? prefix,
  Widget? suffix,
  Color? fill,
  bool idleBorder = false,
}) {
  final idle = error
      ? p.error
      : idleBorder
      ? p.line
      : Colors.transparent;
  return InputDecoration(
    filled: true,
    fillColor: fill ?? p.card,
    prefixIcon: prefix,
    suffixIcon: suffix,
    hintStyle: body(16, color: p.ink3),
    constraints: const BoxConstraints(minHeight: 60),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: idle, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: idleBorder ? p.line : Colors.transparent,
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: error ? p.error : p.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: p.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: p.error, width: 2),
    ),
    counterText: '',
  );
}

/// Label, outlined field, and error line. Every form field uses this.
class ApTextField extends StatelessWidget {
  const ApTextField({
    super.key,
    this.label,
    this.labelTrailing,
    this.controller,
    this.focusNode,
    this.error,
    this.invalid = false,
    this.hint,
    this.help,
    this.prefix,
    this.suffix,
    this.fill,
    this.digits,
    this.numeric = false,
    this.maxLength,
    this.keyboardType,
    this.obscure = false,
    this.caps = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.style,
    this.minLines,
    this.maxLines = 1,
    this.padding = const EdgeInsets.only(bottom: 12),
  });

  final String? label;
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? error;
  final bool invalid;
  final String? hint;
  final String? help;
  final Widget? prefix;
  final Widget? suffix;
  final Color? fill;
  final int? digits;
  final bool numeric;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool caps;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final int? minLines;
  final int maxLines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final bad = invalid || error != null;
    final idleBorder = ApIdleOutline.of(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Row(
              children: [
                Expanded(child: FieldLabel(label!)),
                ?labelTrailing,
              ],
            ),
          _FieldShadow(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              obscureText: obscure,
              style: style,
              minLines: minLines,
              maxLines: obscure ? 1 : maxLines,
              keyboardType:
                  keyboardType ??
                  ((digits != null || numeric)
                      ? TextInputType.number
                      : TextInputType.text),
              textInputAction: textInputAction,
              textCapitalization: caps
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              inputFormatters: [
                if (digits != null || numeric)
                  FilteringTextInputFormatter.digitsOnly,
                if ((digits ?? maxLength) != null)
                  LengthLimitingTextInputFormatter(digits ?? maxLength!),
              ],
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: apInput(
                p,
                error: bad,
                fill: fill,
                prefix: prefix,
                suffix: suffix,
                idleBorder: idleBorder,
              ).copyWith(hintText: hint),
            ),
          ),
          if (error != null)
            HelpText(error!, error: true)
          else if (help != null)
            HelpText(help!),
        ],
      ),
    );
  }
}

/// Label, outlined dropdown, and error line.
class ApDropdown<T> extends StatelessWidget {
  const ApDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.error,
    this.fill,
    this.compact = false,
    this.padding = const EdgeInsets.only(bottom: 12),
  });

  final bool compact;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final Color? fill;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final idleBorder = ApIdleOutline.of(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) FieldLabel(label!),
          _FieldShadow(
            child: DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(20),
              icon: Icon(ApIcons.chevD, color: p.ink2, size: compact ? 18 : 22),
              hint: hint == null ? null : Text(hint!),
              style: compact
                  ? body(14, weight: FontWeight.w500, color: p.ink)
                  : null,
              decoration: compact
                  ? apInput(
                      p,
                      error: error != null,
                      fill: fill,
                      idleBorder: idleBorder,
                    ).copyWith(
                      constraints: const BoxConstraints(minHeight: 44),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    )
                  : apInput(
                      p,
                      error: error != null,
                      fill: fill,
                      idleBorder: idleBorder,
                    ),
            ),
          ),
          if (error != null) HelpText(error!, error: true),
        ],
      ),
    );
  }
}

/// Prototype `.row`: 48px icon tile, title + subtitle, trailing column.
class ApListRow extends StatelessWidget {
  const ApListRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final Widget leading;
  final Widget title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  static Widget tile(IconData icon, Color bg, Color fg) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(icon, color: fg, size: 22),
  );

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    style: body(14.5, weight: FontWeight.w600, color: p.ink),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: body(12.5, color: p.ink2)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        hoverColor: p.canvas,
        onTap: onTap,
        child: row,
      ),
    );
  }
}

/// Pill filter / preset chip.
class ApChip extends StatelessWidget {
  const ApChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? p.primary : p.card,
        borderRadius: BorderRadius.circular(99),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0xB3302D70),
                  blurRadius: 20,
                  spreadRadius: -10,
                  offset: Offset(0, 10),
                ),
              ]
            : cardShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: body(
                    14,
                    weight: FontWeight.w600,
                    color: selected ? p.onPrimary : p.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldShadow extends StatelessWidget {
  const _FieldShadow({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: cardShadow(),
    ),
    child: child,
  );
}

class TxRow extends StatelessWidget {
  const TxRow({super.key, required this.tx, required this.onTap});
  final Txn tx;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    final c = AppScope.of(context);
    final b = bankById(tx.bank);
    final (bg, fg, icon) = switch (tx.svc) {
      'be' => (p.primarySoft, p.primary, ApIcons.scale),
      'ms' => (p.primarySoft, p.primary, ApIcons.doc),
      _ => switch (tx.status) {
        TxStatus.failed => (p.errorBg, p.error, ApIcons.cash),
        TxStatus.pending => (p.warningBg, p.warning, ApIcons.cash),
        TxStatus.success => (p.primarySoft, p.primary, ApIcons.cash),
      },
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        hoverColor: p.canvas,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: fg, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.t(tx.svc)} · ${b?.short ?? ''}',
                        style: body(
                          14.5,
                          weight: FontWeight.w600,
                          color: p.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${maskAadhaar(tx.aadhaar4)} · ${dayLabel(tx.t, c.lang, c.t('today'), c.t('yesterday'))}, ${fmtT(tx.t)}',
                        style: body(12.5, color: p.ink2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (tx.svc == 'cw')
                      AmountText(tx.amt, size: 17, dec: 0)
                    else
                      Text('—', style: body(12.5, color: p.ink2)),
                    const SizedBox(height: 4),
                    StatusBadge(tx.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepperBar extends StatelessWidget {
  const StepperBar({
    super.key,
    required this.labels,
    required this.index,
    this.doneLast = false,
  });
  final List<String> labels;
  final int index;
  final bool doneLast;

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: cardBox(p, radius: 99),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: i == index && !doneLast
                      ? p.primarySoft
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            (i < index || (doneLast && i == labels.length - 1))
                            ? p.success
                            : i == index
                            ? p.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              (i < index || doneLast && i == labels.length - 1)
                              ? p.success
                              : i == index
                              ? p.primary
                              : p.lineStrong,
                          width: 1.5,
                        ),
                      ),
                      child: (i < index || (doneLast && i == labels.length - 1))
                          ? const Icon(
                              ApIcons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              '${i + 1}',
                              style: body(
                                12,
                                weight: FontWeight.w700,
                                color: i == index ? p.onPrimary : p.ink3,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        labels[i],
                        overflow: TextOverflow.ellipsis,
                        style: body(
                          13,
                          weight: FontWeight.w600,
                          color: i == index && !doneLast
                              ? p.primary
                              : (i < index || doneLast)
                              ? p.ink
                              : p.ink3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BankMono extends StatelessWidget {
  const BankMono(this.bank, {super.key, this.size = 36});
  final Bank bank;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(bank.color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        bank.short.length > 4 ? bank.short.substring(0, 4) : bank.short,
        style: body(
          size < 34 ? 9 : 11,
          weight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ScreenPad extends StatelessWidget {
  const ScreenPad({super.key, required this.child, this.bottom = 28});
  final Widget child;
  final double bottom;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Shows every [AppController.toast] as a [TopSnackBar].
/// Must sit below the app's Navigator so an Overlay is available.
class ToastListener extends StatefulWidget {
  const ToastListener({super.key, required this.child});
  final Widget child;

  @override
  State<ToastListener> createState() => _ToastListenerState();
}

class _ToastListenerState extends State<ToastListener> {
  StreamSubscription<ToastMsg>? _sub;
  AppController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = AppScope.of(context);
    if (identical(c, _controller)) return;
    _sub?.cancel();
    _controller = c;
    _sub = c.toasts.listen(_show);
  }

  void _show(ToastMsg toast) {
    if (!mounted) return;
    final p = ap(context);
    TopSnackBar.show(
      context,
      title: toast.text,
      icon: toast.sim ? ApIcons.info : ApIcons.check,
      color: toast.sim ? p.accentText : p.primary,
      titleFontSize: 14,
      titleMaxLines: 3,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> copyText(
  BuildContext context,
  String value,
  String message,
) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) AppScope.of(context).toast(message);
}
