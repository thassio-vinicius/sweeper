import 'package:flutter/material.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/core/widgets/app_buttons.dart';
import 'package:sweeper/core/widgets/game_surface_card.dart';
import 'package:sweeper/features/auth/domain/repositories/auth_repository.dart';

class AuthProfileSection extends StatelessWidget {
  const AuthProfileSection({
    super.key,
    required this.user,
    required this.onSignOut,
    this.isSigningOut = false,
  });

  final AuthUser user;
  final VoidCallback? onSignOut;
  final bool isSigningOut;

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
          accentColor: AppColors.springGreen,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.background,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? user.email ?? '',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (user.displayName != null && user.email != null)
                          Text(
                            user.email!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSigningOut ? null : onSignOut,
                  style: AppButtons.signOut,
                  icon: isSigningOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout, size: 18),
                  label: Text(l10n.signOut),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
