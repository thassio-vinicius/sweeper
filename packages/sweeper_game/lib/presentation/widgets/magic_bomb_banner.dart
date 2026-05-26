import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

class MagicBombBanner extends StatefulWidget {
  const MagicBombBanner({
    super.key,
    required this.message,
    required this.generation,
  });

  final String message;
  final int generation;

  @override
  State<MagicBombBanner> createState() => _MagicBombBannerState();
}

class _MagicBombBannerState extends State<MagicBombBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.22, curve: Curves.easeOutBack),
      ),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 0),
        weight: 30,
      ),
    ]).animate(_controller);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.05),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1),
        weight: 80,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(MagicBombBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.generation != oldWidget.generation) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: SlideTransition(
              position: _slide,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.sun.withValues(alpha: 0.95),
                  AppColors.coralRed.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.sun, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sun.withValues(alpha: 0.45),
                  blurRadius: AppBlur.xl4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt,
                  color: AppColors.background,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    widget.message,
                    style: AppTypography.emphasisLabel.copyWith(
                      color: AppColors.background,
                    ),
                    textAlign: TextAlign.center,
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