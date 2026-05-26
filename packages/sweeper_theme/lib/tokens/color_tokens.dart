import 'package:flutter/material.dart';

/// Semantic color tokens for the app theme.
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFF040A1C);
  static const surface = Color(0xFF131E37);
  static const surfaceBorder = Color(0x14FFFFFF);

  // Text
  static const textPrimary = Color(0xFFF4F9FF);
  static const textSecondary = Color(0xFF92A0B1);

  // Accents
  static const cyan = Color(0xFF00EDF9);
  static const springGreen = Color(0xFF34F47A);
  static const coralRed = Color(0xFFFF4152);
  static const radicalRed = Color(0xFFFF2548);
  static const sun = Color(0xFFFFB113);

  // Board
  static const cellEmpty = Color(0xFF131E37);
  static const cellBorder = Color(0x1AFFFFFF);

  // Game piece (single shared design)
  static const piece = Color(0xFF00EDF9);

  // External / third-party button (e.g. Google Sign-In)
  static const externalButtonBackground = Color(0xFFFFFFFF);
  static const externalButtonForeground = Color(0xFF1F1F1F);
  static const externalButtonBorder = Color(0xFF747775);
}
