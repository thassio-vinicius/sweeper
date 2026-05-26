import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sweeper_game/navigation/game_navigation.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/widgets/game_over_animation.dart';
import 'package:sweeper_game/presentation/widgets/game_over_backdrop.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_settings/sweeper_settings.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage({super.key, required this.discoveredCount});

  final int discoveredCount;

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.45, 1, curve: Curves.easeOutCubic),
      ),
    );
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const GameOverBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  FadeTransition(
                    opacity: _titleFade,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          AppGradients.gradientHeadline.createShader(bounds),
                      child: Text(
                        'gameOverTitle'.tr(),
                        style: AppTypography.displayHeadline.copyWith(
                          shadows: AppShadows.titleTextGlow,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GameOverAnimation(
                    discoveredCount: widget.discoveredCount,
                    label: 'discoveredBombs'.plural(widget.discoveredCount),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            final config = GameConfig.fromGridSize(
                              context.read<SettingsCubit>().state.gridSize,
                            );
                            context.read<GameCubit>().restart(config: config);
                            context.go(GameNavigation.home);
                          },
                          style: AppButtons.filledCyan,
                          child: Text('playAgain'.tr()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
