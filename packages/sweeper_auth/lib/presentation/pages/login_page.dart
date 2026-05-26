import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_auth/presentation/cubit/auth_cubit.dart';
import 'package:sweeper_auth/presentation/widgets/google_sign_in_button.dart';
import 'package:sweeper_auth/presentation/widgets/login_board_preview.dart';
import 'package:sweeper_auth/presentation/widgets/login_hero.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackdrop(),
          SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (prev, curr) =>
                  curr.error != null && curr.error != prev.error,
              listener: (context, state) {
                if (state.error == null) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              },
              builder: (context, auth) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GameTitleHero(
                              board: const LoginBoardPreview(gridSize: 3),
                            ),
                            _LoginActions(auth: auth),
                            const LoginFeatureGuide(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginActions extends StatelessWidget {
  const _LoginActions({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoogleSignInButton(
          isLoading: auth.isLoading,
          onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
        ),
        if (auth.guestModeAvailable) ...[
          const SizedBox(height: AppSpacing.sm),
          GuestPlayButton(
            onPressed: auth.isLoading
                ? null
                : () => context.read<AuthCubit>().enterGuestMode(),
          ),
        ],
      ],
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(color: AppColors.cyan, size: AppSizes.glowOrbLg),
        ),
        Positioned(
          bottom: 80,
          left: -70,
          child: _GlowOrb(color: AppColors.coralRed, size: AppSizes.glowOrbMd),
        ),
        Positioned(
          bottom: -20,
          right: 20,
          child: _GlowOrb(color: AppColors.sun, size: AppSizes.glowOrbSm),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.backdropOrb(color),
      ),
    );
  }
}
