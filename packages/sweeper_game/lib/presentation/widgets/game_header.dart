import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.isPaused,
    required this.onPauseToggle,
    required this.onReset,
    required this.onSettings,
  });

  final bool isPaused;
  final VoidCallback onPauseToggle;
  final VoidCallback onReset;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reversed,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                l10n.minesweeper,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onPauseToggle,
          tooltip: isPaused ? l10n.resume : l10n.pause,
          icon: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: AppColors.cyan,
          ),
        ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings, color: AppColors.textSecondary),
        ),
        IconButton(
          onPressed: onReset,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.refresh, color: AppColors.cyan),
        ),
      ],
    );
  }
}
