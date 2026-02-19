// Created by Dylan Mackintosh 10551951, 25th of September 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_flutter/game_logic.dart';

void main() {
  // These tests check the gameplay rules of the board:
  // Detecting wins and draws, validating legal/illegal moves, making sure the game stops after it's over
  group('Board: core rules', () {

    test('All win lines are detected for X', () {
      // There are 8 ways to win in Tic Tac Toe (3 rows, 3 columns, 2 diagonals)
      const wins = <List<int>>[
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
        [0, 4, 8], [2, 4, 6],            // diagonals
      ];

      // Loop through each possible winning combination
      for (final line in wins) {
        final b = Board();

        // Simulate a full game where X wins along this line
        for (int i = 0; i < line.length; i++) {
          // X makes a move in each cell of the winning line
          expect(b.makeMove(line[i]), true);

          if (i < 2) {
            // After each X move (except the last), let O play elsewhere
            // so that turns alternate properly
            final filler = List.generate(9, (j) => j)
                .firstWhere((j) => !line.contains(j) && b.isLegal(j));
            expect(b.makeMove(filler), true);
          }
        }

        // After filling this line, the game should recognise a win for X
        expect(b.gameOver, true, reason: 'line $line should produce a win');
        expect(b.winner, Player.X);
      }
    });

    test('Draw when board is full with no winner', () {
      final b = Board();

      // Fill the entire board with moves that produce no winning line.
      // This pattern results in a draw:
      // X O X
      // X X O
      // O X O
      for (final i in [0, 1, 2, 5, 3, 6, 4, 8, 7]) {
        expect(b.makeMove(i), true);
      }

      // The game should be over, but with no winner
      expect(b.gameOver, true);
      expect(b.winner, null);
    });

    test('Illegal indices and occupied cells are rejected', () {
      final b = Board();

      // Moves outside 0–8 should be rejected
      expect(b.makeMove(9), false);
      expect(b.makeMove(-1), false);

      // A valid move should succeed
      expect(b.makeMove(0), true);

      // But trying the same cell again should fail 
      expect(b.makeMove(0), false);
    });

    test('No moves allowed after game over', () {
      final b = Board();

      // X completes the top row to win
      b.makeMove(0); b.makeMove(3);
      b.makeMove(1); b.makeMove(4);
      b.makeMove(2); // X wins here

      // Once the game is over, no more moves should be accepted
      expect(b.gameOver, true);
      expect(b.makeMove(5), false);
    });
  });

  // 🔄 These tests focus on undo functionality:
  // Ensuring moves can be reversed correctly, and turn order is restored.
  group('Board: undo behavior', () {

    test('Undo on empty history does nothing', () {
      final b = Board();

      // Trying to undo when no moves have been made should return false or 0
      expect(b.undoOne(), false);
      expect(b.undoFullTurn(), 0);
    });

    test('Undo one restores turn to last mover', () {
      final b = Board();
      b.makeMove(0); // X plays
      b.makeMove(4); // O plays

      // Undo one move (O’s move)
      expect(b.undoOne(), true);

      // The undone cell should now be empty
      expect(b.cells[4], Cell.empty);

      // The turn should go back to O (since O’s move was undone)
      expect(b.currentPlayer, Player.O);
    });

    test('Undo full turn removes last two moves and restores player', () {
      final b = Board();
      b.makeMove(0); // X
      b.makeMove(4); // O

      // Undo a full turn (both X and O’s most recent moves)
      final undone = b.undoFullTurn();

      // Should remove exactly two moves
      expect(undone, 2);

      // Both positions should be empty again
      expect(b.cells[0], Cell.empty);
      expect(b.cells[4], Cell.empty);

      // Turn should reset back to X
      expect(b.currentPlayer, Player.X);
    });
  });

  // 🧬 These tests confirm the clone method works properly:
  // The AI relies on cloning to simulate moves without altering the actual board.
  group('Board: clone safety', () {
    test('Board.clone does not mutate original when simulated', () {
      final b = Board();

      // Make a copy of the board
      final c = Board.clone(b);

      // Make a move on the cloned version
      c.makeMove(0);

      // The original board should remain unchanged
      expect(b.cells[0], Cell.empty);
    });
  });
}
