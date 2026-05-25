import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';
import 'package:sweeper_theme/widgets/game_surface_card.dart';
import 'package:sweeper_auth/presentation/widgets/google_sign_in_button.dart';

class GuestSessionSection extends StatelessWidget {
  const GuestSessionSection({
    super.key,
    required this.onSignIn,
    required this.onEndGuestSession,
    this.isLoading = false,
    this.isEndingSession = false,
  });

  final VoidCallback? onSignIn;
  final VoidCallback? onEndGuestSession;
  final bool isLoading;
  final bool isEndingSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.account, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        GameSurfaceCard(
          accentColor: AppColors.sun,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.avatarMd,
                    height: AppSizes.avatarMd,
                    decoration: BoxDecoration(
                      color: AppColors.sun
                          .withValues(alpha: AppOpacity.accentTintSoft),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: AppColors.sun
                            .withValues(alpha: AppOpacity.magicCellGlow),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.sun,
                      size: AppSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.guestModeTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: AppTypography.fontWeightSemibold,
                          ),
                        ),
                        Text(
                          l10n.guestModeHint,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              GoogleSignInButton(
                isLoading: isLoading,
                onPressed: onSignIn,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isEndingSession ? null : onEndGuestSession,
                  style: AppButtons.signOut,
                  child: Text(l10n.endGuestSession),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
