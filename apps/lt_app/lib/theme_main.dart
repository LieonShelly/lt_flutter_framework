import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:ltapp_flutter/src/theme_test_view.dart';
import 'src/app_router.dart';
import 'src/di/app_providers.dart';

void main() {
  runApp(
    ProviderScope(overrides: AppProviders.overrides, child: const MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LtThemeBuilder(
      initialMode: ThemeMode.dark,
      initialTheme: LtThemeType.cosmicEcho,
      builder: (context, theme, darkTheme, themeMode) {
        return MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: ThemeTestView(),
        );
      },
    );
  }
}
