import 'package:equatable/equatable.dart';

class GameConfig extends Equatable {
  const GameConfig({
    this.gridSize = 10,
    this.maxBombs = 10,
    this.initialBombCount = 10,
    this.emptyCellBuffer = 10,
    this.tickInterval = const Duration(seconds: 10),
  });

  final int gridSize;
  final int maxBombs;
  final int initialBombCount;
  final int emptyCellBuffer;
  final Duration tickInterval;

  int get totalCells => gridSize * gridSize;

  int get initialPieces =>
      totalCells - initialBombCount - emptyCellBuffer;

  GameConfig copyWith({
    int? gridSize,
    int? maxBombs,
    int? initialBombCount,
    int? emptyCellBuffer,
    Duration? tickInterval,
  }) {
    return GameConfig(
      gridSize: gridSize ?? this.gridSize,
      maxBombs: maxBombs ?? this.maxBombs,
      initialBombCount: initialBombCount ?? this.initialBombCount,
      emptyCellBuffer: emptyCellBuffer ?? this.emptyCellBuffer,
      tickInterval: tickInterval ?? this.tickInterval,
    );
  }

  @override
  List<Object?> get props =>
      [gridSize, maxBombs, initialBombCount, emptyCellBuffer, tickInterval];
}
