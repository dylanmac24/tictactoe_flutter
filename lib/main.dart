// Created by Dylan Mackintosh 1055951, 24th of September 2025

import 'package:flutter/material.dart';
import 'game_logic.dart';
import 'ai.dart';
import 'storage.dart';

void main() {
  // Ensures Flutter is fully ready before running the app
  WidgetsFlutterBinding.ensureInitialized();
  // Start the app
  runApp(const TicTacToeApp());
}

// Root widget for the whole app
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App theme and colours
    final seed = const Color(0xFF9C27B0); // Base purple colour
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noughts & Crosses',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        // Font styling
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
          titleMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          bodyMedium: TextStyle(fontWeight: FontWeight.w500, height: 1.25),
        ),
        // Transparent AppBar
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        // Rounded filled buttons
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
            shape: WidgetStatePropertyAll(StadiumBorder()),
            textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ),
        ),
        // Outlined buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
            shape: WidgetStatePropertyAll(StadiumBorder()),
            side: WidgetStatePropertyAll(BorderSide(color: Colors.white70, width: 1.2)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            textStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ),
        ),
      ),
      home: const GamePage(), // Loads main game page
    );
  }
}

// Main game page
class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Core game helpers
  final ScoreKeeper _scores = ScoreKeeper(); // Track wins/losses/draws
  final TicTacToeAI _ai = TicTacToeAI();     // Handles AI logic
  Board _board = Board();                    // Game board state

  // Settings and flags
  Difficulty _difficulty = Difficulty.medium;
  bool _humanIsX = true;            // Player marker
  bool _mediumRandomTurn = true;    // Medium difficulty mix
  bool _aiThinking = false;         // Show loading bar

  // Visuals 

  // Background gradient
  static const LinearGradient _pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF2D55),
      Color(0xFFE91E63),
      Color(0xFF6A1B9A),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  // Board panel gradient
  static const LinearGradient _boardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x22FFFFFF)],
  );

  // Colour gradients for X and O
  Shader _markShader(Rect bounds, bool isX) {
    final colors = isX
        ? [const Color(0xFF42A5F5), const Color(0xFF00E5FF)]
        : [const Color(0xFFFFC107), const Color(0xFFFF7043)];
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)
        .createShader(bounds);
  }

  // Draws the X/O with gradient and shadow
  Widget _markText(String mark) {
    final isX = mark == 'X';
    return ShaderMask(
      shaderCallback: (rect) => _markShader(rect, isX),
      blendMode: BlendMode.srcIn,
      child: Text(
        mark,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Colors.white,
          shadows: [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
        ),
      ),
    );
  }

  // Resize board to fit screen
  double _boardSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    return shortest.clamp(280.0, 520.0) * 0.9;
  }

  // Lifecycle 

  @override
  void initState() {
    super.initState();
    _init(); // Load saved scores
  }

  Future<void> _init() async {
    await _scores.load();
    setState(() {});
  }

  // Start new game
  void _newGame() {
    setState(() {
      _board = Board(currentPlayer: Player.X);
      _mediumRandomTurn = true;
      _aiThinking = false;
    });
    if (!_humanIsX) _aiTurn(); // Let AI go first if player is O
  }

  // Switch player side
  void _setHumanSide(bool isX) {
    if (_humanIsX == isX) return;
    setState(() => _humanIsX = isX);
    _newGame();
  }

  // When user taps a cell
  Future<void> _onCellTap(int index) async {
    if (_aiThinking || _board.gameOver) return;
    final human = _humanIsX ? Player.X : Player.O;
    if (_board.currentPlayer != human) return;
    if (!_board.makeMove(index)) return;

    await _handleEndIfNeeded();
    setState(() {});
    if (!_board.gameOver) await _aiTurn();
  }

  // AI takes its turn
  Future<void> _aiTurn() async {
    final human = _humanIsX ? Player.X : Player.O;
    if (_board.currentPlayer == human || _board.gameOver) return;

    setState(() => _aiThinking = true);
    await Future.delayed(const Duration(milliseconds: 150));

    final idx = _ai.chooseMove(
      _board,
      _difficulty,
      isMediumRandomTurn: (_difficulty == Difficulty.medium) ? _mediumRandomTurn : false,
    );
    if (idx != -1) _board.makeMove(idx);

    await _handleEndIfNeeded();
    if (_difficulty == Difficulty.medium) _mediumRandomTurn = !_mediumRandomTurn;
    setState(() => _aiThinking = false);
  }

  // Update scores if game ended
  Future<void> _handleEndIfNeeded() async {
    if (_board.gameOver) {
      final human = _humanIsX ? Player.X : Player.O;
      if (_board.winner == human) {
        _scores.wins++;
      } else if (_board.winner == null) _scores.draws++;
      else _scores.losses++;
      await _scores.save();
      if (mounted) _showEndDialog();
    }
  }

  // Show pop-up when game ends
  Future<void> _showEndDialog() async {
    final title = _board.winner == null
        ? 'Draw!'
        : (_board.winner == (_humanIsX ? Player.X : Player.O) ? 'Victory!' : 'Defeat');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Play again or undo to replay the turn.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _board.undoFullTurn());
            },
            child: const Text('Undo Turn'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  // Undo last two moves
  void _undo() => setState(() => _board.undoFullTurn());

  // Build 3x3 grid
  Widget _buildGrid(BuildContext context) {
    final boardSize = _boardSize(context);
    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          gradient: _boardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 9,
          itemBuilder: (context, i) {
            final cell = _board.cells[i];
            String text = '';
            if (cell == Cell.X) text = 'X';
            if (cell == Cell.O) text = 'O';
            return _Tile(onTap: () => _onCellTap(i), child: text.isEmpty ? const SizedBox.shrink() : _markText(text));
          },
        ),
      ),
    );
  }

  // UI Layout 
  @override
  Widget build(BuildContext context) {
    final humanLabel = _humanIsX ? 'X' : 'O';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Noughts & Crosses', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
        backgroundColor: Colors.transparent,
        actions: [
          // Reset scores
          IconButton(
            tooltip: 'Reset scores',
            onPressed: () async {
              await _scores.reset();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scores reset')));
              }
              setState(() {});
            },
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      // Page body
      body: Container(
        decoration: const BoxDecoration(gradient: _pageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Control bar 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    children: [
                      // Difficulty selector
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.bolt, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        const Text('Difficulty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButton<Difficulty>(
                            value: _difficulty,
                            underline: const SizedBox.shrink(),
                            dropdownColor: const Color(0xFF2A1845),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            onChanged: (d) {
                              if (d != null) setState(() => _difficulty = d);
                            },
                            items: const [
                              DropdownMenuItem(value: Difficulty.easy, child: Text('Easy')),
                              DropdownMenuItem(value: Difficulty.medium, child: Text('Medium')),
                              DropdownMenuItem(value: Difficulty.hard, child: Text('Hard')),
                            ],
                          ),
                        ),
                      ]),
                      // Player side toggle
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.person, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        const Text('You are', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        _ChipToggle(label: 'X', selected: _humanIsX, onTap: () => _setHumanSide(true)),
                        const SizedBox(width: 8),
                        _ChipToggle(label: 'O', selected: !_humanIsX, onTap: () => _setHumanSide(false)),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Game Board 
                Expanded(child: _buildGrid(context)),

                const SizedBox(height: 12),

                // Buttons 
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _newGame,
                      icon: const Icon(Icons.play_circle),
                      label: const Text('New Game'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _undo,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo Turn'),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Scoreboard 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Wins: ${_scores.wins}   Losses: ${_scores.losses}   Draws: ${_scores.draws}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text('Your marker: $humanLabel', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

                // AI Thinking Bar 
                if (_aiThinking) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(
                    minHeight: 4,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tile widget for board cells
class _Tile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _Tile({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12, width: 0.8),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

// Toggle buttons for player side (X or O)
class _ChipToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChipToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF6A1B9A) : Colors.white,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
