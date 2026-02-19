// Created by Dylan Mackintosh 10551951, 25th of September 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe_flutter/storage.dart';

void main() {
  // Before each test, set up a clean in-memory preferences store.
  // This prevents the tests from using real device storage and ensures each test runs independently with a fresh starting point.
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // 💾 These tests focus on verifying the ScoreKeeper class, which is
  // responsible for saving, loading, and resetting the player's stats.
  group('ScoreKeeper persistence', () {

    test('Save and load keeps stats', () async {
      // Create a new ScoreKeeper instance and assign some test values.
      final s = ScoreKeeper();
      s.wins = 3;
      s.losses = 1;
      s.draws = 2;

      // Save these values into SharedPreferences (mocked in memory).
      await s.save();

      // Create a *new* ScoreKeeper to simulate reopening the app.
      final s2 = ScoreKeeper();

      // Load previously saved values from storage.
      await s2.load();

      // Confirm the stats were saved and loaded correctly.
      expect(s2.wins, 3);
      expect(s2.losses, 1);
      expect(s2.draws, 2);
    });

    test('Reset sets all to zero', () async {
      // Give the ScoreKeeper some non-zero stats.
      final s = ScoreKeeper();
      s.wins = 5;
      s.losses = 4;
      s.draws = 3;

      // Call reset(), which should clear everything back to zero.
      await s.reset();

      // Verify all values are now zeroed out.
      expect(s.wins, 0);
      expect(s.losses, 0);
      expect(s.draws, 0);
    });
  });
}
