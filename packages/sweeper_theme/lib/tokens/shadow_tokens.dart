import 'package:flutter/material.dart';
import 'package:sweeper_theme/tokens/blur_tokens.dart';
import 'package:sweeper_theme/tokens/color_tokens.dart';
import 'package:sweeper_theme/tokens/opacity_tokens.dart';

/// Elevation and glow shadow tokens.
abstract final class AppShadows {
  static List<BoxShadow> externalButton({Color? shadowColor}) => [
        BoxShadow(
          color: (shadowColor ?? Colors.black)
              .withValues(alpha: AppOpacity.shadowExternal),
          blurRadius: AppBlur.sm,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> surfaceCard({required Color accent}) => [
        BoxShadow(
          color: accent.withValues(alpha: AppOpacity.cardAccentGlow),
          blurRadius: AppBlur.xl4,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get heroCard => [
        BoxShadow(
          color: AppColors.cyan.withValues(alpha: AppOpacity.heroCyanGlow),
          blurRadius: AppBlur.xl6,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: AppColors.coralRed.withValues(alpha: AppOpacity.heroCoralGlow),
          blurRadius: AppBlur.xl4,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> titleIcon({required Color accent}) => [
        BoxShadow(
          color: accent.withValues(alpha: AppOpacity.accentGlowMedium),
          blurRadius: AppBlur.xl,
        ),
      ];

  static List<Shadow> get titleTextGlow => [
        Shadow(
          color: AppColors.cyan.withValues(alpha: AppOpacity.accentGlowStrong),
          blurRadius: AppBlur.xl2,
        ),
      ];

  static List<BoxShadow> get magicCell => [
        BoxShadow(
          color: AppColors.sun.withValues(alpha: AppOpacity.magicCellGlow),
          blurRadius: AppBlur.md,
        ),
      ];
}
