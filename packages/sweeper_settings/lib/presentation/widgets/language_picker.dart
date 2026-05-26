import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.selectedLanguageCode,
    required this.onSelected,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppLocales.supportedLanguageCodes.map((code) {
        final selected = selectedLanguageCode == code;
        return ChoiceChip(
          label: Text(AppLocales.displayName(code)),
          selected: selected,
          onSelected: (_) => onSelected(code),
        );
      }).toList(),
    );
  }
}
