import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/domain/entities/board.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/cell.dart';

Board _board(List<List<Cell>> cells) => Board(cells: cells, gridSize: 2);

void main() {
  test('hiddenBombCells and emptyCellsForBomb', () {
    final board = _board([
      [
        const Cell(row: 0, col: 0, bombStatus: BombStatus.hidden),
        const Cell(row: 0, col: 1, bombStatus: BombStatus.discovered),
      ],
      [
        const Cell(row: 1, col: 0, bombStatus: BombStatus.exploded),
        const Cell(row: 1, col: 1),
      ],
    ]);

    expect(board.hiddenBombCount, 1);
    expect(board.emptyCellsForBomb.length, 2);
    expect(board.cellAt(0, 1).bombStatus, BombStatus.discovered);
  });
}
