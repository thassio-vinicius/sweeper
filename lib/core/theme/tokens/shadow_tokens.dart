import 'package:flutter/material.dart';
import 'package:sweeper/core/theme/tokens/color_tokens.dart';
import 'package:sweeper/core/theme/tokens/opacity_tokens.dart';

/// Elevation and glow shadow tokens.
abstract final class AppShadows {
  static List<BoxShadow> googleSignIn({Color? shadowColor}) => [
        BoxShadow(
          color: (shadowColor ?? Colors.black)
              .withValues(alpha: AppOpacity.googleShadow),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> surfaceCard({required Color accent}) => [
        BoxShadow(
          color: accent.withValues(alpha: AppOpacity.cardAccentGlow),
          blurRadius: 24,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get loginHeroPrimary => [
    BoxShadow(
      color: AppColors.cyan.withValues(alpha: AppOpacity.heroCyanGlow),
      blurRadius: 32,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: AppColors.coralRed.withValues(alpha: AppOpacity.heroCoralGlow),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> titleIcon({required Color accent}) => [
        BoxShadow(
          color: accent.withValues(alpha: AppOpacity.accentGlowMedium),
          blurRadius: 16,
        ),
      ];

  static List<Shadow> get titleTextGlow => [
        Shadow(
          color: AppColors.cyan.withValues(alpha: AppOpacity.accentGlowStrong),
          blurRadius: 18,
        ),
      ];

  static List<BoxShadow> get magicCell => [
        BoxShadow(
          color: AppColors.sun.withValues(alpha: AppOpacity.magicCellGlow),
          blurRadius: 10,
        ),
      ];

  static List<BoxShadow> get loginBoardPreview => [
        BoxShadow(
          color: AppColors.cyan.withValues(alpha: AppOpacity.accentBorderSubtle),
          blurRadius: 28,
          spreadRadius: -2,
        ),
      ];
}
