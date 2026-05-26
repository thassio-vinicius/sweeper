import 'package:flutter/material.dart';

/// Supported locales and Easy Localization bootstrap settings.
abstract final class AppLocales {
  static const fallback = Locale('en');
  static const supported = [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  static const supportedLanguageCodes = ['en', 'es', 'pt'];

  static String displayName(String languageCode) {
    return switch (languageCode) {
      'es' => 'Español',
      'pt' => 'Português',
      _ => 'English',
    };
  }

  static bool isSupportedLanguage(String languageCode) {
    return supportedLanguageCodes.contains(languageCode);
  }

  static Locale localeFor(String languageCode) {
    return isSupportedLanguage(languageCode)
        ? Locale(languageCode)
        : fallback;
  }
}
