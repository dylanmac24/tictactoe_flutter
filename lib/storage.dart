// Created by Dylan Mackintosh 10551951, 22nd of September 

import 'package:shared_preferences/shared_preferences.dart';

// Class to track and save the player's score (wins, losses, draws)
class ScoreKeeper {
  // Keys used to store data locally
  static const _w = 'wins', _l = 'losses', _d = 'draws';

  // Current stats
  int wins = 0, losses = 0, draws = 0;

  // Load saved stats from local storage
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    wins = p.getInt(_w) ?? 0;
    losses = p.getInt(_l) ?? 0;
    draws = p.getInt(_d) ?? 0;
  }

  // Save current stats to local storage
  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_w, wins);
    await p.setInt(_l, losses);
    await p.setInt(_d, draws);
  }

  // Reset all stats back to zero
  Future<void> reset() async {
    wins = losses = draws = 0;
    await save();
  }
}

