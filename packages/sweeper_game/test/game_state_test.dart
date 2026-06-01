import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';
import 'package:sweeper_game/presentation/cubit/pause_reason.dart';

GameSnapshot _snapshot({int discovered = 2}) {
  final board = Board(
    gridSize: 2,
    cells: [
      [
        const Cell(row: 0, col: 0, bombStatus: BombStatus.hidden),
        const Cell(row: 0, col: 1, bombStatus: BombStatus.hidden),
      ],
      [
        const Cell(row: 1, col: 0, bombStatus: BombStatus.hidden),
        const Cell(row: 1, col: 1),
      ],
    ],
  );
  return GameSnapshot(
    board: board,
    discoveredBombCount: discovered,
    explodedBombCount: 0,
    phase: GamePhase.playing,
    config: const GameConfig(gridSize: 2),
    secondsUntilNextBlast: 7,
  );
}

void main() {
  test('isInteractive is true only while playing', () {
    expect(const GameState(status: GameStatus.playing).isInteractive, isTrue);
    expect(const GameState(status: GameStatus.paused).isInteractive, isFalse);
  });

  test('showPauseOverlay requires manual pause', () {
    expect(
      const GameState(status: GameStatus.paused, pauseReason: PauseReason.manual)
          .showPauseOverlay,
      isTrue,
    );
    expect(
      const GameState(status: GameStatus.paused, pauseReason: PauseReason.none)
          .showPauseOverlay,
      isFalse,
    );
  });

  test('derived counts read from snapshot with defaults', () {
    const empty = GameState();
    expect(empty.discoveredCount, 0);
    expect(empty.remainingCount, 0);
    expect(empty.secondsUntilBlast, 10);

    final withSnapshot = GameState(snapshot: _snapshot());
    expect(withSnapshot.discoveredCount, 2);
    expect(withSnapshot.remainingCount, 3);
    expect(withSnapshot.secondsUntilBlast, 7);
  });
}
