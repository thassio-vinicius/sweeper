import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_colors.dart';

/// Single shared piece design — glowing cyan token (PDF: same design for all).
class PieceVisual extends StatelessWidget {
  const PieceVisual({
    super.key,
    required this.size,
    this.glowing = false,
  });

  final double size;
  final bool glowing;

  static const color = AppColors.pieceCyan;
  static const symbol = '◆';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: size * 0.42,
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
