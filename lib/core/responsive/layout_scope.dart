import 'package:flutter/widgets.dart';

import 'layout_service.dart';

class LayoutScope extends InheritedWidget {
  const LayoutScope({super.key, required this.profile, required super.child});

  final LayoutProfile profile;

  static LayoutProfile of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LayoutScope>();
    return scope?.profile ?? const LayoutService().resolve(390);
  }

  @override
  bool updateShouldNotify(LayoutScope oldWidget) =>
      oldWidget.profile.viewport != profile.viewport ||
      (oldWidget.profile.width - profile.width).abs() > 1;
}
