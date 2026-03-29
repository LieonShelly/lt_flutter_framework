import 'package:flutter/material.dart';
import 'package:shop/shop.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    default:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
  }
}
