import 'package:equatable/equatable.dart';
import 'package:sweeper_game/domain/entities/bomb_status.dart';
import 'package:sweeper_game/domain/entities/piece.dart';

class Cell extends Equatable {
  const Cell({
    required this.row,
    required this.col,
    this.piece,
    this.bombStatus = BombStatus.none,
  });

  final int row;
  final int col;
  final Piece? piece;
  final BombStatus bombStatus;

  bool get hasHiddenBomb => bombStatus == BombStatus.hidden;

  Cell copyWith({
    Piece? piece,
    BombStatus? bombStatus,
    bool clearPiece = false,
  }) {
    return Cell(
      row: row,
      col: col,
      piece: clearPiece ? null : (piece ?? this.piece),
      bombStatus: bombStatus ?? this.bombStatus,
    );
  }

  @override
  List<Object?> get props => [row, col, piece, bombStatus];
}
