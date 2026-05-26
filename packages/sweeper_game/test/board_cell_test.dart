import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/cell.dart';
import 'package:sweeper_game/domain/entities/piece.dart';
import 'package:sweeper_game/presentation/widgets/board_cell.dart';
import 'package:sweeper_theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: SizedBox(
          width: 64,
          height: 64,
          child: child,
        ),
      ),
    );
  }

  BoardCell buildCell(Cell cell) {
    return BoardCell(
      cell: cell,
      pieceSize: 32,
      snapBackGeneration: 0,
      snapBackCell: null,
      isInteractive: true,
      onDrop: (data, toRow, toCol) {},
      onInvalidDrop: (fromRow, fromCol) {},
    );
  }

  testWidgets('discovered bomb cell uses distinct border styling', (tester) async {
    const discoveredCell = Cell(
      row: 0,
      col: 0,
      piece: Piece(id: 'piece_0'),
      bombStatus: BombStatus.discovered,
    );
    const plainCell = Cell(
      row: 0,
      col: 0,
      piece: Piece(id: 'piece_1'),
    );

    await tester.pumpWidget(wrap(buildCell(discoveredCell)));
    final discoveredDecoration =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration
            as BoxDecoration?;

    await tester.pumpWidget(wrap(buildCell(plainCell)));
    final plainDecoration =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration
            as BoxDecoration?;

    expect(discoveredDecoration?.border, isNot(equals(plainDecoration?.border)));
  });

  testWidgets('discovered bomb styling persists after piece leaves', (tester) async {
    const discoveredEmptyCell = Cell(
      row: 0,
      col: 0,
      bombStatus: BombStatus.discovered,
    );

    await tester.pumpWidget(wrap(buildCell(discoveredEmptyCell)));
    final decoration =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration
            as BoxDecoration?;

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(decoration?.border, isNotNull);
  });

  testWidgets('scorched exploded cell shows fire icon', (tester) async {
    const scorchedCell = Cell(
      row: 0,
      col: 0,
      bombStatus: BombStatus.exploded,
    );

    await tester.pumpWidget(wrap(buildCell(scorchedCell)));

    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });
}
