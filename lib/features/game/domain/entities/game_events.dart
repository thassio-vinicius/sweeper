import 'package:equatable/equatable.dart';
import 'package:sweeper/features/game/domain/entities/game_entities.dart';

/// Side effects emitted by [GameEngine] for the presentation layer.
sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class BombDiscoveredEvent extends GameEvent {
  const BombDiscoveredEvent(this.row, this.col);

  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];
}

final class BombExplodedEvent extends GameEvent {
  const BombExplodedEvent(this.row, this.col);

  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];
}

final class MagicBombAddedEvent extends GameEvent {
  const MagicBombAddedEvent(this.row, this.col, this.triggerWholeDollars);

  final int row;
  final int col;
  final int triggerWholeDollars;

  @override
  List<Object?> get props => [row, col, triggerWholeDollars];
}

final class InvalidMoveEvent extends GameEvent {
  const InvalidMoveEvent();
}

final class GameOverEvent extends GameEvent {
  const GameOverEvent(this.discoveredCount);

  final int discoveredCount;

  @override
  List<Object?> get props => [discoveredCount];
}

class GameEngineResult extends Equatable {
  const GameEngineResult({
    required this.snapshot,
    this.events = const [],
  });

  final GameSnapshot snapshot;
  final List<GameEvent> events;

  @override
  List<Object?> get props => [snapshot, events];
}
