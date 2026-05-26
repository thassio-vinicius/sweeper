import 'package:equatable/equatable.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/cell.dart';

class Board extends Equatable {
  const Board({required this.cells, required this.gridSize});

  final List<List<Cell>> cells;
  final int gridSize;

  Cell cellAt(int row, int col) => cells[row][col];

  List<Cell> get hiddenBombCells => cells
      .expand((row) => row)
      .where((c) => c.bombStatus == BombStatus.hidden)
      .toList();

  List<Cell> get emptyCellsForBomb => cells
      .expand((row) => row)
      .where(
        (c) =>
            (c.bombStatus == BombStatus.none ||
                c.bombStatus == BombStatus.exploded) &&
            c.piece == null,
      )
      .toList();

  int get hiddenBombCount => hiddenBombCells.length;

  @override
  List<Object?> get props => [cells, gridSize];
}
