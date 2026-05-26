import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Loads JSON translations bundled in the [sweeper_l10n] package.
final class SweeperAssetLoader extends AssetLoader {
  const SweeperAssetLoader();

  static const packageName = 'sweeper_l10n';
  static const translationsPath = 'assets/translations';

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final languageCode = locale.languageCode;
    final candidates = [
      '$translationsPath/$languageCode.json',
      '$translationsPath/en.json',
    ];

    for (final relativePath in candidates) {
      try {
        final content = await rootBundle.loadString(
          'packages/$packageName/$relativePath',
        );
        return jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
    }

    return null;
  }
}
