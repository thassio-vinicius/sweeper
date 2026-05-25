import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_colors.dart';
import 'package:sweeper_theme/app_spacing.dart';
import 'package:sweeper_game/domain/entities/game_entities.dart';
import 'package:sweeper_game/presentation/widgets/explosion_overlay.dart';

/// Single shared piece design — glowing cyan token (PDF: same design for all).
class PieceVisual extends StatelessWidget {
  const PieceVisual({
    super.key,
    required this.size,
    this.glowing = false,
  });

  final double size;
  final bool glowing;

  static const color = AppColors.pieceCyan;
  static const symbol = '◆';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: size * 0.42,
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SnapBackDraggablePiece extends StatefulWidget {
  const SnapBackDraggablePiece({
    super.key,
    required this.dragData,
    required this.pieceSize,
    required this.snapBackGeneration,
    required this.shouldSnapBack,
    required this.onDragRejected,
    required this.enabled,
  });

  final BoardDragData dragData;
  final double pieceSize;
  final int snapBackGeneration;
  final bool shouldSnapBack;
  final VoidCallback onDragRejected;
  final bool enabled;

  @override
  State<SnapBackDraggablePiece> createState() => _SnapBackDraggablePieceState();
}

class _SnapBackDraggablePieceState extends State<SnapBackDraggablePiece>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1,
    );
    _bounce = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(SnapBackDraggablePiece oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldSnapBack &&
        widget.snapBackGeneration != oldWidget.snapBackGeneration &&
        mounted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.pieceSize;
    final restingPiece = PieceVisual(size: size);

    if (!widget.enabled) {
      return restingPiece;
    }

    final draggable = Draggable<BoardDragData>(
      data: widget.dragData,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        child: PieceVisual(size: size * 1.2, glowing: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: restingPiece),
      onDragEnd: (details) {
        if (!details.wasAccepted) {
          widget.onDragRejected();
        }
      },
      child: restingPiece,
    );

    if (!_controller.isAnimating && _controller.value >= 1) {
      return draggable;
    }

    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        final offset = (1 - _bounce.value) * 10;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: Transform.scale(
            scale: 1 + (1 - _bounce.value) * 0.12,
            child: child,
          ),
        );
      },
      child: draggable,
    );
  }
}

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
  final bool isInteractive;

  Offset _cellTopLeft(int row, int col, double cellSize, double gap) {
    return Offset(col * (cellSize + gap), row * (cellSize + gap));
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
