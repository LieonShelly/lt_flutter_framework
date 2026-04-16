import 'package:flutter/material.dart';
import 'colors.dart';
import 'lt_theme_type.dart';
import 'lt_theme_colors.dart';

abstract final class AppTheme {
  static const _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.grey3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.grey3,
    ),
    labelLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.grey3,
    ),
  );

  static const _inputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(
      // grey3 works for both light and dark themes
      color: AppColors.grey3,
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
    ),
  );

  static ThemeData getThemeData(LtThemeType type, Brightness brightness) {
    final ColorScheme colorScheme = brightness == Brightness.light
        ? LtThemeColors.getLightColorScheme(type)
        : LtThemeColors.getDarkColorScheme(type);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  static ThemeData lightTheme = getThemeData(LtThemeType.neutralV2, Brightness.light);

  static ThemeData darkTheme = getThemeData(LtThemeType.neutralV2, Brightness.dark);
}
