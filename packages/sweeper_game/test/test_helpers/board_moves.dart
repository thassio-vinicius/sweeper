import 'package:sweeper_game/domain/entities/game_entities.dart';

typedef MoveCoords = ({int fromRow, int fromCol, int toRow, int toCol});

MoveCoords? findSafeMove(GameSnapshot snapshot) {
  final board = snapshot.board;
  final gridSize = board.gridSize;

  for (var row = 0; row < gridSize; row++) {
    for (var col = 0; col < gridSize; col++) {
      final fromCell = board.cellAt(row, col);
      if (fromCell.piece == null) continue;

      for (final (dRow, dCol) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final toRow = row + dRow;
        final toCol = col + dCol;
        if (toRow < 0 ||
            toRow >= gridSize ||
            toCol < 0 ||
            toCol >= gridSize) {
          continue;
        }

        final toCell = board.cellAt(toRow, toCol);
        if (toCell.piece == null && toCell.bombStatus != BombStatus.hidden) {
          return (
            fromRow: row,
            fromCol: col,
            toRow: toRow,
            toCol: toCol,
          );
        }
      }
    }
  }

  return null;
}

MoveCoords? findHiddenBombMove(GameSnapshot snapshot) {
  final board = snapshot.board;
  final gridSize = board.gridSize;

  for (var row = 0; row < gridSize; row++) {
    for (var col = 0; col < gridSize; col++) {
      final fromCell = board.cellAt(row, col);
      if (fromCell.piece == null) continue;

      for (final (dRow, dCol) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final toRow = row + dRow;
        final toCol = col + dCol;
        if (toRow < 0 ||
            toRow >= gridSize ||
            toCol < 0 ||
            toCol >= gridSize) {
          continue;
        }

        final toCell = board.cellAt(toRow, toCol);
        if (toCell.piece == null &&
            toCell.bombStatus == BombStatus.hidden) {
          return (
            fromRow: row,
            fromCol: col,
            toRow: toRow,
            toCol: toCol,
          );
        }
      }
    }
  }

  return null;
}
