import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/presentation/widgets/auth_profile_section.dart';
import 'package:sweeper_auth/presentation/widgets/guest_session_section.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';
import 'package:sweeper_settings/presentation/widgets/settings_sheet.dart';

/// Opens the in-game menu: settings preferences plus account actions.
Future<bool?> showGameMenuSheet(
  BuildContext context, {
  required GameCubit gameCubit,
}) {
  gameCubit.pause(reason: PauseReason.settings);

  return showSettingsSheet<bool>(
    context,
    footer: _GameMenuAuthFooter(gameCubit: gameCubit),
    onGridSizeSelected: (sheetContext, size) async {
      await gameCubit.restart(config: GameConfig.fromGridSize(size));
      if (!sheetContext.mounted) return;
      Navigator.pop(sheetContext);
    },
  );
}

class _GameMenuAuthFooter extends StatelessWidget {
  const _GameMenuAuthFooter({required this.gameCubit});

  final GameCubit gameCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        if (auth.isGuest) {
          return GuestSessionSection(
            isLoading: auth.isLoading,
            isEndingSession: auth.isSigningOut,
            onSignIn: auth.isLoading
                ? null
                : () => context.read<AuthCubit>().signInWithGoogle(),
            onEndGuestSession: auth.isSigningOut
                ? null
                : () => _endSession(
                      context: context,
                      sheetContext: context,
                    ),
          );
        }
        if (auth.user == null) {
          return const SizedBox.shrink();
        }
        return AuthProfileSection(
          user: auth.user!,
          isSigningOut: auth.isSigningOut,
          onSignOut: auth.isSigningOut
              ? null
              : () => _endSession(
                    context: context,
                    sheetContext: context,
                  ),
        );
      },
    );
  }

  Future<void> _endSession({
    required BuildContext context,
    required BuildContext sheetContext,
  }) async {
    Navigator.of(sheetContext).pop(true);
    await gameCubit.stopGame();
    if (!context.mounted) return;
    await context.read<AuthCubit>().signOut();
  }
}
