import 'package:equatable/equatable.dart';
import 'package:sweeper/features/game/domain/entities/game_config.dart';

enum BombStatus { none, hidden, discovered, exploded }

enum GamePhase { playing, gameOver }

/// All pieces share the same design per PDF spec.
class Piece extends Equatable {
  const Piece({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class Cell extends Equatable {
  const Cell({
    required this.row,
    required this.col,
    this.piece,
    this.bombStatus = BombStatus.none,
  });

  final int row;
  final int col;
  final Piece? piece;
  final BombStatus bombStatus;

  bool get hasHiddenBomb => bombStatus == BombStatus.hidden;

  Cell copyWith({
    Piece? piece,
    BombStatus? bombStatus,
    bool clearPiece = false,
  }) {
    return Cell(
      row: row,
      col: col,
      piece: clearPiece ? null : (piece ?? this.piece),
      bombStatus: bombStatus ?? this.bombStatus,
    );
  }

  @override
  List<Object?> get props => [row, col, piece, bombStatus];
}

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

class GameSnapshot extends Equatable {
  const GameSnapshot({
    required this.board,
    required this.discoveredBombCount,
    required this.explodedBombCount,
    required this.phase,
    required this.config,
    this.lastMagicBombTriggerPrice,
    this.secondsUntilNextBlast,
  });

  final Board board;
  final int discoveredBombCount;
  final int explodedBombCount;
  final GamePhase phase;
  final GameConfig config;
  final int? lastMagicBombTriggerPrice;
  final int? secondsUntilNextBlast;

  int get remainingHiddenBombs => board.hiddenBombCount;

  GameSnapshot copyWith({
    Board? board,
    int? discoveredBombCount,
    int? explodedBombCount,
    GamePhase? phase,
    int? lastMagicBombTriggerPrice,
    int? secondsUntilNextBlast,
  }) {
    return GameSnapshot(
      board: board ?? this.board,
      discoveredBombCount: discoveredBombCount ?? this.discoveredBombCount,
      explodedBombCount: explodedBombCount ?? this.explodedBombCount,
      phase: phase ?? this.phase,
      config: config,
      lastMagicBombTriggerPrice:
          lastMagicBombTriggerPrice ?? this.lastMagicBombTriggerPrice,
      secondsUntilNextBlast:
          secondsUntilNextBlast ?? this.secondsUntilNextBlast,
    );
  }

  @override
  List<Object?> get props => [
        board,
        discoveredBombCount,
        explodedBombCount,
        phase,
        config,
        lastMagicBombTriggerPrice,
        secondsUntilNextBlast,
      ];
}

class BtcPrice extends Equatable {
  const BtcPrice({required this.priceUsd, required this.receivedAt});

  final double priceUsd;
  final DateTime receivedAt;

  int get integerPrice => priceUsd.floor();

  bool get isDivisibleByFive => integerPrice % 5 == 0;

  @override
  List<Object?> get props => [priceUsd, receivedAt];
}

/// Payload for board drag-and-drop — always includes source cell.
class BoardDragData extends Equatable {
  const BoardDragData({
    required this.piece,
    required this.fromRow,
    required this.fromCol,
  });

  final Piece piece;
  final int fromRow;
  final int fromCol;

  @override
  List<Object?> get props => [piece, fromRow, fromCol];
}
