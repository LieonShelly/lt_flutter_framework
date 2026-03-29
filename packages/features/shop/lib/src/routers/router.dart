import 'package:flutter/material.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/pages/auth/login_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case logInScreenRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    default:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
  }
}
