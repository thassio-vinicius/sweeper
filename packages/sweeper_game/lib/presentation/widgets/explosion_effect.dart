import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

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
                      blurRadius: AppBlur.xl3 * _scale.value,
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
