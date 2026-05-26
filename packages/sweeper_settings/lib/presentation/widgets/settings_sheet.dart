import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/presentation/widgets/board_size_picker.dart';
import 'package:sweeper_settings/presentation/widgets/language_picker.dart';
import 'package:sweeper_settings/presentation/cubit/settings_cubit.dart';
import 'package:sweeper_settings/presentation/cubit/settings_state.dart';
import 'package:sweeper_theme/app_tokens.dart';

/// Scrollable settings body — board size and language preferences.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    this.footer,
    this.onGridSizeSelected,
  });

  final Widget? footer;
  final Future<void> Function(BuildContext sheetContext, int gridSize)?
      onGridSizeSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'boardSize'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                BoardSizePicker(
                  selectedSize: settings.gridSize,
                  onSelected: (size) => _onGridSizeSelected(context, size),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'language'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                LanguagePicker(
                  selectedLanguageCode: settings.languageCode,
                  onSelected: (code) => _onLanguageSelected(context, code),
                ),
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  footer!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onGridSizeSelected(BuildContext context, int size) async {
    final sheetContext = context;
    await context.read<SettingsCubit>().setGridSize(size);
    if (!sheetContext.mounted) return;

    final handler = onGridSizeSelected;
    if (handler != null) {
      await handler(sheetContext, size);
    }
  }

  Future<void> _onLanguageSelected(BuildContext context, String code) async {
    await context.read<SettingsCubit>().setLanguageCode(code);
    if (!context.mounted) return;
    await context.setLocale(AppLocales.localeFor(code));
  }
}

/// Presents [SettingsSheet] in a modal bottom sheet.
Future<T?> showSettingsSheet<T>(
  BuildContext context, {
  Widget? footer,
  Future<void> Function(BuildContext sheetContext, int gridSize)?
      onGridSizeSelected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SettingsSheet(
        footer: footer,
        onGridSizeSelected: onGridSizeSelected,
      );
    },
  );
}
