import 'package:equatable/equatable.dart';

class GameConfig extends Equatable {
  const GameConfig({
    this.gridSize = 10,
    this.initialBombCount = 10,
    this.emptyCellBuffer = 10,
    this.tickInterval = const Duration(seconds: 10),
  });

  final int gridSize;
  final int initialBombCount;
  final int emptyCellBuffer;
  final Duration tickInterval;

  /// Magic bombs cannot raise remaining bombs above the starting count.
  int get maxBombs => initialBombCount;

  int get totalCells => gridSize * gridSize;

  int get initialPieces =>
      totalCells - initialBombCount - emptyCellBuffer;

  static const supportedGridSizes = [8, 10, 12];

  factory GameConfig.fromGridSize(int gridSize) {
    final bombCount = switch (gridSize) {
      8 => 8,
      12 => 12,
      _ => 10,
    };
    return GameConfig(
      gridSize: gridSize,
      initialBombCount: bombCount,
      emptyCellBuffer: gridSize,
    );
  }

  GameConfig copyWith({
    int? gridSize,
    int? initialBombCount,
    int? emptyCellBuffer,
    Duration? tickInterval,
  }) {
    return GameConfig(
      gridSize: gridSize ?? this.gridSize,
      initialBombCount: initialBombCount ?? this.initialBombCount,
      emptyCellBuffer: emptyCellBuffer ?? this.emptyCellBuffer,
      tickInterval: tickInterval ?? this.tickInterval,
    );
  }

  @override
  List<Object?> get props =>
      [gridSize, initialBombCount, emptyCellBuffer, tickInterval];
}
