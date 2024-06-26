import 'dart:math';
import 'cell.dart';

class Board {
  final int rows;
  final int columns;
  final int numMines;
  final Random _random = Random(); // Random number generator
  late List<List<Cell>> cells;

  Board({
    required this.rows,
    required this.columns,
    required this.numMines,
  }) {
    _initializeBoard();
  }

  void _initializeBoard() {
    cells = List.generate(rows, (r) => List.generate(columns, (c) => Cell()));
    _placeMines();
    _calculateSurroundingMines();
  }

  void _placeMines() {
    int placedMines = 0;
    while (placedMines < numMines) {
      int r = _random.nextInt(rows);
      int c = _random.nextInt(columns);
      if (!cells[r][c].hasMine) {
        cells[r][c].hasMine = true;
        placedMines++;
      }
    }
  }

  void _calculateSurroundingMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        cells[r][c].surroundingMines = _countSurroundingMines(r, c);
      }
    }
  }

  int _countSurroundingMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nr = row + dr;
        int nc = col + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < columns) {
          if (cells[nr][nc].hasMine) {
            count++;
          }
        }
      }
    }
    return count;
  }
}
