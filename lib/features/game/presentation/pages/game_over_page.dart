import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/core/widgets/app_buttons.dart';
import 'package:sweeper/features/game/presentation/cubit/game_cubit.dart';
import 'package:sweeper/features/game/presentation/widgets/explosion_overlay.dart';
import 'package:sweeper/features/settings/presentation/cubit/settings_cubit.dart';

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
                    final config =
                        context.read<SettingsCubit>().state.toGameConfig();
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
