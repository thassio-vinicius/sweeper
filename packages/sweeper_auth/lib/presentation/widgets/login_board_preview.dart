import 'package:flutter/material.dart';
import 'package:sweeper_theme/app_tokens.dart';

/// Compact decorative board for the login hero card.
class LoginBoardPreview extends StatelessWidget {
  const LoginBoardPreview({super.key, this.gridSize = 4});

  final int gridSize;

  @override
  Widget build(BuildContext context) {
    final cells = _cellsForSize(gridSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth.clamp(0.0, AppSizes.previewBoardMaxWidth);
        final cellSize =
            (maxWidth - AppSizes.previewBoardGap * (gridSize - 1)) / gridSize;

        return Center(
          child: SizedBox(
            width: maxWidth,
            height: maxWidth,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: AppSizes.previewBoardGap,
                mainAxisSpacing: AppSizes.previewBoardGap,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                return _PreviewTile(
                  cell: cells[index],
                  pieceSize: cellSize * AppSizes.previewBoardPieceScale,
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
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: cell == _PreviewCell.magic
              ? AppColors.sun.withValues(alpha: AppOpacity.magicCellBorder)
              : AppColors.cellBorder,
        ),
        boxShadow:
            cell == _PreviewCell.magic ? AppShadows.magicCell : null,
      ),
      child: Center(
        child: switch (cell) {
          _PreviewCell.piece =>
            _PreviewPiece(size: pieceSize, glowing: true),
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

class _PreviewPiece extends StatelessWidget {
  const _PreviewPiece({
    required this.size,
    this.glowing = false,
  });

  final double size;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.piece;

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
                  blurRadius: AppBlur.lg,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        AppGlyphs.piece,
        style: TextStyle(
          color: AppColors.background,
          fontSize: size * 0.45,
          height: 1,
        ),
      ),
    );
  }
}
