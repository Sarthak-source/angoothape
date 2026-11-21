import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../theme/ap_icons.dart';

class TopSnackBar extends StatefulWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final double? titleFontSize;
  final int? titleMaxLines;
  final double? messageFontSize;
  final int? messageMaxLines;

  const TopSnackBar({
    super.key,
    required this.title,
    this.message,
    required this.icon,
    required this.color,
    this.onDismiss,
    this.onTap,
    this.titleFontSize,
    this.titleMaxLines,
    this.messageFontSize,
    this.messageMaxLines,
  });

  static OverlayEntry? _current;

  /// Shows the snackbar at the top of the screen as a non-blocking overlay.
  /// A new snackbar replaces the one already on screen.
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    double? titleFontSize,
    int? titleMaxLines,
    double? messageFontSize,
    int? messageMaxLines,
  }) {
    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) {
      assert(() {
        debugPrint(
          'TopSnackBar.show: no Overlay (wrong context — use a descendant '
          'of Navigator/Overlay, not navigatorKey.currentContext)',
        );
        return true;
      }());
      return;
    }
    late OverlayEntry entry;

    void removeEntry() {
      if (entry.mounted) {
        entry.remove();
      }
      if (identical(_current, entry)) _current = null;
    }

    final previous = _current;
    if (previous != null && previous.mounted) previous.remove();

    entry = OverlayEntry(
      builder: (ctx) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TopSnackBar(
                  title: title,
                  message: message,
                  icon: icon,
                  color: color,
                  onDismiss: removeEntry,
                  onTap: onTap,
                  titleFontSize: titleFontSize,
                  titleMaxLines: titleMaxLines,
                  messageFontSize: messageFontSize,
                  messageMaxLines: messageMaxLines,
                ),
              ),
            ),
          ),
        );
      },
    );

    _current = entry;
    overlayState.insert(entry);
  }

  @override
  State<TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  late Animation<double> fade;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    controller.forward();

    _autoDismissTimer = Timer(const Duration(seconds: 3), dismiss);
  }

  Future<void> dismiss() async {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (!mounted) return;
    try {
      await controller.reverse();
    } catch (_) {
      // Overlay removed / [dispose] ran while reversing (ticker detached).
    }
    if (!mounted) return;
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ap(context);
    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap == null
                ? null
                : () {
                    try {
                      widget.onTap?.call();
                    } finally {
                      unawaited(dismiss());
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          maxLines: widget.titleMaxLines,
                          overflow: widget.titleMaxLines == null
                              ? null
                              : TextOverflow.ellipsis,
                          style: body(
                            widget.titleFontSize ?? 15,
                            weight: FontWeight.w600,
                            color: p.ink,
                            height: 1.3,
                          ),
                        ),
                        if (widget.message != null)
                          Text(
                            widget.message!,
                            maxLines: widget.messageMaxLines ?? 3,
                            overflow: TextOverflow.ellipsis,
                            style: body(
                              widget.messageFontSize ?? 12,
                              color: p.ink2,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: dismiss,
                    child: Icon(ApIcons.close, size: 18, color: p.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
