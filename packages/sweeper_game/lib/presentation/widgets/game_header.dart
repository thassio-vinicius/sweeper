import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/sweeper_theme.dart';

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
    return Row(
      children: [
        Expanded(
          child: GameTitleBrand(
            size: GameTitleBrandSize.compact,
            eyebrow: AppText.labelCaps('reversed'.tr()),
            title: 'minesweeper'.tr(),
          ),
        ),
        IconButton(
          onPressed: onPauseToggle,
          tooltip: isPaused ? 'resume'.tr() : 'pause'.tr(),
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
