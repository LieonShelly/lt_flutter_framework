import 'package:flutter/material.dart';
import 'lt_theme_controller.dart';
import 'lt_theme_type.dart';
import 'app_theme.dart';
import 'lt_theme_provider.dart';

class LtThemeBuilder extends StatefulWidget {
  const LtThemeBuilder({
    super.key,
    required this.builder,
    this.initialTheme = LtThemeType.neutralV2,
    this.initialMode = ThemeMode.system,
  });

  final Widget Function(
    BuildContext context,
    ThemeData theme,
    ThemeData darkTheme,
    ThemeMode themeMode,
  )
  builder;

  final LtThemeType initialTheme;
  final ThemeMode initialMode;

  @override
  State<LtThemeBuilder> createState() => _LtThemeBuilderState();
}

class _LtThemeBuilderState extends State<LtThemeBuilder> {
  late final LtThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LtThemeController(
      initialTheme: widget.initialTheme,
      initialMode: widget.initialMode,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LtThemeProvider(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final themeData = AppTheme.getThemeData(
            _controller.themeType,
            Brightness.light,
          );
          final darkThemeData = AppTheme.getThemeData(
            _controller.themeType,
            Brightness.dark,
          );

          return widget.builder(
            context,
            themeData,
            darkThemeData,
            _controller.themeMode,
          );
        },
      ),
    );
  }
}
