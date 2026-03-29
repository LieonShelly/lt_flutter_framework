import 'package:flutter/material.dart';
import 'package:shop/shop.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      onGenerateRoute: generateRoute,
      themeMode: ThemeMode.light,
      initialRoute: onbordingScreenRoute,
    );
  }
}
