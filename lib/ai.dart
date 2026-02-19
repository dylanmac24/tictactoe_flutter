// Created by Dylan Mackintosh 10551951, 23rd of September 2025

import 'dart:math';
import 'game_logic.dart';

// Difficulty options for the AI
enum Difficulty { easy, medium, hard }

class TicTacToeAI {
  final _rng = Random(); // Used for random move selection

  // Main function that decides which move to make based on difficulty
  int chooseMove(Board board, Difficulty diff, {bool isMediumRandomTurn = false}) {
    switch (diff) {
      case Difficulty.easy:
        return _random(board); // Easy: purely random
      case Difficulty.medium:
        // Medium: alternate between random and smart moves
        return isMediumRandomTurn ? _random(board) : _strategy(board);
      case Difficulty.hard:
        return _strategy(board); // Hard: always uses strategy
    }
  }

  // Picks a random available square
  int _random(Board b) {
    final e = b.emptyIndices();
    return e.isEmpty ? -1 : e[_rng.nextInt(e.length)];
  }

  // Smart move strategy for Medium/Hard
  int _strategy(Board b) {
    final me = b.currentPlayer, opp = Board.other(me);

    // 1. Try to win if possible
    for (final i in b.emptyIndices()) {
      final clone = Board.clone(b)..makeMove(i);
      if (clone.gameOver && clone.winner == me) return i;
    }

    // 2. Block opponent's winning move
    for (final i in b.emptyIndices()) {
      final clone = Board.clone(b)..currentPlayer = opp..makeMove(i);
      if (clone.gameOver && clone.winner == opp) return i;
    }

    // 3. Take center if open
    if (b.isLegal(4)) return 4;

    // 4. Otherwise, take a corner
    for (final c in [0, 2, 6, 8]) {
      if (b.isLegal(c)) return c;
    }

    // 5. Finally, take a side if nothing else
    for (final s in [1, 3, 5, 7]) {
      if (b.isLegal(s)) return s;
    }

    // Fallback: random move
    return _random(b);
  }
}
