import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/gradient_text.dart';

enum GameTitleBrandSize { compact, hero }

/// Shared gradient game mark — glow icon, eyebrow, and headline.
class GameTitleBrand extends StatelessWidget {
  const GameTitleBrand({
    super.key,
    required this.eyebrow,
    required this.title,
    this.size = GameTitleBrandSize.hero,
  });

  final String eyebrow;
  final String title;
  final GameTitleBrandSize size;

  bool get _isHero => size == GameTitleBrandSize.hero;

  double get _iconOuter => _isHero ? AppSizes.titleGlowOuter : 36;
  double get _iconInner => _isHero ? AppSizes.titleGlowInner : 28;
  double get _iconGlyph => _isHero ? AppSizes.iconMd : AppSizes.iconSm;

  TextStyle get _eyebrowStyle =>
      _isHero ? AppTypography.eyebrow : AppTypography.eyebrow.copyWith(
            fontSize: AppTypography.fontSize2xs,
            letterSpacing: AppTypography.letterSpacingLabel,
          );

  TextStyle get _titleStyle => (_isHero
          ? AppTypography.displayHeadline
          : AppTypography.headlineLarge.copyWith(
              height: AppTypography.lineHeightTight,
              color: Colors.white,
            ))
      .copyWith(shadows: AppShadows.titleTextGlow);

  @override
  Widget build(BuildContext context) {
    final icon = _GameTitleGlowIcon(
      outer: _iconOuter,
      inner: _iconInner,
      glyphSize: _iconGlyph,
    );
    final eyebrowText = GradientText(
      text: eyebrow,
      style: _eyebrowStyle,
      gradient: AppGradients.gradientEyebrow,
    );
    final headlineText = GradientText(
      text: title,
      textAlign: _isHero ? TextAlign.center : TextAlign.start,
      style: _titleStyle,
      gradient: AppGradients.gradientHeadline,
    );

    if (_isHero) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: AppSpacing.sm),
          eyebrowText,
          const SizedBox(height: AppSpacing.xs),
          headlineText,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              eyebrowText,
              headlineText,
            ],
          ),
        ),
      ],
    );
  }
}

class _GameTitleGlowIcon extends StatelessWidget {
  const _GameTitleGlowIcon({
    required this.outer,
    required this.inner,
    required this.glyphSize,
  });

  final double outer;
  final double inner;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outer,
      height: outer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.titleIconGlow(AppColors.coralRed),
        boxShadow: AppShadows.titleIcon(accent: AppColors.coralRed),
      ),
      child: Center(
        child: Container(
          width: inner,
          height: inner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withValues(alpha: AppOpacity.surfaceStrong),
            boxShadow: AppShadows.titleIcon(accent: AppColors.coralRed),
          ),
          child: Icon(
            Icons.local_fire_department,
            color: AppColors.coralRed,
            size: glyphSize,
          ),
        ),
      ),
    );
  }
}
