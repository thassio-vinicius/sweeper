import 'package:flutter/material.dart';
import 'package:sweeper_game/presentation/widgets/piece_visual.dart';

/// Animates a piece sliding from one cell to another after a valid move.
class SlidingPieceOverlay extends StatefulWidget {
  const SlidingPieceOverlay({
    super.key,
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.cellSize,
    required this.gap,
    required this.pieceSize,
    required this.generation,
  });

  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final double cellSize;
  final double gap;
  final double pieceSize;
  final int generation;

  @override
  State<SlidingPieceOverlay> createState() => _SlidingPieceOverlayState();
}

class _SlidingPieceOverlayState extends State<SlidingPieceOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _position;

  Offset _cellCenter(int row, int col) {
    final stride = widget.cellSize + widget.gap;
    return Offset(
      col * stride + widget.cellSize / 2,
      row * stride + widget.cellSize / 2,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _position = Tween<Offset>(
      begin: _cellCenter(widget.fromRow, widget.fromCol),
      end: _cellCenter(widget.toRow, widget.toCol),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SlidingPieceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.generation != oldWidget.generation) {
      _position = Tween<Offset>(
        begin: _cellCenter(widget.fromRow, widget.fromCol),
        end: _cellCenter(widget.toRow, widget.toCol),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
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
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        final center = _position.value;
        return Positioned(
          left: center.dx - widget.pieceSize / 2,
          top: center.dy - widget.pieceSize / 2,
          child: child!,
        );
      },
      child: PieceVisual(size: widget.pieceSize),
    );
  }
}
