import 'package:flutter/material.dart';
import 'package:sweeper_game/domain/entities/board_drag_data.dart';
import 'package:sweeper_game/presentation/widgets/piece_visual.dart';

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
