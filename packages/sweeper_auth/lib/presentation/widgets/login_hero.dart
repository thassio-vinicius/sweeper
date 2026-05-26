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
    final l10n = AppLocalizations.of(context);

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
              l10n.reversed,
              style: AppTypography.eyebrow,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                AppGradients.gradientHeadline.createShader(bounds),
            child: Text(
              l10n.minesweeper,
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
      ),
      child: Center(
        child: Container(
          width: AppSizes.titleGlowInner,
          height: AppSizes.titleGlowInner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.coralRed.withValues(alpha: AppOpacity.accentBorder),
            ),
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

class LoginFeatureGuide extends StatelessWidget {
  const LoginFeatureGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: AppOpacity.surfaceSoft),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FeatureRow(
            icon: Icons.currency_bitcoin,
            label: l10n.loginFeatureBtc,
            color: AppColors.sun,
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          _FeatureRow(
            icon: Icons.auto_awesome,
            label: l10n.loginFeatureMagic,
            color: AppColors.cyan,
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          _FeatureRow(
            icon: Icons.timer_outlined,
            label: l10n.loginFeatureBlast,
            color: AppColors.coralRed,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.featureIconBox,
            height: AppSizes.featureIconBox,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppOpacity.accentTintSoft),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: color.withValues(alpha: AppOpacity.accentBorderMuted),
              ),
            ),
            child: Icon(icon, size: AppSizes.iconSm, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyFeature,
            ),
          ),
        ],
      ),
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
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppButtons.outlined,
        child: Text(l10n.playAsGuest),
      ),
    );
  }
}
