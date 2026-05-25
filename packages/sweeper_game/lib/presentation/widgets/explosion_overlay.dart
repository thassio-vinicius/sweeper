import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_colors.dart';

/// Explosion effect — must be a direct child of a [Stack] (returns [Positioned]).
class ExplosionEffect extends StatefulWidget {
  const ExplosionEffect({
    super.key,
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  @override
  State<ExplosionEffect> createState() => _ExplosionEffectState();
}

class _ExplosionEffectState extends State<ExplosionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.2, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final diameter = widget.size * _scale.value;
          return Opacity(
            opacity: _opacity.value,
            child: Transform.rotate(
              angle: _controller.value * math.pi,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.sun,
                      AppColors.coralRed,
                      AppColors.radicalRed.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coralRed.withValues(alpha: 0.8),
                      blurRadius: 20 * _scale.value,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white.withValues(alpha: _opacity.value),
                  size: diameter * 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pulse when a magic bomb spawns from a BTC price divisible by 5.
class MagicBombPulse extends StatefulWidget {
  const MagicBombPulse({
    super.key,
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  @override
  State<MagicBombPulse> createState() => _MagicBombPulseState();
}

class _MagicBombPulseState extends State<MagicBombPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_controller.value);
          final scale = 0.4 + t * 0.9;
          return Opacity(
            opacity: 1 - t,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sun, width: 3),
                  color: AppColors.sun.withValues(alpha: 0.25),
                ),
                child: Icon(
                  Icons.bolt,
                  color: AppColors.sun,
                  size: widget.size * 0.45,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _countScale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _glow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _countScale.value,
              child: Text(
                '${widget.discoveredCount}',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: AppColors.springGreen,
                  shadows: [
                    Shadow(
                      color: AppColors.springGreen
                          .withValues(alpha: 0.6 * _glow.value),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: _glow.value,
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
