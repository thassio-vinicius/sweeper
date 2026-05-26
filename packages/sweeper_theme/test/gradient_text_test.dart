import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_theme/app_tokens.dart';
import 'package:sweeper_theme/widgets/gradient_text.dart';

void main() {
  testWidgets('GradientText renders descenders for Portuguese headline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientText(
              text: 'Fim de jogo',
              style: AppTypography.displayHeadline,
              gradient: AppGradients.gradientHeadline,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Fim de jogo'), findsOneWidget);
    final text = tester.widget<Text>(find.text('Fim de jogo'));
    expect(text.style?.foreground?.shader, isNotNull);
  });
}
