import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'app_current_locale';

  @override
  Locale build() {
    _loadFromPrefs();
    return const Locale('en');
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      if (savedLocale != null) {
        state = Locale(savedLocale);
      }
    } catch (_) {}
  }

  void setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (_) {}
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(() {
  return AppLocaleNotifier();
});
