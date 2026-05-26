import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';

class GameTitleHero extends StatelessWidget {
  const GameTitleHero({
    super.key,
    required this.board,
  });

  final Widget board;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: AppOpacity.surfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.heroCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _TitleGlowIcon(),
          const SizedBox(height: AppSpacing.sm),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                AppGradients.gradientEyebrow.createShader(bounds),
            child: Text(
              AppText.labelCaps('reversed'.tr()),
              style: AppTypography.eyebrow,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                AppGradients.gradientHeadline.createShader(bounds),
            child: Text(
              'minesweeper'.tr(),
              textAlign: TextAlign.center,
              style: AppTypography.displayHeadline.copyWith(
                shadows: AppShadows.titleTextGlow,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          board,
        ],
      ),
    );
  }
}

class LoginFeatureGuide extends StatelessWidget {
  const LoginFeatureGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FeatureRow(
          color: AppColors.sun,
          icon: Icons.currency_bitcoin,
          label: 'loginFeatureBtc'.tr(),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FeatureRow(
          color: AppColors.springGreen,
          icon: Icons.auto_awesome,
          label: 'loginFeatureMagic'.tr(),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FeatureRow(
          color: AppColors.coralRed,
          icon: Icons.timer_outlined,
          label: 'loginFeatureBlast'.tr(),
        ),
      ],
    );
  }
}

class GuestPlayButton extends StatelessWidget {
  const GuestPlayButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: AppButtons.outlined,
      child: Text('playAsGuest'.tr()),
    );
  }
}

class _TitleGlowIcon extends StatelessWidget {
  const _TitleGlowIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.titleGlowOuter,
      height: AppSizes.titleGlowOuter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.titleIconGlow(AppColors.coralRed),
        boxShadow: AppShadows.titleIcon(accent: AppColors.coralRed),
      ),
      child: Center(
        child: Container(
          width: AppSizes.titleGlowInner,
          height: AppSizes.titleGlowInner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withValues(alpha: AppOpacity.surfaceStrong),
            boxShadow: AppShadows.titleIcon(accent: AppColors.coralRed),
          ),
          child: Icon(
            Icons.local_fire_department,
            color: AppColors.coralRed,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizes.featureIconBox,
          height: AppSizes.featureIconBox,
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.accentTintSoft),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: AppSizes.iconSm, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyFeature,
          ),
        ),
      ],
    );
  }
}
