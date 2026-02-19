// Created by Dylan Mackintosh, 22nd of September 2025

// Represents the two players
enum Player { X, O }

// Represents each cell’s state
enum Cell { empty, X, O }

// Records each move (who played and where)
class Move {
  final int index;
  final Player player;
  Move(this.index, this.player);
}

// Main game board class
class Board {
  final List<Cell> cells;         // 3x3 board as a list
  Player currentPlayer;           // Whose turn it is
  bool gameOver = false;          // Whether game has ended
  Player? winner;                 // Winner if game is over
  final List<Move> _history = []; // Move history for undo

  // Creates a new board (defaults to empty)
  Board({List<Cell>? initial, this.currentPlayer = Player.X})
      : cells = initial ?? List.filled(9, Cell.empty);

  // Clone constructor (used for AI simulation)
  Board.clone(Board other)
      : cells = List<Cell>.from(other.cells),
        currentPlayer = other.currentPlayer,
        gameOver = other.gameOver,
        winner = other.winner {
    _history.addAll(other._history);
  }

  // Returns indexes of all empty cells
  List<int> emptyIndices() {
    return [
      for (int i = 0; i < 9; i++)
        if (cells[i] == Cell.empty) i
    ];
  }

  // Checks if move is valid (inside bounds, empty, game not over)
  bool isLegal(int i) => !gameOver && i >= 0 && i < 9 && cells[i] == Cell.empty;

  // Places a move on the board
  bool makeMove(int i) {
    if (!isLegal(i)) return false;
    cells[i] = currentPlayer == Player.X ? Cell.X : Cell.O;
    _history.add(Move(i, currentPlayer));
    _checkWin(); // Check for win/draw
    if (!gameOver) currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
    return true;
  }

  // Undo last single move
  bool undoOne() {
    if (_history.isEmpty) return false;
    final last = _history.removeLast();
    cells[last.index] = Cell.empty;
    gameOver = false;
    winner = null;
    currentPlayer = last.player;
    return true;
  }

  // Undo last full turn (player + AI)
  int undoFullTurn() {
    int undone = 0;
    if (undoOne()) undone++;
    if (undoOne()) undone++;
    return undone;
  }

  // Check for a win or draw
  void _checkWin() {
    const wins = [
      [0,1,2],[3,4,5],[6,7,8], // Rows
      [0,3,6],[1,4,7],[2,5,8], // Columns
      [0,4,8],[2,4,6]          // Diagonals
    ];
    for (final line in wins) {
      final a = cells[line[0]], b = cells[line[1]], c = cells[line[2]];
      if (a != Cell.empty && a == b && b == c) {
        gameOver = true;
        winner = (a == Cell.X) ? Player.X : Player.O;
        return;
      }
    }
    // If board full and no winner → draw
    if (emptyIndices().isEmpty) gameOver = true;
  }

  // Returns the opposite player
  static Player other(Player p) => p == Player.X ? Player.O : Player.X;
}
