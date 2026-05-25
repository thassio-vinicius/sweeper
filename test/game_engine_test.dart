import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper/features/game/domain/entities/game_config.dart';
import 'package:sweeper/features/game/domain/entities/game_entities.dart';
import 'package:sweeper/features/game/domain/entities/game_events.dart';
import 'package:sweeper/features/game/domain/services/game_engine.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;
    const config = GameConfig(
      gridSize: 10,
      maxBombs: 10,
      initialBombCount: 10,
      emptyCellBuffer: 10,
    );

    setUp(() {
      engine = GameEngine(config: config, random: Random(42));
    });

    test('initialize places bombs and pieces', () {
      final result = engine.initialize();
      final snapshot = result.snapshot;

      expect(snapshot.phase, GamePhase.playing);
      expect(snapshot.discoveredBombCount, 0);
      expect(snapshot.explodedBombCount, 0);

      var hiddenBombs = 0;
      var pieces = 0;
      for (final row in snapshot.board.cells) {
        for (final cell in row) {
          if (cell.bombStatus == BombStatus.hidden) hiddenBombs++;
          if (cell.piece != null) pieces++;
        }
      }
      expect(hiddenBombs, config.initialBombCount);
      expect(pieces, config.initialPieces);
    });

    test('move to occupied cell is invalid', () {
      engine.initialize();
      final board = engine.snapshot.board;

      int? fromR, fromC, toR, toC;
      outer:
      for (var r = 0; r < config.gridSize; r++) {
        for (var c = 0; c < config.gridSize; c++) {
          if (board.cellAt(r, c).piece != null) {
            fromR = r;
            fromC = c;
            break outer;
          }
        }
      }

      for (var r = 0; r < config.gridSize; r++) {
        for (var c = 0; c < config.gridSize; c++) {
          if (board.cellAt(r, c).piece != null &&
              (r != fromR || c != fromC)) {
            toR = r;
            toC = c;
            break;
          }
        }
        if (toR != null) break;
      }

      final result = engine.movePiece(
        fromRow: fromR!,
        fromCol: fromC!,
        toRow: toR!,
        toCol: toC!,
      );

      expect(result.events, contains(isA<InvalidMoveEvent>()));
    });

    test('move onto hidden bomb discovers it', () {
      engine = GameEngine(config: config, random: Random(1));
      engine.initialize();
      final board = engine.snapshot.board;

      int? pieceR, pieceC;
      int? bombR, bombC;

      for (var r = 0; r < config.gridSize; r++) {
        for (var c = 0; c < config.gridSize; c++) {
          final cell = board.cellAt(r, c);
          if (cell.piece != null && pieceR == null) {
            pieceR = r;
            pieceC = c;
          }
          if (cell.bombStatus == BombStatus.hidden &&
              cell.piece == null &&
              bombR == null) {
            bombR = r;
            bombC = c;
          }
        }
      }

      if (pieceR == null || bombR == null) return;

      final result = engine.movePiece(
        fromRow: pieceR,
        fromCol: pieceC!,
        toRow: bombR,
        toCol: bombC!,
      );

      expect(result.events, contains(isA<BombDiscoveredEvent>()));
      expect(result.snapshot.discoveredBombCount, 1);
      expect(
        result.snapshot.board.cellAt(bombR, bombC).bombStatus,
        BombStatus.discovered,
      );
      expect(result.snapshot.board.cellAt(bombR, bombC).piece, isNotNull);
    });

    test('timer tick explodes a random hidden bomb', () {
      engine.initialize();
      final before = engine.snapshot.board.hiddenBombCount;

      final result = engine.onTimerTick();

      expect(result.events, contains(isA<BombExplodedEvent>()));
      expect(result.snapshot.explodedBombCount, 1);
      expect(result.snapshot.board.hiddenBombCount, before - 1);
    });

    test('magic bomb added when BTC price divisible by 5', () {
      engine.initialize();
      final before = engine.snapshot.board.hiddenBombCount;

      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(result.events, contains(isA<MagicBombAddedEvent>()));
      expect(result.snapshot.board.hiddenBombCount, before + 1);
      expect(result.snapshot.lastMagicBombTriggerPrice, 67455);
    });

    test('magic bomb dedupes same price', () {
      engine.initialize();
      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );
      final afterFirst = engine.snapshot.board.hiddenBombCount;

      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455.9, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(result.snapshot.board.hiddenBombCount, afterFirst);
    });

    test('magic bomb not added when price not divisible by 5', () {
      engine.initialize();
      final before = engine.snapshot.board.hiddenBombCount;

      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67457, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(result.snapshot.board.hiddenBombCount, before);
    });

    test('game over when all bombs discovered or exploded', () {
      engine = GameEngine(
        config: const GameConfig(
          gridSize: 4,
          maxBombs: 2,
          initialBombCount: 2,
          emptyCellBuffer: 1,
        ),
        random: Random(0),
      );
      engine.initialize();

      while (engine.snapshot.board.hiddenBombCount > 0) {
        engine.onTimerTick();
      }

      expect(engine.snapshot.phase, GamePhase.gameOver);
    });
  });
}
