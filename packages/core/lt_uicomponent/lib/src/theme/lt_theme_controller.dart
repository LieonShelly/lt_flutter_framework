import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lt_theme_type.dart';

class LtThemeController extends ChangeNotifier {
  LtThemeController({
    LtThemeType initialTheme = LtThemeType.neutralV2,
    ThemeMode initialMode = ThemeMode.system,
  })  : _themeType = initialTheme,
        _themeMode = initialMode {
    _loadFromPrefs();
  }

  static const _themeTypeKey = 'lt_theme_type';
  static const _themeModeKey = 'lt_theme_mode';

  LtThemeType _themeType;
  ThemeMode _themeMode;

  LtThemeType get themeType => _themeType;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedThemeStr = prefs.getString(_themeTypeKey);
      if (savedThemeStr != null) {
        _themeType = LtThemeType.values.firstWhere(
          (e) => e.name == savedThemeStr,
          orElse: () => _themeType,
        );
      }

      final savedModeStr = prefs.getString(_themeModeKey);
      if (savedModeStr != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == savedModeStr,
          orElse: () => _themeMode,
        );
      }
      
      notifyListeners();
    } catch (_) {
      // Handle missing bindings or plugin errors gracefully
    }
  }

  void changeTheme(LtThemeType newType) async {
    if (_themeType != newType) {
      _themeType = newType;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeTypeKey, newType.name);
      } catch (_) {}
    }
  }

  void changeThemeMode(ThemeMode newMode) async {
    if (_themeMode != newMode) {
      _themeMode = newMode;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themeModeKey, newMode.name);
      } catch (_) {}
    }
  }
}
