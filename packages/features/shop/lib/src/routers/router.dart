import 'package:flutter/material.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/pages/auth/login_screen.dart';
import 'package:shop/src/pages/entry_point/entry_point.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case logInScreenRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (context) => const EntryPoint());
    default:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
  }
}
