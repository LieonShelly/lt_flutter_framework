import 'package:flutter/material.dart';
import 'lt_theme_controller.dart';

class LtThemeProvider extends InheritedNotifier<LtThemeController> {
  const LtThemeProvider({
    super.key,
    required LtThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static LtThemeController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LtThemeProvider>()
        ?.notifier;
  }

  static LtThemeController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No LtThemeProvider found in context');
    return controller!;
  }
}
