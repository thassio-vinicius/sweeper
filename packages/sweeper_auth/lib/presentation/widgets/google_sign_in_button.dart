import 'package:flutter/material.dart';
import 'package:sweeper_l10n/sweeper_l10n.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/google_logo.dart';

/// Standard white Google sign-in button with the official logo asset.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = !isLoading && onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          height: AppSizes.buttonHeightLg,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.googleSignInBackground
                : AppColors.googleSignInBackground
                    .withValues(alpha: AppOpacity.disabled),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.googleSignInBorder),
            boxShadow: AppShadows.googleSignIn(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: AppSizes.iconLg,
                    height: AppSizes.iconLg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.googleSignInForeground
                          .withValues(alpha: AppOpacity.disabled),
                    ),
                  )
                else
                  const GoogleLogo(),
                const SizedBox(width: AppSpacing.md),
                Text(
                  l10n.signInWithGoogle,
                  style: AppTypography.googleSignInLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
