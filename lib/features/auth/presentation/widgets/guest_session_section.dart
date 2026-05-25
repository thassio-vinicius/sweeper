import 'package:flutter/material.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/core/widgets/app_buttons.dart';
import 'package:sweeper/core/widgets/game_surface_card.dart';
import 'package:sweeper/features/auth/presentation/widgets/google_sign_in_button.dart';

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
        Text(
          l10n.account,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        GameSurfaceCard(
          accentColor: AppColors.sun,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.sun.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.cellRadius),
                      border: Border.all(
                        color: AppColors.sun.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.sun,
                      size: 20,
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
                            fontWeight: FontWeight.w600,
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
