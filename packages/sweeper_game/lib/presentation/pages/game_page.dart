import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper_game/navigation/game_navigation.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';
import 'package:sweeper_game/presentation/widgets/board_grid.dart';
import 'package:sweeper_game/presentation/widgets/game_header.dart';
import 'package:sweeper_game/presentation/widgets/game_hud.dart';
import 'package:sweeper_game/presentation/widgets/game_pause_overlay.dart';
import 'package:sweeper_game/presentation/widgets/game_menu_sheet.dart';
import 'package:sweeper_game/presentation/widgets/game_stats_grid.dart';
import 'package:sweeper_game/presentation/widgets/magic_bomb_banner.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/sweeper_settings.dart';
import 'package:sweeper_theme/app_tokens.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _gameStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryStartGame());
  }

  void _tryStartGame() {
    if (_gameStarted || !mounted) return;
    final settings = context.read<SettingsCubit>().state;
    if (!settings.isLoaded) return;
    _gameStarted = true;
    context.read<GameCubit>().startGame(
          config: GameConfig.fromGridSize(settings.gridSize),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) => curr.isLoaded && !prev.isLoaded,
      listener: (context, settings) => _tryStartGame(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          if (!settings.isLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return _GameBody(onOpenSettings: _openSettings);
        },
      ),
    );
  }

  Future<void> _openSettings(GameCubit gameCubit) async {
    final sessionEnded = await showGameMenuSheet(
      context,
      gameCubit: gameCubit,
    );
    if (!mounted) return;
    if (sessionEnded == true) return;
    gameCubit.resume();
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({required this.onOpenSettings});

  final Future<void> Function(GameCubit gameCubit) onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listenWhen: (prev, curr) =>
          (curr.status == GameStatus.gameOver &&
              prev.status != GameStatus.gameOver) ||
          (curr.errorMessage != null &&
              curr.errorMessage != prev.errorMessage),
      listener: (context, state) {
        if (state.status == GameStatus.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.go(GameNavigation.gameOver, extra: state.discoveredCount);
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('connectionError'.tr()),
              action: SnackBarAction(
                label: 'retry'.tr(),
                onPressed: () =>
                    context.read<GameCubit>().retryConnection(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final snapshot = state.snapshot;
        final cubit = context.read<GameCubit>();
        final isPaused = state.status == GameStatus.paused;

        return Scaffold(
          body: SafeArea(
            child: snapshot == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GameHeader(
                              isPaused: isPaused,
                              onPauseToggle: () {
                                if (isPaused) {
                                  cubit.resume();
                                } else {
                                  cubit.pause(reason: PauseReason.manual);
                                }
                              },
                              onReset: () {
                                final gridSize = context
                                    .read<SettingsCubit>()
                                    .state
                                    .gridSize;
                                cubit.restart(
                                  config: GameConfig.fromGridSize(gridSize),
                                );
                              },
                              onSettings: () => onOpenSettings(cubit),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            GameStatsGrid(state: state),
                            const SizedBox(height: AppSpacing.lg),
                            BoardGrid(
                              board: snapshot.board,
                              snapBackGeneration: state.snapBackGeneration,
                              snapBackCell: state.snapBackCell,
                              explosionAt: state.explosionAt,
                              magicBombAt: state.magicBombAt,
                              magicBombGeneration: state.magicBombGeneration,
                              isInteractive: state.isInteractive,
                              onMovePiece: ({
                                required fromRow,
                                required fromCol,
                                required toRow,
                                required toCol,
                              }) {
                                cubit.movePiece(
                                  fromRow: fromRow,
                                  fromCol: fromCol,
                                  toRow: toRow,
                                  toCol: toCol,
                                );
                              },
                              onInvalidDrop: ({
                                required fromRow,
                                required fromCol,
                              }) {
                                cubit.onInvalidDrop(
                                  fromRow: fromRow,
                                  fromCol: fromCol,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: Text(
                                'footerHint'.tr(),
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                      if (state.showPauseOverlay)
                        Positioned.fill(
                          child: GamePauseOverlay(onResume: cubit.resume),
                        ),
                      if (state.magicBombBannerWholeDollars != null)
                        Positioned(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: MagicBombBanner(
                              key: ValueKey(state.magicBombBannerGeneration),
                              generation: state.magicBombBannerGeneration,
                              message: AppText.calloutCaps(
                                'magicBombBanner'.tr(
                                  namedArgs: {
                                    'price': formatWholeDollars(
                                      state.magicBombBannerWholeDollars!,
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
