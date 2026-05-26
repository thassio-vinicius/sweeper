import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sweeper_theme/tokens/color_tokens.dart';

/// Typography tokens — font scale and composed text styles.
///
/// Fonts are loaded via [google_fonts] (Poppins for display, Inter for body).
abstract final class AppTypography {
  static const fontSize2xs = 9.0;
  static const fontSizeXs = 10.0;
  static const fontSizeSm = 11.0;
  static const fontSizeMd = 13.0;
  static const fontSizeBase = 14.0;
  static const fontSizeXl = 16.0;
  static const fontSize2xl = 24.0;
  static const fontSize3xl = 28.0;

  static const fontWeightRegular = FontWeight.w400;
  static const fontWeightSemibold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;
  static const fontWeightExtraBold = FontWeight.w800;

  static const letterSpacingTight = -0.48;
  static const letterSpacingEyebrow = 4.8;
  static const letterSpacingLabel = 2.4;
  static const letterSpacingBody = 0.28;
  static const letterSpacingButton = 0.1;

  static const lineHeightTight = 1.0;
  static const lineHeightSnug = 1.2;
  static const lineHeightNormal = 1.3;

  static TextStyle _display({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle _body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle get headlineLarge => _display(
        fontSize: fontSize2xl,
        fontWeight: fontWeightExtraBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get titleMedium => _body(
        fontSize: fontSizeXs,
        fontWeight: fontWeightSemibold,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingLabel,
      );

  static TextStyle get bodySmall => _body(
        fontSize: fontSizeMd,
        fontWeight: fontWeightRegular,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingBody,
      );

  static TextStyle get labelLarge => _body(
        fontSize: fontSizeXl,
        fontWeight: fontWeightBold,
        color: AppColors.springGreen,
      );

  static TextStyle get buttonPrimary => _body(
        fontSize: fontSizeXl,
        fontWeight: fontWeightBold,
      );

  static TextStyle get buttonSecondary => _body(
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
      );

  static TextStyle get buttonDestructive => _body(
        fontSize: fontSizeBase,
        fontWeight: fontWeightSemibold,
      );

  static TextStyle get externalButtonLabel => _body(
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
        color: AppColors.externalButtonForeground,
        letterSpacing: letterSpacingButton,
      );

  static TextStyle get eyebrow => titleMedium.copyWith(
        fontSize: fontSizeSm,
        letterSpacing: letterSpacingEyebrow,
        color: Colors.white,
      );

  static TextStyle get displayHeadline => headlineLarge.copyWith(
        fontSize: fontSize3xl,
        height: lineHeightTight,
        color: Colors.white,
      );

  static TextStyle get bodyFeature => bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontSize: fontSizeSm,
        height: lineHeightNormal,
      );

  static TextStyle get statLabel => titleMedium.copyWith(
        fontSize: fontSize2xs,
        height: lineHeightSnug,
      );

  static TextStyle get statValue => _body(
        fontSize: fontSizeBase,
        fontWeight: fontWeightBold,
      );

  static TextStyle get statSubValue => _body(
        fontSize: fontSizeXs,
      );

  static TextStyle get emphasisLabel => _body(
        fontSize: fontSizeBase + 1,
        fontWeight: fontWeightExtraBold,
        letterSpacing: 0.4,
      );
}
