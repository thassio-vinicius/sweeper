import 'package:flutter/material.dart';
import 'package:sweeper_game/domain/entities/board.dart';
import 'package:sweeper_game/presentation/cubit/game_state.dart';
import 'package:sweeper_game/presentation/widgets/board_cell.dart';
import 'package:sweeper_game/presentation/widgets/explosion_effect.dart';
import 'package:sweeper_game/presentation/widgets/magic_bomb_pulse.dart';
import 'package:sweeper_game/presentation/widgets/sliding_piece_overlay.dart';

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.board,
    required this.snapBackGeneration,
    required this.snapBackCell,
    required this.onMovePiece,
    required this.onInvalidDrop,
    this.explosionAt,
    this.magicBombAt,
    this.magicBombGeneration = 0,
    this.slideMove,
    this.slideGeneration = 0,
    this.isInteractive = true,
  });

  final Board board;
  final int snapBackGeneration;
  final ({int row, int col})? snapBackCell;
  final void Function({
    required int fromRow,
    required int fromCol,
    required int toRow,
    required int toCol,
  }) onMovePiece;
  final void Function({required int fromRow, required int fromCol})
      onInvalidDrop;
  final ({int row, int col})? explosionAt;
  final ({int row, int col})? magicBombAt;
  final int magicBombGeneration;
  final BoardMove? slideMove;
  final int slideGeneration;
  final bool isInteractive;

  Offset _cellTopLeft(int row, int col, double cellSize, double gap) {
    return Offset(col * (cellSize + gap), row * (cellSize + gap));
  }

  bool _hidePieceForSlide(int row, int col) {
    if (slideMove == null) return false;
    return (row == slideMove!.fromRow && col == slideMove!.fromCol) ||
        (row == slideMove!.toRow && col == slideMove!.toCol);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final gridSize = board.gridSize;
        final cellSize =
            (constraints.maxWidth - gap * (gridSize - 1)) / gridSize;
        final pieceSize = cellSize * 0.62;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ gridSize;
                final col = index % gridSize;
                final cell = board.cellAt(row, col);

                return BoardCell(
                  cell: cell,
                  pieceSize: pieceSize,
                  snapBackGeneration: snapBackGeneration,
                  snapBackCell: snapBackCell,
                  hidePiece: _hidePieceForSlide(row, col),
                  isInteractive: isInteractive,
                  onDrop: (data, toRow, toCol) {
                    onMovePiece(
                      fromRow: data.fromRow,
                      fromCol: data.fromCol,
                      toRow: toRow,
                      toCol: toCol,
                    );
                  },
                  onInvalidDrop: (fromRow, fromCol) {
                    onInvalidDrop(fromRow: fromRow, fromCol: fromCol);
                  },
                );
              },
            ),
            if (slideMove != null)
              SlidingPieceOverlay(
                key: ValueKey(slideGeneration),
                fromRow: slideMove!.fromRow,
                fromCol: slideMove!.fromCol,
                toRow: slideMove!.toRow,
                toCol: slideMove!.toCol,
                cellSize: cellSize,
                gap: gap,
                pieceSize: pieceSize,
                generation: slideGeneration,
              ),
            if (explosionAt != null)
              Builder(
                builder: (context) {
                  final pos = _cellTopLeft(
                    explosionAt!.row,
                    explosionAt!.col,
                    cellSize,
                    gap,
                  );
                  final effectSize = cellSize * 0.85;
                  return ExplosionEffect(
                    left: pos.dx + cellSize / 2 - effectSize / 2,
                    top: pos.dy + cellSize / 2 - effectSize / 2,
                    size: effectSize,
                  );
                },
              ),
            if (magicBombAt != null)
              Builder(
                builder: (context) {
                  final pos = _cellTopLeft(
                    magicBombAt!.row,
                    magicBombAt!.col,
                    cellSize,
                    gap,
                  );
                  final pulseSize = cellSize * 0.75;
                  return MagicBombPulse(
                    key: ValueKey(magicBombGeneration),
                    left: pos.dx + cellSize / 2 - pulseSize / 2,
                    top: pos.dy + cellSize / 2 - pulseSize / 2,
                    size: pulseSize,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
