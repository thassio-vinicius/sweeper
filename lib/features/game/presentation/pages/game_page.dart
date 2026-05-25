import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper/features/game/presentation/cubit/game_cubit.dart';
import 'package:sweeper/features/game/presentation/cubit/game_state.dart';
import 'package:sweeper/features/game/presentation/widgets/board_grid.dart';
import 'package:sweeper/features/game/presentation/widgets/game_hud.dart';
import 'package:sweeper/features/settings/presentation/cubit/settings_cubit.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsCubit>().state;
      context.read<GameCubit>().startGame(config: settings.toGameConfig());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            context.push('/game-over', extra: state.discoveredCount);
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.connectionError),
              action: SnackBarAction(
                label: l10n.retry,
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
                            _Header(
                              isPaused: isPaused,
                              onPauseToggle: () {
                                if (isPaused) {
                                  cubit.resume();
                                } else {
                                  cubit.pause();
                                }
                              },
                              onReset: () {
                                final config = context
                                    .read<SettingsCubit>()
                                    .state
                                    .toGameConfig();
                                cubit.restart(config: config);
                              },
                              onSettings: () => _showSettings(context),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _StatsGrid(state: state, l10n: l10n),
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
                                l10n.footerHint,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                      if (isPaused)
                        Positioned.fill(
                          child: ColoredBox(
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
                                    style:
                                        Theme.of(context).textTheme.headlineLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  FilledButton.icon(
                                    onPressed: cubit.resume,
                                    icon: const Icon(Icons.play_arrow),
                                    label: Text(l10n.resume),
                                  ),
                                ],
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

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gameCubit = context.read<GameCubit>();
    gameCubit.pause();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.boardSize,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: SettingsState.availableSizes.map((size) {
                      final selected = settings.gridSize == size;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text('${size}x$size'),
                          selected: selected,
                          onSelected: (_) {
                            context.read<SettingsCubit>().setGridSize(size);
                            final config = context
                                .read<SettingsCubit>()
                                .state
                                .toGameConfig();
                            context.read<GameCubit>().restart(config: config);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, auth) {
                      if (!auth.isAvailable) {
                        return const SizedBox.shrink();
                      }
                      if (auth.user != null) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: auth.user!.photoUrl != null
                                ? NetworkImage(auth.user!.photoUrl!)
                                : null,
                            child: auth.user!.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            auth.user!.displayName ??
                                auth.user!.email ??
                                '',
                          ),
                          trailing: TextButton(
                            onPressed: () =>
                                context.read<AuthCubit>().signOut(),
                            child: Text(l10n.signOut),
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: auth.isLoading
                              ? null
                              : () => context
                                  .read<AuthCubit>()
                                  .signInWithGoogle(),
                          icon: auth.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(l10n.signInWithGoogle),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (context.mounted) {
        gameCubit.resume();
      }
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.state, required this.l10n});

  final GameState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final btcDirection = state.btcPriceDirection;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 3.0,
      children: [
        StatCard(
          label: l10n.discovered,
          icon: Icons.gps_fixed,
          value: '${state.discoveredCount}',
          valueColor: AppColors.springGreen,
        ),
        StatCard(
          label: l10n.remaining,
          icon: Icons.warning_amber_rounded,
          value: '${state.remainingCount}',
          valueColor: AppColors.coralRed,
        ),
        StatCard(
          label: l10n.btcLive,
          icon: Icons.currency_bitcoin,
          value: formatBtcPrice(state.btcPrice?.priceUsd),
          valueColor: AppColors.sun,
          subValue: state.btcPrice != null
              ? (btcDirection < 0 ? '▼' : '▲')
              : null,
          subValueColor: btcDirection < 0
              ? AppColors.coralRed
              : AppColors.springGreen,
        ),
        StatCard(
          label: l10n.nextBlast,
          icon: Icons.timer_outlined,
          value: formatTimer(state.secondsUntilBlast),
          valueColor: AppColors.cyan,
        ),
      ],
    );
  }
}
