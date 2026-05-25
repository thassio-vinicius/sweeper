import 'package:flutter/material.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';

abstract final class AppButtons {
  static ButtonStyle get filledCyan => FilledButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );

  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.surfaceBorder),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get signOut => OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.coralRed,
        side: BorderSide(color: AppColors.coralRed.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xl,
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
}
