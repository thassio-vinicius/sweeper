import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.cyan,
        secondary: AppColors.springGreen,
        error: AppColors.coralRed,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headlineLarge,
        titleMedium: AppTypography.titleMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(style: AppButtons.filledCyan),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtons.outlined),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
