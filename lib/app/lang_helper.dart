import 'package:flutter/material.dart';

enum AppLanguage { en, de,fr }

class AppLanguageData {
  final String code;
  final String displayName;

  const AppLanguageData(this.code, this.displayName);
}

extension AppLanguageExtension on AppLanguage {
  /// Default language code if not specified
  static const defaultCode = 'en';
  static const Map<AppLanguage, AppLanguageData> _data = {
    AppLanguage.en: AppLanguageData('en', 'English'),
    AppLanguage.de: AppLanguageData('de', 'Deutsch'),
    AppLanguage.fr: AppLanguageData('fr', 'Francais'),
  };

  String get code => _data[this]!.code;
  String get displayName => _data[this]!.displayName;
  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return _data.entries
        .firstWhere((entry) => entry.value.code == code,
        orElse: () => MapEntry(AppLanguage.en, _data[AppLanguage.en]!))
        .key;
  }

  static List<Locale> get supportedLocales =>
      AppLanguage.values.map((e) => e.locale).toList();


}