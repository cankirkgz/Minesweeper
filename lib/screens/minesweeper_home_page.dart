import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/board.dart';
import '../widgets/board_widget.dart';

class MinesweeperHomePage extends StatefulWidget {
  @override
  _MinesweeperHomePageState createState() => _MinesweeperHomePageState();
}

class _MinesweeperHomePageState extends State<MinesweeperHomePage> {
  late Board board;
  Timer? timer;
  Timer? cellTimer;
  int secondsPassed = 0;
  int cellTimeLeft = 5;
  bool gameStarted = false;
  bool gameEnded = false;
  bool gameActive = true;
  int remainingMines = 10;
  int maxMines = 0;
  int rows = 10;
  int columns = 10;
  int bestTime = 0;
  int bestTimeMines = 0;

  @override
  void initState() {
    super.initState();
    maxMines = rows * columns - 1;
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
    if (numMines < 10) numMines = 10;
    if (numMines > maxMines / 2) numMines = maxMines ~/ 2;

    setState(() {
      board = Board(rows: rows, columns: columns, numMines: numMines);
      remainingMines = numMines;
      gameStarted = false;
      gameEnded = false;
      gameActive = true;
      secondsPassed = 0;
      cellTimeLeft = 5;
      maxMines = rows * columns - 1;
      _cancelTimers();
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
            _showGameOverDialog("Süre doldu! Tekrar oynamak ister misiniz?");
          }
        });
      }
    });
  }

  void _resetCellTimer() {
    setState(() {
      cellTimeLeft = 5;
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

    if (!gameActive) return;

    _resetCellTimer();

    if (board.cells[row][column].hasMine) {
      _revealAllMines();
      _endGame();
      _showGameOverDialog("Bir mayına bastınız! Tekrar oynamak ister misiniz?");
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
            "Tebrikler! Kazandınız! Tekrar oynamak ister misiniz?");
      }
    }
  }

  void _handleCellFlag(int row, int column) async {
    if (!gameActive) return;

    _resetCellTimer();

    setState(() {
      if (!board.cells[row][column].isRevealed) {
        board.cells[row][column].isFlagged =
            !board.cells[row][column].isFlagged;
        remainingMines += board.cells[row][column].isFlagged ? -1 : 1;
      }
    });

    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(duration: 50);
    }
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
      gameActive = false;
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
          title: Text("Oyun Bitti"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Evet"),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(rows, columns, remainingMines);
              },
            ),
            TextButton(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameActive = false;
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
        title: Text('Mayın Tarlası'),
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
                Text('Oyun Kuralları:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('1. $remainingMines mayın var.'),
                Text('2. Bir hücreyi açmak için dokunun.'),
                Text('3. Bir hücreyi işaretlemek için uzun basın.'),
                Text('4. Bir hücre seçmek için 5 saniyeniz var.'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Mayınlar: $remainingMines'),
                    Text('Süre: $secondsPassed s'),
                    Text('Kalan Hücreler: $remainingCells'),
                  ],
                ),
                SizedBox(height: 10),
                Text('Mayın Sayısını Seçin:'),
                Slider(
                  value: remainingMines
                      .toDouble()
                      .clamp(10.0, (rows * columns / 2).toDouble()),
                  min: 10,
                  max: (rows * columns / 2).toDouble(),
                  divisions: ((rows * columns / 2 - 10) / 5).round(),
                  label: remainingMines.toString(),
                  onChanged: (value) {
                    setState(() {
                      remainingMines =
                          value.toInt().clamp(10, (rows * columns / 2).toInt());
                    });
                  },
                  onChangeEnd: (value) {
                    _startNewGame(rows, columns, value.toInt());
                  },
                ),
                SizedBox(height: 10),
                Text(
                    'En İyi Süre: ${bestTime > 0 ? "$bestTime s" : "0"} ${bestTimeMines > 0 ? "$bestTimeMines mayın" : ""}'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kalan Süre: $cellTimeLeft s',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  BoardWidget(
                    board: board,
                    onCellTap: _handleCellTap,
                    onCellFlag: _handleCellFlag,
                    gameActive: gameActive,
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
