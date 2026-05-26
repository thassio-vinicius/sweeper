import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';

class GamePauseOverlay extends StatelessWidget {
  const GamePauseOverlay({
    super.key,
    required this.onResume,
  });

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 64,
              color: AppColors.cyan.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.paused,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.resume),
              style: AppButtons.filledCyan,
            ),
          ],
        ),
      ),
    );
  }
}
