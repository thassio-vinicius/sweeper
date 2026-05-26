import 'dart:math';

import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/domain/entities/game_events.dart';
import 'package:sweeper_game/domain/services/board_initializer.dart';
import 'package:sweeper_game/domain/services/cell_grid_clone.dart';

/// Pure Dart game rules engine — no Flutter imports.
///
/// Kept as a single orchestrator: every public method mutates one [GameSnapshot]
/// and returns events. Splitting further would scatter snapshot lifecycle across
/// types without reducing complexity — board setup lives in [BoardInitializer].
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
    _snapshot = BoardInitializer.createInitialSnapshot(
      config: _config,
      random: _random,
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

    final cells = cloneCellGrid(_snapshot!.board.cells);
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
    final cells = cloneCellGrid(_snapshot!.board.cells);
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

    final newWhole = price.wholeDollarPrice;
    final prevWhole = _snapshot!.lastSeenBtcIntegerPrice;

    _snapshot = _snapshot!.copyWith(lastSeenBtcIntegerPrice: newWhole);

    final triggerWhole = BtcPrice.landedOnDivisibleWhole(prevWhole, newWhole);
    if (triggerWhole == null) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    if (_snapshot!.lastMagicBombTriggerPrice == triggerWhole) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    if (_snapshot!.board.hiddenBombCount >= _config.initialBombCount) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    final emptyCells = _snapshot!.board.emptyCellsForBomb;
    if (emptyCells.isEmpty) {
      return GameEngineResult(snapshot: _snapshot!);
    }

    final target = emptyCells[_random.nextInt(emptyCells.length)];
    final cells = cloneCellGrid(_snapshot!.board.cells);
    cells[target.row][target.col] = cells[target.row][target.col].copyWith(
      bombStatus: BombStatus.hidden,
    );

    _snapshot = _snapshot!.copyWith(
      board: Board(cells: cells, gridSize: _config.gridSize),
      lastMagicBombTriggerPrice: triggerWhole,
    );

    return _finalize([
      MagicBombAddedEvent(target.row, target.col, triggerWhole),
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
}
