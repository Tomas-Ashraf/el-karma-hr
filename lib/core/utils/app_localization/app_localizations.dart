import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations._(this.locale, this._strings, this._fallback);

  final Locale locale;
  final Map<String, String> _strings;
  final Map<String, String> _fallback;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final isSupported = supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
    final code = isSupported ? locale.languageCode : 'en';

    final strings = await _loadFile(code);
    final fallback = code == 'en' ? strings : await _loadFile('en');

    return AppLocalizations._(Locale(code), strings, fallback);
  }

  static Future<Map<String, String>> _loadFile(String code) async {
    final content = await rootBundle.loadString('assets/lang/$code.json');
    final decoded = json.decode(content) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key, {Map<String, String>? args}) {
    var text = _strings[key] ?? _fallback[key] ?? key;
    args?.forEach((name, value) {
      text = text.replaceAll('{$name}', value);
    });
    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension TranslateContext on BuildContext {
  String tr(String key, {Map<String, String>? args}) {
    return AppLocalizations.of(this).translate(key, args: args);
  }
}
