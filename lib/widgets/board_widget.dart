import 'package:flutter/material.dart';
import 'package:minesweeper/widgets/cell_widget.dart';
import '../models/board.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final Function(int, int) onCellTap;
  final Function(int, int) onCellFlag;
  final bool gameActive; // Oyun aktif mi?

  BoardWidget({
    required this.board,
    required this.onCellTap,
    required this.onCellFlag,
    required this.gameActive, // Oyun aktif mi?
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: board.cells.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((cell) {
            int rowIndex = board.cells.indexOf(row);
            int cellIndex = row.indexOf(cell);
            return CellWidget(
              cell: cell,
              onTap: () => gameActive
                  ? onCellTap(rowIndex, cellIndex)
                  : null, // Oyun aktifse dokunmayı aktif et
              onFlag: () => gameActive
                  ? onCellFlag(rowIndex, cellIndex)
                  : null, // Oyun aktifse bayrak koymayı aktif et
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
