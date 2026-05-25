import 'package:flutter/material.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';

/// Surface card matching in-game HUD stat tiles.
class GameSurfaceCard extends StatelessWidget {
  const GameSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final glow = accentColor ?? AppColors.cyan;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}
