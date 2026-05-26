import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_colors.dart';

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
