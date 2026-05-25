import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_spacing.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/widgets/explosion_overlay.dart';
import 'package:sweeper_settings/sweeper_settings.dart';

class GameOverPage extends StatelessWidget {
  const GameOverPage({super.key, required this.discoveredCount});

  final int discoveredCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.gameOverTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xxl),
              GameOverAnimation(
                discoveredCount: discoveredCount,
                label: l10n.discoveredBombs(discoveredCount),
              ),
              const SizedBox(height: AppSpacing.xxl * 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final config = GameConfig.fromGridSize(
                      context.read<SettingsCubit>().state.gridSize,
                    );
                    context.read<GameCubit>().restart(config: config);
                    context.go('/');
                  },
                  style: AppButtons.filledCyan,
                  child: Text(l10n.playAgain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
