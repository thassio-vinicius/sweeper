import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper/features/game/domain/entities/game_config.dart';
import 'package:sweeper/features/game/domain/entities/game_entities.dart';
import 'package:sweeper/features/game/domain/entities/game_events.dart';
import 'package:sweeper/features/game/domain/services/game_engine.dart';

void _openMagicBombSlot(GameEngine engine) {
  engine.onTimerTick();
}

void main() {
  group('BtcPrice', () {
    test('landedOnDivisibleWhole detects landing on whole dollars ending in 0 or 5', () {
      expect(BtcPrice.landedOnDivisibleWhole(null, 67455), isNull);
      expect(BtcPrice.landedOnDivisibleWhole(67455, 67455), isNull);
      expect(BtcPrice.landedOnDivisibleWhole(67454, 67455), 67455);
      expect(BtcPrice.landedOnDivisibleWhole(67450, 67455), 67455);
      expect(BtcPrice.landedOnDivisibleWhole(67455, 67456), isNull);
      expect(BtcPrice.landedOnDivisibleWhole(67455, 67460), 67460);
      expect(BtcPrice.landedOnDivisibleWhole(97660, 97665), 97665);
      expect(BtcPrice.landedOnDivisibleWhole(97662, 97668), isNull);
    });

    test('wholeDollars matches UI rounding', () {
      expect(BtcPrice.wholeDollars(77665.4), 77665);
      expect(BtcPrice.wholeDollars(77665.6), 77666);
      expect(BtcPrice.wholeDollars(77665.6) % 5, isNot(0));
    });
  });

  group('GameEngine', () {
    late GameEngine engine;
    const config = GameConfig(
      gridSize: 10,
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

    test('magic bomb not added when displayed price is not divisible by 5', () {
      engine.initialize();
      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 77664, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 77665.6, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(BtcPrice.wholeDollars(77665.6) % 5, isNot(0));
    });

    test('magic bomb added when displayed price lands on divisible by 5', () {
      engine.initialize();
      _openMagicBombSlot(engine);
      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 77664, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 77665.4, receivedAt: DateTime.now()),
      );

      expect(result.events, contains(isA<MagicBombAddedEvent>()));
      final event = result.events.whereType<MagicBombAddedEvent>().first;
      expect(event.triggerWholeDollars, 77665);
      expect(event.triggerWholeDollars % 5, 0);
    });

    test('magic bomb not added when price jump skips divisible landing', () {
      engine.initialize();
      _openMagicBombSlot(engine);
      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 97662, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 97668, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(BtcPrice.wholeDollars(97668) % 5, isNot(0));
    });

    test('magic bomb added when BTC lands on divisible by 5', () {
      engine.initialize();
      _openMagicBombSlot(engine);
      final before = engine.snapshot.board.hiddenBombCount;

      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(result.events, contains(isA<MagicBombAddedEvent>()));
      expect(result.snapshot.board.hiddenBombCount, before + 1);
      expect(result.snapshot.lastMagicBombTriggerPrice, 67455);
    });

    test('magic bomb added when landing on another divisible price', () {
      engine.initialize();
      _openMagicBombSlot(engine);
      final before = engine.snapshot.board.hiddenBombCount;

      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67450, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67460, receivedAt: DateTime.now()),
      );

      expect(result.events, contains(isA<MagicBombAddedEvent>()));
      expect(result.snapshot.board.hiddenBombCount, before + 1);
      expect(result.snapshot.lastMagicBombTriggerPrice, 67460);
    });

    test('magic bomb not added when remaining bombs at cap', () {
      engine.initialize();
      expect(engine.snapshot.board.hiddenBombCount, config.initialBombCount);

      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(result.snapshot.board.hiddenBombCount, config.initialBombCount);
    });

    test('magic bomb cap follows initial bomb count for 8x8', () {
      final smallEngine = GameEngine(
        config: const GameConfig(
          gridSize: 8,
          initialBombCount: 8,
          emptyCellBuffer: 8,
        ),
        random: Random(42),
      );
      smallEngine.initialize();
      expect(smallEngine.snapshot.board.hiddenBombCount, 8);

      smallEngine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      final blocked = smallEngine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(blocked.events, isEmpty);
      expect(blocked.snapshot.board.hiddenBombCount, 8);
    });

    test('magic bomb not added on first tick without prior price', () {
      engine.initialize();
      final before = engine.snapshot.board.hiddenBombCount;

      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(result.snapshot.board.hiddenBombCount, before);
    });

    test('magic bomb dedupes same divisible integer', () {
      engine.initialize();
      _openMagicBombSlot(engine);
      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
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

      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67456, receivedAt: DateTime.now()),
      );
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67457, receivedAt: DateTime.now()),
      );

      expect(result.events, isEmpty);
      expect(result.snapshot.board.hiddenBombCount, before);
    });

    test('failed cap does not consume trigger price', () {
      const tightConfig = GameConfig(
        gridSize: 10,
        initialBombCount: 10,
        emptyCellBuffer: 10,
      );
      final tightEngine = GameEngine(config: tightConfig, random: Random(42));
      tightEngine.initialize();

      tightEngine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      final blocked = tightEngine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(blocked.events, isEmpty);
      expect(tightEngine.snapshot.lastMagicBombTriggerPrice, isNull);
    });

    test('magic bomb adds after discoveries when below max bombs', () {
      engine.initialize();
      var discoveries = 0;

      while (discoveries < 3) {
        final board = engine.snapshot.board;
        int? fromR;
        int? fromC;
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

        var moved = false;
        for (var r = 0; r < config.gridSize; r++) {
          for (var c = 0; c < config.gridSize; c++) {
            if (engine.snapshot.board.cellAt(r, c).bombStatus ==
                    BombStatus.hidden &&
                engine.snapshot.board.cellAt(r, c).piece == null) {
              engine.movePiece(
                fromRow: fromR!,
                fromCol: fromC!,
                toRow: r,
                toCol: c,
              );
              discoveries++;
              moved = true;
              break;
            }
          }
          if (moved) break;
        }
        expect(moved, isTrue);
      }

      expect(engine.snapshot.board.hiddenBombCount, 7);

      engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67454, receivedAt: DateTime.now()),
      );
      final before = engine.snapshot.board.hiddenBombCount;
      final result = engine.onBtcPriceUpdate(
        BtcPrice(priceUsd: 67455, receivedAt: DateTime.now()),
      );

      expect(result.events, contains(isA<MagicBombAddedEvent>()));
      expect(result.snapshot.board.hiddenBombCount, before + 1);
    });

    test('game over when all bombs discovered or exploded', () {
      engine = GameEngine(
        config: const GameConfig(
          gridSize: 4,
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
