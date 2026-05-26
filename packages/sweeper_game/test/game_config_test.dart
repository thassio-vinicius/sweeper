import 'package:flutter_test/flutter_test.dart';
import 'package:sweeper_game/domain/entities/game_config.dart';

void main() {
  test('fromGridSize maps board sizes to bomb counts', () {
    expect(GameConfig.fromGridSize(8).initialBombCount, 8);
    expect(GameConfig.fromGridSize(10).initialBombCount, 10);
    expect(GameConfig.fromGridSize(12).initialBombCount, 12);
    expect(GameConfig.fromGridSize(99).initialBombCount, 10);
  });

  test('fromGridSize sets empty cell buffer to grid size', () {
    expect(GameConfig.fromGridSize(8).emptyCellBuffer, 8);
    expect(GameConfig.fromGridSize(12).emptyCellBuffer, 12);
  });

  test('derived counts', () {
    const config = GameConfig(gridSize: 10, initialBombCount: 10, emptyCellBuffer: 10);
    expect(config.totalCells, 100);
    expect(config.initialPieces, 80);
    expect(config.maxBombs, 10);
    expect(GameConfig.supportedGridSizes, [8, 10, 12]);
  });

  test('copyWith preserves unspecified fields', () {
    const config = GameConfig(gridSize: 10);
    expect(config.copyWith(gridSize: 12).gridSize, 12);
    expect(config.copyWith(gridSize: 12).initialBombCount, 10);
  });
}
