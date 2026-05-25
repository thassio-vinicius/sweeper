import 'package:flutter/material.dart';
import 'package:sweeper_theme/tokens/color_tokens.dart';

/// Gradient tokens for branded surfaces.
abstract final class AppGradients {
  static const loginEyebrow = LinearGradient(
    colors: [AppColors.cyan, AppColors.springGreen],
  );

  static const loginTitle = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.textPrimary,
      AppColors.cyan,
      AppColors.springGreen,
    ],
  );

  static RadialGradient titleIconGlow(Color accent) => RadialGradient(
        colors: [
          accent.withValues(alpha: 0.35),
          AppColors.background.withValues(alpha: 0.0),
        ],
      );

  static RadialGradient backdropOrb(Color accent) => RadialGradient(
        colors: [
          accent.withValues(alpha: 0.22),
          accent.withValues(alpha: 0.0),
        ],
      );
}
