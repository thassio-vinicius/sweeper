import 'dart:math';

import 'package:sweeper/features/game/domain/entities/game_config.dart';
import 'package:sweeper/features/game/domain/entities/game_entities.dart';
import 'package:sweeper/features/game/domain/entities/game_events.dart';

/// Pure Dart game rules engine — no Flutter imports.
class GameEngine {
  GameEngine({
    required GameConfig config,
    Random? random,
  })  : _config = config,
        _random = random ?? Random();

  final GameConfig _config;
  final Random _random;

  GameSnapshot? _snapshot;

  GameSnapshot get snapshot {
    if (_snapshot == null) {
      throw StateError('GameEngine not initialized. Call initialize() first.');
    }
    return _snapshot!;
  }

  GameEngineResult initialize() {
    final gridSize = _config.gridSize;
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
    allPositions.shuffle(_random);

    var bombCount = _config.initialBombCount.clamp(0, _config.maxBombs);
    final bombPositions = allPositions.take(bombCount).toList();

    for (final pos in bombPositions) {
      cells[pos.row][pos.col] = cells[pos.row][pos.col]
          .copyWith(bombStatus: BombStatus.hidden);
    }

    final pieceCount = _config.initialPieces.clamp(0, gridSize * gridSize);
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

    _snapshot = GameSnapshot(
      board: Board(cells: cells, gridSize: gridSize),
      discoveredBombCount: 0,
      explodedBombCount: 0,
      phase: GamePhase.playing,
      config: _config,
      secondsUntilNextBlast: _config.tickInterval.inSeconds,
    );

    return GameEngineResult(snapshot: _snapshot!);
  }

  GameEngineResult restart({GameConfig? config}) {
    if (config != null) {
      return GameEngine(config: config, random: _random).initialize();
    }
    return GameEngine(config: _config, random: _random).initialize();
  }

  /// Move a piece from [fromRow,fromCol] to [toRow,toCol].
  GameEngineResult movePiece({
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) {
    _ensurePlaying();
    if (fromRow == toRow && fromCol == toCol) {
      return GameEngineResult(
        snapshot: _snapshot!,
        events: const [InvalidMoveEvent()],
      );
    }

    final fromCell = _snapshot!.board.cellAt(fromRow, fromCol);
    final toCell = _snapshot!.board.cellAt(toRow, toCol);

    if (fromCell.piece == null) {
      return GameEngineResult(
        snapshot: _snapshot!,
        events: const [InvalidMoveEvent()],
      );
    }

    if (toCell.piece != null) {
      return GameEngineResult(
        snapshot: _snapshot!,
        events: const [InvalidMoveEvent()],
      );
    }

    final cells = _deepCopyCells(_snapshot!.board.cells);
    final piece = fromCell.piece!;

    cells[fromRow][fromCol] = cells[fromRow][fromCol].copyWith(clearPiece: true);

    var discovered = _snapshot!.discoveredBombCount;
    final events = <GameEvent>[];

    if (toCell.bombStatus == BombStatus.hidden) {
      cells[toRow][toCol] = cells[toRow][toCol].copyWith(
        piece: piece,
        bombStatus: BombStatus.discovered,
      );
      discovered++;
      events.add(BombDiscoveredEvent(toRow, toCol));
    } else {
      cells[toRow][toCol] = cells[toRow][toCol].copyWith(piece: piece);
    }

    _snapshot = _snapshot!.copyWith(
      board: Board(cells: cells, gridSize: _config.gridSize),
      discoveredBombCount: discovered,
    );

    return _finalize(events);
  }

  GameEngineResult onTimerTick() {
    if (_snapshot == null) {
      throw StateError('GameEngine not initialized.');
    }
    if (_snapshot!.phase == GamePhase.gameOver) {
      return GameEngineResult(snapshot: _snapshot!);
    }
    final hidden = _snapshot!.board.hiddenBombCells;
    if (hidden.isEmpty) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    final target = hidden[_random.nextInt(hidden.length)];
    final cells = _deepCopyCells(_snapshot!.board.cells);
    cells[target.row][target.col] = cells[target.row][target.col].copyWith(
      bombStatus: BombStatus.exploded,
      clearPiece: cells[target.row][target.col].piece != null,
    );

    _snapshot = _snapshot!.copyWith(
      board: Board(cells: cells, gridSize: _config.gridSize),
      explodedBombCount: _snapshot!.explodedBombCount + 1,
      secondsUntilNextBlast: _config.tickInterval.inSeconds,
    );

    return _finalize([BombExplodedEvent(target.row, target.col)]);
  }

  GameEngineResult updateCountdown(int secondsRemaining) {
    if (_snapshot == null) {
      throw StateError('GameEngine not initialized.');
    }
    if (_snapshot!.phase == GamePhase.gameOver) {
      return GameEngineResult(snapshot: _snapshot!);
    }
    _snapshot = _snapshot!.copyWith(secondsUntilNextBlast: secondsRemaining);
    return GameEngineResult(snapshot: _snapshot!);
  }

  GameEngineResult onBtcPriceUpdate(BtcPrice price) {
    if (_snapshot == null) {
      throw StateError('GameEngine not initialized.');
    }
    if (_snapshot!.phase == GamePhase.gameOver) {
      return GameEngineResult(snapshot: _snapshot!);
    }
    if (!price.isDivisibleByFive) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    if (_snapshot!.lastMagicBombTriggerPrice == price.integerPrice) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    final currentHidden = _snapshot!.board.hiddenBombCount;
    final totalActive = _snapshot!.discoveredBombCount +
        _snapshot!.explodedBombCount +
        currentHidden;

    if (totalActive >= _config.maxBombs) {
      _snapshot = _snapshot!.copyWith(
        lastMagicBombTriggerPrice: price.integerPrice,
      );
      return GameEngineResult(snapshot: _snapshot!);
    }

    final emptyCells = _snapshot!.board.emptyCellsForBomb;
    if (emptyCells.isEmpty) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    final target = emptyCells[_random.nextInt(emptyCells.length)];
    final cells = _deepCopyCells(_snapshot!.board.cells);
    cells[target.row][target.col] = cells[target.row][target.col].copyWith(
      bombStatus: BombStatus.hidden,
    );

    _snapshot = _snapshot!.copyWith(
      board: Board(cells: cells, gridSize: _config.gridSize),
      lastMagicBombTriggerPrice: price.integerPrice,
    );

    return _finalize([
      MagicBombAddedEvent(target.row, target.col, price.integerPrice),
    ]);
  }

  void _ensurePlaying() {
    if (_snapshot == null) {
      throw StateError('GameEngine not initialized.');
    }
    if (_snapshot!.phase == GamePhase.gameOver) {
      throw StateError('Game is over.');
    }
  }

  GameEngineResult _finalize(List<GameEvent> events) {
    if (_snapshot!.board.hiddenBombCount == 0) {
      _snapshot = _snapshot!.copyWith(phase: GamePhase.gameOver);
      events = [
        ...events,
        GameOverEvent(_snapshot!.discoveredBombCount),
      ];
    }
    return GameEngineResult(snapshot: _snapshot!, events: events);
  }

  List<List<Cell>> _deepCopyCells(List<List<Cell>> source) {
    return source
        .map((row) => row.map((cell) {
              return Cell(
                row: cell.row,
                col: cell.col,
                piece: cell.piece,
                bombStatus: cell.bombStatus,
              );
            }).toList())
        .toList();
  }
}
