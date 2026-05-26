import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

/// Hero animation for the game-over screen — radial bursts, glow, and score reveal.
class GameOverAnimation extends StatefulWidget {
  const GameOverAnimation({
    super.key,
    required this.discoveredCount,
    required this.label,
  });

  final int discoveredCount;
  final String label;

  @override
  State<GameOverAnimation> createState() => _GameOverAnimationState();
}

class _GameOverAnimationState extends State<GameOverAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _sequence;
  late final AnimationController _pulse;
  late final Animation<double> _burst;
  late final Animation<double> _iconScale;
  late final Animation<double> _countScale;
  late final Animation<double> _labelOpacity;
  late final Animation<double> _badgeSlide;

  @override
  void initState() {
    super.initState();
    _sequence = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _burst = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
    );
    _iconScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sequence,
        curve: const Interval(0.08, 0.45, curve: Curves.elasticOut),
      ),
    );
    _countScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sequence,
        curve: const Interval(0.28, 0.62, curve: Curves.easeOutBack),
      ),
    );
    _labelOpacity = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _badgeSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _sequence,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _sequence.forward();
  }

  @override
  void dispose() {
    _sequence.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sequence, _pulse]),
      builder: (context, child) {
        final glow = 0.55 + _pulse.value * 0.45;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              height: 168,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(280, 168),
                    painter: _BurstRingPainter(progress: _burst.value),
                  ),
                  ..._sparkOffsets().map(
                    (offset) => _Spark(
                      offset: offset,
                      progress: _burst.value,
                      angle: offset.direction,
                    ),
                  ),
                  Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.titleIconGlow(
                          AppColors.springGreen,
                        ),
                        boxShadow: AppShadows.titleIcon(
                          accent: AppColors.springGreen,
                        ),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.springGreen,
                        size: AppSizes.iconXl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Transform.translate(
              offset: Offset(0, _badgeSlide.value),
              child: Opacity(
                opacity: _countScale.value.clamp(0, 1),
                child: Transform.scale(
                  scale: _countScale.value,
                  child: Text(
                    '${widget.discoveredCount}',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      foreground: Paint()
                        ..shader = AppGradients.gradientHeadline.createShader(
                          const Rect.fromLTWH(0, 0, 120, 72),
                        ),
                      shadows: [
                        Shadow(
                          color: AppColors.springGreen
                              .withValues(alpha: 0.75 * glow),
                          blurRadius: AppBlur.xl3,
                        ),
                        Shadow(
                          color: AppColors.cyan.withValues(alpha: 0.35 * glow),
                          blurRadius: AppBlur.xl5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Transform.translate(
              offset: Offset(0, _badgeSlide.value * 0.5),
              child: Opacity(
                opacity: _labelOpacity.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    border: Border.all(
                      color: AppColors.springGreen.withValues(alpha: 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.springGreen.withValues(alpha: 0.2),
                        blurRadius: AppBlur.xl,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyFeature.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Offset> _sparkOffsets() {
    const count = 12;
    const radius = 72.0;
    return List.generate(count, (index) {
      final angle = (index / count) * math.pi * 2 - math.pi / 2;
      return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    });
  }
}

class _Spark extends StatelessWidget {
  const _Spark({
    required this.offset,
    required this.progress,
    required this.angle,
  });

  final Offset offset;
  final double progress;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final travel = Curves.easeOut.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    return Transform.translate(
      offset: offset * travel,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 10,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  AppColors.sun,
                  AppColors.springGreen.withValues(alpha: 0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sun.withValues(alpha: 0.6 * opacity),
                  blurRadius: AppBlur.xs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstRingPainter extends CustomPainter {
  const _BurstRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rings = [
      (color: AppColors.coralRed, delay: 0.0, maxScale: 1.15),
      (color: AppColors.sun, delay: 0.12, maxScale: 1.35),
      (color: AppColors.springGreen, delay: 0.22, maxScale: 1.55),
      (color: AppColors.cyan, delay: 0.32, maxScale: 1.75),
    ];

    for (final ring in rings) {
      final t = ((progress - ring.delay) / (1 - ring.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final radius = size.shortestSide * 0.28 * ring.maxScale * t;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t * 0.6)
        ..color = ring.color.withValues(alpha: (1 - t) * 0.85);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
