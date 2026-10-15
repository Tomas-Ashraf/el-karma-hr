import 'package:flutter/material.dart';

class AppSettingsState {
  const AppSettingsState({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';

  AppSettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
