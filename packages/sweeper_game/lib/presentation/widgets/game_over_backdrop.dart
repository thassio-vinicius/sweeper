import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

class GameOverBackdrop extends StatefulWidget {
  const GameOverBackdrop({super.key});

  @override
  State<GameOverBackdrop> createState() => _GameOverBackdropState();
}

class _GameOverBackdropState extends State<GameOverBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final drift = _controller.value;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    Color(0xFF0A1628),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -60 + drift * 20,
              right: -40,
              child: _GlowOrb(
                color: AppColors.springGreen,
                size: AppSizes.glowOrbLg,
                strength: 0.35 + drift * 0.15,
              ),
            ),
            Positioned(
              bottom: 120 - drift * 24,
              left: -70,
              child: _GlowOrb(
                color: AppColors.coralRed,
                size: AppSizes.glowOrbMd,
                strength: 0.28 + drift * 0.12,
              ),
            ),
            Positioned(
              bottom: -10 + drift * 16,
              right: 24,
              child: _GlowOrb(
                color: AppColors.cyan,
                size: AppSizes.glowOrbSm,
                strength: 0.22 + drift * 0.1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.strength,
  });

  final Color color;
  final double size;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
