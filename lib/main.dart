import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/board.dart';
import 'widgets/board_widget.dart';

void main() {
  runApp(MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MinesweeperHomePage(),
    );
  }
}

class MinesweeperHomePage extends StatefulWidget {
  @override
  _MinesweeperHomePageState createState() => _MinesweeperHomePageState();
}

class _MinesweeperHomePageState extends State<MinesweeperHomePage> {
  late Board board;
  Timer? timer;
  Timer? cellTimer; // Her hücre seçimi için zamanlayıcı
  int secondsPassed = 0;
  int cellTimeLeft = 5; // Her hücre için kalan süre
  bool gameStarted = false;
  bool gameEnded = false;
  bool gameActive = true; // Oyun aktif mi?
  int remainingMines = 10;
  int maxMines = 0;
  int rows = 10;
  int columns = 10;
  int bestTime = 0; // En iyi süre
  int bestTimeMines = 0; // En iyi süreye karşılık gelen mayın sayısı

  @override
  void initState() {
    super.initState();
    maxMines =
        rows * columns - 1; // Maksimum mayın sayısı, hücre sayısından bir eksik
    _loadBestTime();
    _startNewGame(rows, columns, remainingMines);
  }

  void _loadBestTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bestTime = prefs.getInt('bestTime') ?? 0;
      bestTimeMines = prefs.getInt('bestTimeMines') ?? 0;
    });
  }

  void _saveBestTime(int time, int mines) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('bestTime', time);
    prefs.setInt('bestTimeMines', mines);
  }

  void _startNewGame(int rows, int columns, int numMines) {
    if (numMines < 1) numMines = 1;
    if (numMines > maxMines) numMines = maxMines;

    setState(() {
      board = Board(rows: rows, columns: columns, numMines: numMines);
      remainingMines = numMines;
      gameStarted = false;
      gameEnded = false;
      gameActive = true; // Oyunu aktif hale getir
      secondsPassed = 0;
      cellTimeLeft = 5; // Hücre seçimi için süreyi sıfırla
      maxMines = rows * columns - 1;
      _cancelTimers(); // Zamanlayıcıları iptal et
      _startTimers();
    });
  }

  void _startTimers() {
    _startMainTimer();
    _startCellTimer();
  }

  void _startMainTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (gameStarted && !gameEnded) {
        setState(() {
          secondsPassed++;
        });
      }
    });
  }

  void _startCellTimer() {
    cellTimer = Timer.periodic(Duration(seconds: 1), (cellTimer) {
      if (gameStarted && !gameEnded) {
        setState(() {
          cellTimeLeft--;
          if (cellTimeLeft <= 0) {
            _endGame();
            _showGameOverDialog("Time's up! Would you like to play again?");
          }
        });
      }
    });
  }

  void _resetCellTimer() {
    setState(() {
      cellTimeLeft = 5; // Hücre seçimi için süreyi sıfırla
    });
  }

  void _cancelTimers() {
    timer?.cancel();
    cellTimer?.cancel();
  }

  void _handleCellTap(int row, int column) {
    if (!gameStarted) {
      gameStarted = true;
    }

    if (!gameActive) return; // Oyun aktif değilse hiçbir işlem yapma

    _resetCellTimer(); // Hücre seçimi için zamanlayıcıyı sıfırla

    if (board.cells[row][column].hasMine) {
      _revealAllMines();
      _endGame();
      _showGameOverDialog("You hit a mine! Would you like to play again?");
    } else {
      _revealEmptyCells(row, column);
      if (_checkWin()) {
        _endGame();
        if ((remainingMines >= bestTimeMines &&
            (secondsPassed < bestTime || bestTime == 0))) {
          bestTime = secondsPassed;
          bestTimeMines = remainingMines;
          _saveBestTime(bestTime, bestTimeMines);
        }
        _showGameOverDialog(
            "Congratulations! You won! Would you like to play again?");
      }
    }
  }

  void _handleCellFlag(int row, int column) {
    if (!gameActive) return; // Oyun aktif değilse hiçbir işlem yapma

    _resetCellTimer(); // Hücre seçimi için zamanlayıcıyı sıfırla

    setState(() {
      if (!board.cells[row][column].isRevealed) {
        board.cells[row][column].isFlagged =
            !board.cells[row][column].isFlagged;
        remainingMines += board.cells[row][column].isFlagged ? -1 : 1;
      }
    });
  }

  void _revealAllMines() {
    setState(() {
      for (var row in board.cells) {
        for (var cell in row) {
          if (cell.hasMine) {
            cell.isRevealed = true;
          }
        }
      }
    });
  }

  void _endGame() {
    setState(() {
      gameEnded = true;
      gameActive = false; // Oyunu aktiflikten çıkar
    });
    _cancelTimers();
  }

  void _revealEmptyCells(int row, int column) {
    setState(() {
      if (board.cells[row][column].isRevealed ||
          board.cells[row][column].isFlagged) {
        return;
      }

      board.cells[row][column].isRevealed = true;

      if (board.cells[row][column].surroundingMines == 0) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = row + dr;
            int nc = column + dc;
            if (nr >= 0 && nr < board.rows && nc >= 0 && nc < board.columns) {
              if (!board.cells[nr][nc].isRevealed) {
                _revealEmptyCells(nr, nc);
              }
            }
          }
        }
      }
    });
  }

  bool _checkWin() {
    for (var row in board.cells) {
      for (var cell in row) {
        if (!cell.hasMine && !cell.isRevealed) {
          return false;
        }
      }
    }
    return true;
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(rows, columns, remainingMines);
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameActive = false; // Oyun aktifliğini kaldır
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int remainingCells = board.cells
        .expand((e) => e)
        .where((cell) => !cell.isRevealed && !cell.hasMine)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Minesweeper'),
        actions: [
          if (!gameActive)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _startNewGame(rows, columns, remainingMines);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Game Rules:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('1. There are $remainingMines mines.'),
                Text('2. Tap to reveal a cell.'),
                Text('3. Long press to flag a cell.'),
                Text('4. You have 5 seconds to select a cell.'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Mines: $remainingMines'),
                    Text('Time: $secondsPassed s'),
                    Text('Remaining Cells: $remainingCells'),
                  ],
                ),
                SizedBox(height: 10),
                Text('Select Number of Mines:'),
                Slider(
                  value:
                      remainingMines.toDouble().clamp(1.0, maxMines.toDouble()),
                  min: 1,
                  max: maxMines.toDouble(),
                  divisions: maxMines,
                  label: remainingMines.toString(),
                  onChanged: (value) {
                    setState(() {
                      remainingMines = value.toInt().clamp(1, maxMines);
                    });
                  },
                  onChangeEnd: (value) {
                    _startNewGame(rows, columns, value.toInt());
                  },
                ),
                SizedBox(height: 10),
                Text(
                    'Best Time: ${bestTime > 0 ? "$bestTime s" : "0"} for ${bestTimeMines > 0 ? "$bestTimeMines mines" : ""}'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Time Left: $cellTimeLeft s',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  BoardWidget(
                    board: board,
                    onCellTap: _handleCellTap,
                    onCellFlag: _handleCellFlag,
                    gameActive: gameActive, // Oyun aktifliğini widget'a geç
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
