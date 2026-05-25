import 'package:flutter/material.dart';
import 'package:sweeper_theme/tokens/color_tokens.dart';

/// Typography tokens — font families, scale, and composed text styles.
abstract final class AppTypography {
  static const fontFamilyDisplay = 'Poppins';
  static const fontFamilyBody = 'Inter';

  static const fontSize2xs = 9.0;
  static const fontSizeXs = 10.0;
  static const fontSizeSm = 11.0;
  static const fontSizeMd = 13.0;
  static const fontSizeBase = 14.0;
  static const fontSizeLg = 15.0;
  static const fontSizeXl = 16.0;
  static const fontSize2xl = 24.0;
  static const fontSize3xl = 28.0;
  static const fontSizeDisplay = 34.0;

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
  static const lineHeightRelaxed = 1.5;

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: fontFamilyDisplay,
        fontSize: fontSize2xl,
        fontWeight: fontWeightExtraBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingTight,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXs,
        fontWeight: fontWeightSemibold,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingLabel,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeMd,
        fontWeight: fontWeightRegular,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingBody,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXl,
        fontWeight: fontWeightBold,
        color: AppColors.springGreen,
      );

  static TextStyle get buttonPrimary => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXl,
        fontWeight: fontWeightBold,
      );

  static TextStyle get buttonSecondary => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
      );

  static TextStyle get buttonDestructive => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeBase,
        fontWeight: fontWeightSemibold,
      );

  static TextStyle get googleSignInLabel => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
        color: AppColors.googleSignInForeground,
        letterSpacing: letterSpacingButton,
      );

  static TextStyle get loginEyebrow => titleMedium.copyWith(
        fontSize: fontSizeSm,
        letterSpacing: letterSpacingEyebrow,
        color: Colors.white,
      );

  static TextStyle get loginTitle => headlineLarge.copyWith(
        fontSize: fontSize3xl,
        height: lineHeightTight,
        color: Colors.white,
      );

  static TextStyle get loginFeature => bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontSize: fontSizeSm,
        height: lineHeightNormal,
      );

  static TextStyle get loginFeatureShort => bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontSize: fontSize2xs,
        height: lineHeightSnug,
      );

  static TextStyle get statLabel => titleMedium.copyWith(
        fontSize: fontSize2xs,
        height: lineHeightSnug,
      );

  static TextStyle get statValue => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeBase,
        fontWeight: fontWeightBold,
      );

  static TextStyle get statSubValue => const TextStyle(
        fontFamily: fontFamilyBody,
        fontSize: fontSizeXs,
      );
}
