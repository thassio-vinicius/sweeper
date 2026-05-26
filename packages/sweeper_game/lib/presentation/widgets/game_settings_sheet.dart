import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/presentation/widgets/auth_profile_section.dart';
import 'package:sweeper_auth/presentation/widgets/guest_session_section.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/presentation/cubit/game_cubit.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';
import 'package:sweeper_settings/sweeper_settings.dart';
import 'package:sweeper_theme/app_tokens.dart';

Future<bool?> showGameSettingsSheet(
  BuildContext context, {
  required GameCubit gameCubit,
}) {
  gameCubit.pause(reason: PauseReason.settings);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'settings'.tr(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'boardSize'.tr(),
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
                        onSelected: (_) async {
                          await context.read<SettingsCubit>().setGridSize(size);
                          if (!sheetContext.mounted) return;
                          final config = GameConfig.fromGridSize(size);
                          await context.read<GameCubit>().restart(config: config);
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'language'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AppLocales.supportedLanguageCodes.map((code) {
                    final selected = settings.languageCode == code;
                    return ChoiceChip(
                      label: Text(AppLocales.displayName(code)),
                      selected: selected,
                      onSelected: (_) async {
                        await context
                            .read<SettingsCubit>()
                            .setLanguageCode(code);
                        if (!sheetContext.mounted) return;
                        await sheetContext.setLocale(AppLocales.localeFor(code));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, auth) {
                    if (auth.isGuest) {
                      return GuestSessionSection(
                        isLoading: auth.isLoading,
                        isEndingSession: auth.isSigningOut,
                        onSignIn: auth.isLoading
                            ? null
                            : () => context
                                .read<AuthCubit>()
                                .signInWithGoogle(),
                        onEndGuestSession: auth.isSigningOut
                            ? null
                            : () => _endSessionFromSettings(
                                  context: context,
                                  sheetContext: sheetContext,
                                  gameCubit: gameCubit,
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
                          : () => _endSessionFromSettings(
                                context: context,
                                sheetContext: sheetContext,
                                gameCubit: gameCubit,
                              ),
                    );
                  },
                ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _endSessionFromSettings({
  required BuildContext context,
  required BuildContext sheetContext,
  required GameCubit gameCubit,
}) async {
  Navigator.of(sheetContext).pop(true);
  await gameCubit.stopGame();
  if (!context.mounted) return;
  await context.read<AuthCubit>().signOut();
}
