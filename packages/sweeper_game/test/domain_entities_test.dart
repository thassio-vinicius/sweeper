import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/domain/entities/board.dart';
import 'package:sweeper_game/domain/entities/board_drag_data.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/btc_price.dart';
import 'package:sweeper_game/domain/entities/cell.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_events.dart';
import 'package:sweeper_game/domain/entities/game_phase.dart';
import 'package:sweeper_game/domain/entities/game_snapshot.dart';
import 'package:sweeper_game/domain/entities/piece.dart';

void main() {
  group('BoardDragData', () {
    test('equality uses piece and coordinates', () {
      const piece = Piece(id: 'p1');
      const a = BoardDragData(piece: piece, fromRow: 1, fromCol: 2);
      const b = BoardDragData(piece: piece, fromRow: 1, fromCol: 2);
      const c = BoardDragData(piece: piece, fromRow: 0, fromCol: 2);

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('Cell', () {
    test('hasHiddenBomb is true only for hidden bombs', () {
      const hidden = Cell(row: 0, col: 0, bombStatus: BombStatus.hidden);
      const discovered = Cell(row: 0, col: 0, bombStatus: BombStatus.discovered);

      expect(hidden.hasHiddenBomb, isTrue);
      expect(discovered.hasHiddenBomb, isFalse);
    });

    test('copyWith can clear piece', () {
      const cell = Cell(row: 0, col: 0, piece: Piece(id: 'p1'));
      expect(cell.copyWith(clearPiece: true).piece, isNull);
    });
  });

  group('BtcPrice', () {
    test('instance getters mirror whole-dollar rounding', () {
      final price = BtcPrice(priceUsd: 67455.4, receivedAt: DateTime(2024));

      expect(price.wholeDollarPrice, 67455);
      expect(price.integerPrice, 67455);
      expect(price.isDivisibleByFive, isTrue);
    });

    test('equality includes price and timestamp', () {
      final t = DateTime(2024, 1, 1);
      final a = BtcPrice(priceUsd: 1, receivedAt: t);
      final b = BtcPrice(priceUsd: 1, receivedAt: t);
      final c = BtcPrice(priceUsd: 2, receivedAt: t);

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('GameEvent', () {
    test('subtypes expose props for value equality', () {
      expect(const BombDiscoveredEvent(1, 2), const BombDiscoveredEvent(1, 2));
      expect(const BombExplodedEvent(1, 2), isNot(const BombExplodedEvent(2, 2)));
      expect(
        const MagicBombAddedEvent(0, 0, 67455),
        const MagicBombAddedEvent(0, 0, 67455),
      );
      expect(const InvalidMoveEvent(), const InvalidMoveEvent());
      expect(const GameOverEvent(3), const GameOverEvent(3));
    });

    test('GameEngineResult compares snapshot and events', () {
      const config = GameConfig(gridSize: 4);
      final board = Board(
        gridSize: 4,
        cells: List.generate(
          4,
          (row) => List.generate(4, (col) => Cell(row: row, col: col)),
        ),
      );
      final snapshot = GameSnapshot(
        board: board,
        discoveredBombCount: 0,
        explodedBombCount: 0,
        phase: GamePhase.playing,
        config: config,
      );
      final result = GameEngineResult(
        snapshot: snapshot,
        events: const [InvalidMoveEvent()],
      );

      expect(result, GameEngineResult(snapshot: snapshot, events: const [InvalidMoveEvent()]));
    });
  });

  group('GameConfig', () {
    test('copyWith updates tickInterval and props include all fields', () {
      const config = GameConfig(tickInterval: Duration(seconds: 5));
      final updated = config.copyWith(tickInterval: const Duration(seconds: 15));

      expect(updated.tickInterval, const Duration(seconds: 15));
      expect(updated, config.copyWith(tickInterval: const Duration(seconds: 15)));
      expect(updated, isNot(config));
    });
  });

  group('GameSnapshot', () {
    test('remainingHiddenBombs delegates to board', () {
      final board = Board(
        gridSize: 2,
        cells: [
          [
            const Cell(row: 0, col: 0, bombStatus: BombStatus.hidden),
            const Cell(row: 0, col: 1),
          ],
          [
            const Cell(row: 1, col: 0, bombStatus: BombStatus.hidden),
            const Cell(row: 1, col: 1, bombStatus: BombStatus.discovered),
          ],
        ],
      );
      final snapshot = GameSnapshot(
        board: board,
        discoveredBombCount: 1,
        explodedBombCount: 0,
        phase: GamePhase.playing,
        config: const GameConfig(gridSize: 2),
      );

      expect(snapshot.remainingHiddenBombs, 2);
    });
  });
}
