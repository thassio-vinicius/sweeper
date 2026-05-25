import 'package:flutter/material.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/features/game/domain/entities/game_entities.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.valueColor,
    this.subValue,
    this.subValueColor,
    this.pulseGeneration = 0,
  });

  final String label;
  final IconData icon;
  final String value;
  final Color valueColor;
  final String? subValue;
  final Color? subValueColor;
  final int pulseGeneration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: valueColor.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: valueColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 9,
                        height: 1.1,
                      ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: _PulsingValue(
                        key: ValueKey(pulseGeneration),
                        value: value,
                        valueColor: valueColor,
                        pulseGeneration: pulseGeneration,
                      ),
                    ),
                    if (subValue != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        subValue!,
                        style: TextStyle(
                          fontSize: 10,
                          color: subValueColor ?? AppColors.springGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingValue extends StatefulWidget {
  const _PulsingValue({
    super.key,
    required this.value,
    required this.valueColor,
    required this.pulseGeneration,
  });

  final String value;
  final Color valueColor;
  final int pulseGeneration;

  @override
  State<_PulsingValue> createState() => _PulsingValueState();
}

class _PulsingValueState extends State<_PulsingValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.45), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 1), weight: 65),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_PulsingValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseGeneration != oldWidget.pulseGeneration &&
        widget.pulseGeneration > 0) {
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
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: Text(
        widget.value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: widget.valueColor,
          shadows: [
            Shadow(
              color: widget.valueColor.withValues(alpha: 0.5),
              blurRadius: 8 * _scale.value,
            ),
          ],
        ),
      ),
    );
  }
}

String formatWholeDollars(int wholeDollars) {
  return '\$${wholeDollars.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';
}

String formatBtcPrice(double? price) {
  if (price == null) return '--';
  return formatWholeDollars(BtcPrice.wholeDollars(price));
}

String formatTimer(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
