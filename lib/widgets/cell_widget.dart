import 'package:flutter/material.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onFlag;

  CellWidget({
    required this.cell,
    required this.onTap,
    required this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onFlag,
      child: Container(
        margin: EdgeInsets.all(2.0),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: cell.isRevealed
              ? (cell.hasMine ? Colors.red[200] : Colors.grey[300])
              : Colors.blue[300],
          border: Border.all(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: cell.isRevealed
              ? cell.hasMine
                  ? Icon(Icons.brightness_1, color: Colors.black, size: 20)
                  : Text(
                      cell.surroundingMines > 0
                          ? '${cell.surroundingMines}'
                          : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(cell.surroundingMines),
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    )
              : cell.isFlagged
                  ? Icon(Icons.flag, color: Colors.red, size: 20)
                  : Container(),
        ),
      ),
    );
  }

  Color _getTextColor(int surroundingMines) {
    switch (surroundingMines) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.deepPurple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.cyan;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
