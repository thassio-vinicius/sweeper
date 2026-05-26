import 'package:equatable/equatable.dart';
import 'package:sweeper_game/domain/entities/board.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';
import 'package:sweeper_game/domain/entities/game_phase.dart';

class GameSnapshot extends Equatable {
  const GameSnapshot({
    required this.board,
    required this.discoveredBombCount,
    required this.explodedBombCount,
    required this.phase,
    required this.config,
    this.lastMagicBombTriggerPrice,
    this.lastSeenBtcIntegerPrice,
    this.secondsUntilNextBlast,
  });

  final Board board;
  final int discoveredBombCount;
  final int explodedBombCount;
  final GamePhase phase;
  final GameConfig config;
  final int? lastMagicBombTriggerPrice;
  final int? lastSeenBtcIntegerPrice;
  final int? secondsUntilNextBlast;

  int get remainingHiddenBombs => board.hiddenBombCount;

  GameSnapshot copyWith({
    Board? board,
    int? discoveredBombCount,
    int? explodedBombCount,
    GamePhase? phase,
    int? lastMagicBombTriggerPrice,
    int? lastSeenBtcIntegerPrice,
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
      lastSeenBtcIntegerPrice:
          lastSeenBtcIntegerPrice ?? this.lastSeenBtcIntegerPrice,
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
        lastSeenBtcIntegerPrice,
        secondsUntilNextBlast,
      ];
}
