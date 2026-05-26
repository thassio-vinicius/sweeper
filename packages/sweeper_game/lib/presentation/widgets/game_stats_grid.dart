import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';
import 'package:sweeper_game/presentation/widgets/game_hud.dart';

class GameStatsGrid extends StatelessWidget {
  const GameStatsGrid({
    super.key,
    required this.state,
  });

  final GameState state;

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
          label: 'discovered'.tr(),
          icon: Icons.gps_fixed,
          value: '${state.discoveredCount}',
          valueColor: AppColors.springGreen,
        ),
        StatCard(
          label: 'remaining'.tr(),
          icon: Icons.warning_amber_rounded,
          value: '${state.remainingCount}',
          valueColor: AppColors.coralRed,
          pulseGeneration: state.remainingPulseGeneration,
        ),
        StatCard(
          label: 'btcLive'.tr(),
          icon: Icons.currency_bitcoin,
          value: formatBtcPrice(state.btcPrice?.priceUsd),
          valueColor: AppColors.sun,
          subValue: state.btcPrice != null
              ? AppGlyphs.trendIndicator(btcDirection)
              : null,
          subValueColor: btcDirection < 0
              ? AppColors.coralRed
              : AppColors.springGreen,
        ),
        StatCard(
          label: 'nextBlast'.tr(),
          icon: Icons.timer_outlined,
          value: formatTimer(state.secondsUntilBlast),
          valueColor: AppColors.cyan,
        ),
      ],
    );
  }
}
