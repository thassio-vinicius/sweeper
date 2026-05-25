import 'package:flutter/material.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/core/widgets/app_buttons.dart';

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
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.14),
            blurRadius: 32,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: AppColors.coralRed.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TitleGlowIcon(),
          const SizedBox(height: AppSpacing.sm),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.cyan, AppColors.springGreen],
            ).createShader(bounds),
            child: Text(
              l10n.reversed,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 4.8,
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.textPrimary,
                AppColors.cyan,
                AppColors.springGreen,
              ],
            ).createShader(bounds),
            child: Text(
              l10n.minesweeper,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    height: 1,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: AppColors.cyan.withValues(alpha: 0.45),
                        blurRadius: 18,
                      ),
                    ],
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.coralRed.withValues(alpha: 0.35),
            AppColors.background.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: AppColors.coralRed.withValues(alpha: 0.35),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department,
            color: AppColors.coralRed,
            size: 18,
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
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
          Divider(height: 1, color: AppColors.surfaceBorder),
          _FeatureRow(
            icon: Icons.auto_awesome,
            label: l10n.loginFeatureMagic,
            color: AppColors.cyan,
          ),
          Divider(height: 1, color: AppColors.surfaceBorder),
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.cellRadius),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    height: 1.3,
                  ),
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
