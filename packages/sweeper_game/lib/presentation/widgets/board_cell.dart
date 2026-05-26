import 'package:flutter/material.dart';
import 'package:sweeper_game/domain/entities/board_drag_data.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/cell.dart';
import 'package:sweeper_theme/app_colors.dart';
import 'package:sweeper_theme/app_spacing.dart';
import 'package:sweeper_game/presentation/widgets/snap_back_draggable_piece.dart';

class BoardCell extends StatelessWidget {
  const BoardCell({
    super.key,
    required this.cell,
    required this.pieceSize,
    required this.snapBackGeneration,
    required this.snapBackCell,
    required this.onDrop,
    required this.onInvalidDrop,
    required this.isInteractive,
  });

  final Cell cell;
  final double pieceSize;
  final int snapBackGeneration;
  final ({int row, int col})? snapBackCell;
  final void Function(BoardDragData data, int toRow, int toCol) onDrop;
  final void Function(int fromRow, int fromCol) onInvalidDrop;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) {
    final isScorched =
        cell.bombStatus == BombStatus.exploded && cell.piece == null;

    return DragTarget<BoardDragData>(
      onWillAcceptWithDetails: (details) {
        if (!isInteractive) return false;
        final data = details.data;
        if (data.fromRow == cell.row && data.fromCol == cell.col) return false;
        if (cell.piece != null && cell.piece!.id != data.piece.id) return false;
        return true;
      },
      onAcceptWithDetails: (details) {
        onDrop(details.data, cell.row, cell.col);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        final isRejectedTarget = rejectedData.isNotEmpty;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cellRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isRejectedTarget
                  ? AppColors.coralRed.withValues(alpha: 0.12)
                  : isHighlighted
                      ? AppColors.cyan.withValues(alpha: 0.15)
                      : isScorched
                          ? AppColors.coralRed.withValues(alpha: 0.08)
                          : AppColors.cellEmpty,
              borderRadius: BorderRadius.circular(AppSpacing.cellRadius),
              border: Border.all(
                color: isRejectedTarget
                    ? AppColors.coralRed.withValues(alpha: 0.4)
                    : isHighlighted
                        ? AppColors.cyan.withValues(alpha: 0.5)
                        : isScorched
                            ? AppColors.coralRed.withValues(alpha: 0.25)
                            : AppColors.cellBorder,
              ),
            ),
            child: cell.piece != null
                ? Center(
                    child: SnapBackDraggablePiece(
                      dragData: BoardDragData(
                        piece: cell.piece!,
                        fromRow: cell.row,
                        fromCol: cell.col,
                      ),
                      pieceSize: pieceSize,
                      snapBackGeneration: snapBackGeneration,
                      shouldSnapBack: snapBackCell != null &&
                          snapBackCell!.row == cell.row &&
                          snapBackCell!.col == cell.col,
                      onDragRejected: () =>
                          onInvalidDrop(cell.row, cell.col),
                      enabled: isInteractive,
                    ),
                  )
                : isScorched
                    ? Center(
                        child: Icon(
                          Icons.local_fire_department,
                          size: pieceSize * 0.55,
                          color: AppColors.coralRed.withValues(alpha: 0.5),
                        ),
                      )
                    : null,
          ),
        );
      },
    );
  }
}
