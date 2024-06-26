class Cell {
  bool hasMine;
  bool isRevealed;
  bool isFlagged;
  int surroundingMines;

  Cell({
    this.hasMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.surroundingMines = 0,
  });
}
