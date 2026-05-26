import 'dart:math';

import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/cell.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_phase.dart';
import 'package:sweeper_game/domain/entities/game_snapshot.dart';
import 'package:sweeper_game/domain/entities/piece.dart';
import 'package:sweeper_game/domain/entities/board.dart';

/// Builds the initial board layout — bombs, pieces, and starting snapshot.
class BoardInitializer {
  const BoardInitializer._();

  static GameSnapshot createInitialSnapshot({
    required GameConfig config,
    required Random random,
  }) {
    final gridSize = config.gridSize;
    final cells = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => Cell(row: row, col: col),
      ),
    );

    final allPositions = <({int row, int col})>[];
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        allPositions.add((row: r, col: c));
      }
    }
    allPositions.shuffle(random);

    final bombCount = config.initialBombCount;
    final bombPositions = allPositions.take(bombCount).toList();

    for (final pos in bombPositions) {
      cells[pos.row][pos.col] = cells[pos.row][pos.col]
          .copyWith(bombStatus: BombStatus.hidden);
    }

    final pieceCount = config.initialPieces.clamp(0, gridSize * gridSize);
    final availableForPieces = allPositions
        .skip(bombCount)
        .where((p) => cells[p.row][p.col].piece == null)
        .take(pieceCount)
        .toList();

    for (var i = 0; i < availableForPieces.length; i++) {
      final pos = availableForPieces[i];
      cells[pos.row][pos.col] = cells[pos.row][pos.col].copyWith(
        piece: Piece(id: 'piece_$i'),
      );
    }

    return GameSnapshot(
      board: Board(cells: cells, gridSize: gridSize),
      discoveredBombCount: 0,
      explodedBombCount: 0,
      phase: GamePhase.playing,
      config: config,
      secondsUntilNextBlast: config.tickInterval.inSeconds,
    );
  }
}
