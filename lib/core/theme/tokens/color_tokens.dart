import 'package:flutter/material.dart';

/// Color design tokens for the neon-bomb-drop theme.
abstract final class AppColors {
  // --- Surfaces ---
  static const background = Color(0xFF040A1C);
  static const surface = Color(0xFF131E37);
  static const surfaceBorder = Color(0x14FFFFFF);

  // --- Text ---
  static const textPrimary = Color(0xFFF4F9FF);
  static const textSecondary = Color(0xFF92A0B1);
  static const textMuted = Color(0xFFEDF2F8);

  // --- Brand accents ---
  static const cyan = Color(0xFF00EDF9);
  static const springGreen = Color(0xFF34F47A);
  static const coralRed = Color(0xFFFF4152);
  static const radicalRed = Color(0xFFFF2548);
  static const sun = Color(0xFFFFB113);

  // --- Board ---
  static const cellEmpty = Color(0xFF131E37);
  static const cellBorder = Color(0x1AFFFFFF);

  // --- Pieces ---
  static const pieceCyan = Color(0xFF00EDF9);
  static const piecePurple = Color(0xFF9B59FF);
  static const pieceGreen = Color(0xFF34F47A);
  static const pieceOrange = Color(0xFFFFB113);

  // --- External brand (Google sign-in) ---
  static const googleSignInBackground = Color(0xFFFFFFFF);
  static const googleSignInForeground = Color(0xFF1F1F1F);
  static const googleSignInBorder = Color(0xFF747775);
  static const googleSignInShadow = Color(0x2E000000);

  // --- Overlays ---
  static const scrim = Color(0xBF040A1C);
}
