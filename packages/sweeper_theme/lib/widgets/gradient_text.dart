import 'package:flutter/material.dart';

/// Gradient-filled text that keeps descenders (e.g. g, j, p, y) fully shaded.
///
/// [ShaderMask] with a tight [TextStyle.height] clips letter tails; this widget
/// sizes the shader from [TextPainter] metrics and leaves room for descenders.
class GradientText extends StatelessWidget {
  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  static TextStyle _withDescenderHeight(TextStyle style) {
    final height = style.height;
    if (height == null || height < 1.1) {
      return style.copyWith(height: 1.15);
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = _withDescenderHeight(style);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;

        final painter = TextPainter(
          text: TextSpan(text: text, style: baseStyle),
          textAlign: textAlign ?? TextAlign.start,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: maxLines,
        )..layout(maxWidth: maxWidth);

        final shaderRect =
            Rect.fromLTWH(0, 0, painter.width, painter.height);

        final glowShadows = style.shadows;
        final gradientStyle = baseStyle.copyWith(
          foreground: Paint()..shader = gradient.createShader(shaderRect),
          color: null,
          shadows: null,
        );

        return SizedBox(
          width: painter.width,
          height: painter.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (glowShadows != null && glowShadows.isNotEmpty)
                Text(
                  text,
                  textAlign: textAlign,
                  maxLines: maxLines,
                  overflow: overflow,
                  style: baseStyle.copyWith(
                    color: Colors.transparent,
                    shadows: glowShadows,
                  ),
                ),
              Text(
                text,
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
                style: gradientStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
