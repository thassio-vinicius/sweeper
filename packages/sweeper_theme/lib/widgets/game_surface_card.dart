import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

/// Surface card matching in-game HUD stat tiles.
class GameSurfaceCard extends StatelessWidget {
  const GameSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accentColor,
    this.surfaceOpacity = AppOpacity.surfaceMedium,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final double surfaceOpacity;

  @override
  Widget build(BuildContext context) {
    final glow = accentColor ?? AppColors.cyan;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: surfaceOpacity),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.surfaceCard(accent: glow),
      ),
      child: child,
    );
  }
}
