import 'package:equatable/equatable.dart';
import 'package:sweeper_game/domain/entities/piece.dart';

/// Payload for board drag-and-drop — always includes source cell.
class BoardDragData extends Equatable {
  const BoardDragData({
    required this.piece,
    required this.fromRow,
    required this.fromCol,
  });

  final Piece piece;
  final int fromRow;
  final int fromCol;

  @override
  List<Object?> get props => [piece, fromRow, fromCol];
}
