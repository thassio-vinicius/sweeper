import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Multi-color Google "G" mark for the sign-in button.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fill = Paint()..style = PaintingStyle.fill;

    fill.color = _blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 4,
      math.pi / 2,
      true,
      fill,
    );

    fill.color = _green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 4,
      math.pi / 2,
      true,
      fill,
    );

    fill.color = _yellow;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * math.pi / 4,
      math.pi / 2,
      true,
      fill,
    );

    fill.color = _red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3 * math.pi / 4,
      math.pi / 2,
      true,
      fill,
    );

    fill.color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, fill);

    fill.color = _blue;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.08, center.dy),
        width: radius * 1.05,
        height: radius * 0.34,
      ),
      fill,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.34, center.dy),
      radius * 0.34,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
