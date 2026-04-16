import 'package:answer_detail/answer_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/app_router.dart';
import 'src/di/app_providers.dart';
import 'package:feature_core/feature_core.dart';

void main() {
  runApp(
    ProviderScope(overrides: AppProviders.overrides, child: const MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentLocale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      // showPerformanceOverlay: true,
      // checkerboardOffscreenLayers: true,
      routerConfig: router,
      title: 'theLittle Thing',
      locale: currentLocale,
      localizationsDelegates: const [
        AnswerDetailLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFDF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFDF8),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}
