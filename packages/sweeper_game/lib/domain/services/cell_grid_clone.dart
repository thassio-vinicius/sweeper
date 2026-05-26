import 'package:sweeper_game/domain/entities/cell.dart';

List<List<Cell>> cloneCellGrid(List<List<Cell>> source) {
  return source
      .map(
        (row) => row
            .map(
              (cell) => Cell(
                row: cell.row,
                col: cell.col,
                piece: cell.piece,
                bombStatus: cell.bombStatus,
              ),
            )
            .toList(),
      )
      .toList();
}
