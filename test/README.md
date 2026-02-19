# Tic Tac Toe - Test Suite README

This document explains the testing approach for the Tic Tac Toe app.
All tests are written in Flutter's 'flutter_test' framework and focus on game logic, AI behaviour, and persistence as per assignment requirements.

# Purpose

To verify the game's core logic functions correctly.

# Test Files Overview

test/
|----ai_test.dart # Tests AI strategies in different difficulties for correct decision making.
|----board_test.dart # Tests board rules, win/draw logic, move legality and undo behaviour.
|----persistence_test.dart # Tests ScoreKeeper (saving, loading, resetting stats)

Each file includes its own 'main()' entrypoint and grouped 'test()' blocks.

# What Each File Tests

'board_test.dart' 
- Win Detection: Covers all 8 possible winning lines (rows, columns, diagonals).
- Draw Detection: Ensures a full board with no winner is a draw.
- Move Validation: Prevents out of range or occupied moves.
- Turn Flow: Alternates players correctly, stops after the game is over.
- Undo Behaviour: 'undoOne()' restores turn to previous player, 'undoFullTurn()' removes both recent turns. 
- Clone Safety: 'Board.clone()' does not affect the original board.

'ai_test.dart'
- Hard Mode: Takes winning move if available, blocks opponent's winning move if needed, prefers center on first move.
- Medium Mode: Alternates between random and strategic moves.
- Easy Mode: Always selects a random move. 

'persistence_test.dart'
- Save/Load: Confirms stats persist across instances using 'SharedPreferences'.
- Reset: Zeroes wins/losses/draws correctly.
- Uses 'SharedPreferences.setMockInitialValues({})' fore in-memory testing.

# Running Tests

Run All Tests
- To run all tests in the /test directory:
    flutter test

Run a Specific Test File
- To run a specific test in the /test directory (e.g. board_test.dart):
    flutter test test/board_test.dart