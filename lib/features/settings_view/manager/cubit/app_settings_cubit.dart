import 'package:el_karma_ph/features/settings_view/manager/cubit/app_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit._(super.initial, this._prefs);

  static const _darkModeKey = 'isDarkMode';
  static const _languageKey = 'languageCode';

  final SharedPreferences _prefs;

  static Future<AppSettingsCubit> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_darkModeKey) ?? false;
    final languageCode = prefs.getString(_languageKey) ?? 'en';

    return AppSettingsCubit._(
      AppSettingsState(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(languageCode),
      ),
      prefs,
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    emit(state.copyWith(themeMode: enabled ? ThemeMode.dark : ThemeMode.light));
    await _prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> setArabic(bool enabled) async {
    final code = enabled ? 'ar' : 'en';
    emit(state.copyWith(locale: Locale(code)));
    await _prefs.setString(_languageKey, code);
  }
}
