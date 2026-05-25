import 'package:flutter/material.dart';
import 'package:sweeper/core/l10n/app_localizations.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/core/widgets/google_logo.dart';

/// Standard white Google sign-in button with the multi-color G logo.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  static const _background = Color(0xFFFFFFFF);
  static const _foreground = Color(0xFF1F1F1F);
  static const _border = Color(0xFF747775);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = !isLoading && onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? _background : _background.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _foreground,
                    ),
                  )
                else
                  const GoogleLogo(size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(
                  l10n.signInWithGoogle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _foreground,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
