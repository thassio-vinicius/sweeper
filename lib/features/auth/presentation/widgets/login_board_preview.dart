import 'package:flutter/material.dart';
import 'package:sweeper/core/theme/app_colors.dart';
import 'package:sweeper/core/theme/app_spacing.dart';
import 'package:sweeper/features/game/presentation/widgets/board_grid.dart';

/// Compact decorative board for the login hero card.
class LoginBoardPreview extends StatelessWidget {
  const LoginBoardPreview({super.key, this.gridSize = 4});

  final int gridSize;

  @override
  Widget build(BuildContext context) {
    final cells = _cellsForSize(gridSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.clamp(0.0, 168.0);
        const gap = 3.0;
        final cellSize = (maxWidth - gap * (gridSize - 1)) / gridSize;

        return Center(
          child: SizedBox(
            width: maxWidth,
            height: maxWidth,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                return _PreviewTile(
                  cell: cells[index],
                  pieceSize: cellSize * 0.62,
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<_PreviewCell> _cellsForSize(int size) {
    if (size == 3) {
      return const [
        _PreviewCell.piece,
        _PreviewCell.bomb,
        _PreviewCell.empty,
        _PreviewCell.empty,
        _PreviewCell.magic,
        _PreviewCell.piece,
        _PreviewCell.empty,
        _PreviewCell.piece,
        _PreviewCell.bomb,
      ];
    }
    if (size == 4) {
      return const [
        _PreviewCell.piece,
        _PreviewCell.empty,
        _PreviewCell.bomb,
        _PreviewCell.empty,
        _PreviewCell.empty,
        _PreviewCell.magic,
        _PreviewCell.empty,
        _PreviewCell.piece,
        _PreviewCell.bomb,
        _PreviewCell.empty,
        _PreviewCell.piece,
        _PreviewCell.empty,
        _PreviewCell.empty,
        _PreviewCell.piece,
        _PreviewCell.empty,
        _PreviewCell.bomb,
      ];
    }

    return List.generate(size * size, (index) {
      return switch (index % 5) {
        0 => _PreviewCell.piece,
        2 => _PreviewCell.bomb,
        3 => _PreviewCell.magic,
        _ => _PreviewCell.empty,
      };
    });
  }
}

enum _PreviewCell { empty, piece, bomb, magic }

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.cell,
    required this.pieceSize,
  });

  final _PreviewCell cell;
  final double pieceSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cellEmpty,
        borderRadius: BorderRadius.circular(AppSpacing.cellRadius),
        border: Border.all(
          color: cell == _PreviewCell.magic
              ? AppColors.sun.withValues(alpha: 0.8)
              : AppColors.cellBorder,
        ),
        boxShadow: cell == _PreviewCell.magic
            ? [
                BoxShadow(
                  color: AppColors.sun.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Center(
        child: switch (cell) {
          _PreviewCell.piece => PieceVisual(size: pieceSize, glowing: true),
          _PreviewCell.bomb => Icon(
              Icons.local_fire_department,
              size: pieceSize * 0.9,
              color: AppColors.coralRed,
            ),
          _PreviewCell.magic => Icon(
              Icons.auto_awesome,
              size: pieceSize * 0.85,
              color: AppColors.sun,
            ),
          _PreviewCell.empty => const SizedBox.shrink(),
        },
      ),
    );
  }
}
