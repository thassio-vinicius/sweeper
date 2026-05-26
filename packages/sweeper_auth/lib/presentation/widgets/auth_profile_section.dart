import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/app_buttons.dart';
import 'package:sweeper_theme/widgets/game_surface_card.dart';
import 'package:sweeper_auth/domain/entities/auth_user.dart';

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('account'.tr(), style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        GameSurfaceCard(
          accentColor: AppColors.springGreen,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarSm / 2 + AppSpacing.xs,
                    backgroundColor: AppColors.background,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                          )
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
                            fontWeight: AppTypography.fontWeightSemibold,
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
                          width: AppSizes.iconLg - 4,
                          height: AppSizes.iconLg - 4,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.logout, size: AppSizes.iconMd),
                  label: Text('signOut'.tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
