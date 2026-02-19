// Created by Dylan Mackintosh 10551951, 25th of September 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe_flutter/ai.dart';
import 'package:tictactoe_flutter/game_logic.dart';

void main() {
  // This group tests the "Hard" AI difficulty, which should always make the best move:
  // It should take a winning move if available
  // It should block the opponent’s win if needed
  // It should play smartly (center first, then corners)
  group('AI: Hard strategy', () {

    test('Takes immediate winning move', () {
      final b = Board();

      // Setting up the board so that X can win on the next move at index 2:
      // Positions: [0, 1, 2]
      // X has already taken 0 and 1, so playing 2 will complete the top row.
      b.makeMove(0); // X goes first
      b.makeMove(3); // O plays somewhere else
      b.makeMove(1); // X takes another top row spot
      b.makeMove(4); // O again, random move

      // Create the AI and ask it for its move in Hard mode
      final ai = TicTacToeAI();
      final idx = ai.chooseMove(b, Difficulty.hard);

      // The AI should see the winning opportunity and choose index 2
      expect(idx, 2);
    });

    test('Blocks opponent immediate win (when no immediate win exists)', () {
      final b = Board();
      final ai = TicTacToeAI();

      // Set up a situation where the AI must block the opponent (O) from winning:
      // O has 0 and 1, threatening to win at 2 (the top row).
      // X has no immediate winning move here.
      b.makeMove(4); // X starts in the center
      b.makeMove(0); // O top-left
      b.makeMove(8); // X bottom-right
      b.makeMove(1); // O top-middle

      // It’s X’s turn. The only correct move is to block at index 2.
      final idx = ai.chooseMove(b, Difficulty.hard);
      expect(idx, 2);
    });

    test('Prefers center then a corner', () {
      final ai = TicTacToeAI();

      // Test 1: Empty board, the best opening move is the center (index 4)
      final b1 = Board(); // empty board, X to move
      expect(ai.chooseMove(b1, Difficulty.hard), 4); // should take center

      // Test 2: If center is already taken, AI should pick a corner next
      final b2 = Board();
      b2.makeMove(4); // X takes center, so it's O's turn
      final m = ai.chooseMove(b2, Difficulty.hard);

      // The move should be one of the four corners: 0, 2, 6, or 8
      expect([0, 2, 6, 8].contains(m), true);
    });
  });

  // This group covers the "Easy" and "Medium" difficulties.
  // Easy plays random moves, Medium alternates between random and smart moves.
  group('AI: Easy & Medium sanity', () {

    test('Easy returns a legal move', () {
      final b = Board();
      final ai = TicTacToeAI();

      // In Easy mode, the AI just picks a random move.
      final m = ai.chooseMove(b, Difficulty.easy);

      // Make sure the move is valid (on an empty space within 0–8)
      expect(b.isLegal(m), true);
    });

    test('Medium alternation flag respected (both legal)', () {
      final b = Board();
      final ai = TicTacToeAI();

      // Medium mode alternates between random and strategy.
      // First call simulates the random turn:
      final rand = ai.chooseMove(b, Difficulty.medium, isMediumRandomTurn: true);
      // Second call simulates the strategic turn:
      final strat = ai.chooseMove(b, Difficulty.medium, isMediumRandomTurn: false);

      // Both moves should still be valid positions
      expect(b.isLegal(rand), true);
      expect(b.isLegal(strat), true);
    });
  });
}
