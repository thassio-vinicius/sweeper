import 'package:flutter/material.dart';

/// Supported locales and Easy Localization bootstrap settings.
abstract final class AppLocales {
  static const fallback = Locale('en');
  static const supported = [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];
}
