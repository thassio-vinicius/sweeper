import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

abstract final class AppButtons {
  static ButtonStyle get filledCyan => FilledButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        textStyle: AppTypography.buttonPrimary,
      );

  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.surfaceBorder),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        textStyle: AppTypography.buttonSecondary,
      );

  static ButtonStyle get signOut => OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.coralRed,
        side: BorderSide(
          color: AppColors.coralRed.withValues(alpha: AppOpacity.accentBorderSoft),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xl,
        ),
        textStyle: AppTypography.buttonDestructive,
      );
}
