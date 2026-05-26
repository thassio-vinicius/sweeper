import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

/// Single shared piece design — glowing cyan token (PDF: same design for all).
class PieceVisual extends StatelessWidget {
  const PieceVisual({
    super.key,
    required this.size,
    this.glowing = false,
  });

  final double size;
  final bool glowing;

  static const color = AppColors.piece;

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
                  blurRadius: AppBlur.lg,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          AppGlyphs.piece,
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
