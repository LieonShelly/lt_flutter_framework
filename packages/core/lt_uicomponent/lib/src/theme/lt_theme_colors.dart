import 'package:flutter/material.dart';
import 'lt_theme_type.dart';
import 'colors.dart';

abstract final class LtThemeColors {
  static ColorScheme getLightColorScheme(LtThemeType type) {
    switch (type) {
      case LtThemeType.neutralV2:
        return AppColors.lightColorScheme;
      case LtThemeType.cosmicEcho:
        return const ColorScheme.light(
          primary: Color(0xFF1E3A8A), // deep blue
          onPrimary: Colors.white,
          secondary: Color(0xFF3B82F6), // soft blue
          surface: Colors.white,
        );
      case LtThemeType.gladeGreen:
        return const ColorScheme.light(
          primary: Color(0xFF166534), // green
          onPrimary: Colors.white,
          secondary: Color(0xFF22C55E), // light green
          surface: Colors.white,
        );
      case LtThemeType.peakNeon:
         return const ColorScheme.light(
          primary: Color(0xFFFF00FF), // neon magenta
          onPrimary: Colors.white,
          secondary: Color(0xFF00FFFF), // neon cyan
          surface: Color(0xFF101010), // dark surface for contrast
        );
    }
  }

  static ColorScheme getDarkColorScheme(LtThemeType type) {
    switch (type) {
      case LtThemeType.neutralV2:
        return AppColors.darkColorScheme;
      case LtThemeType.cosmicEcho:
        return const ColorScheme.dark(
          primary: Color(0xFF60A5FA),
          onPrimary: Colors.black,
          secondary: Color(0xFF93C5FD),
          surface: Color(0xFF101010),
        );
      case LtThemeType.gladeGreen:
        return const ColorScheme.dark(
          primary: Color(0xFF4ADE80),
          onPrimary: Colors.black,
          secondary: Color(0xFF86EFAC),
          surface: Color(0xFF101010),
        );
      case LtThemeType.peakNeon:
         return const ColorScheme.dark(
          primary: Color(0xFFFF00FF),
          onPrimary: Colors.black,
          secondary: Color(0xFF00FFFF),
          surface: Color(0xFF000000),
        );
    }
  }
}
