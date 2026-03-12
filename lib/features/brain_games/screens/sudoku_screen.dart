import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import '../data/local_db/brain_games_db.dart';
import '../data/models/game_stat_model.dart';
import '../providers/sudoku_provider.dart';

class SudokuScreen extends ConsumerStatefulWidget {
  final String difficulty;
  const SudokuScreen({super.key, required this.difficulty});

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  late SudokuProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    _gameProvider = SudokuProvider(difficulty: widget.difficulty);
    _gameProvider.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (_gameProvider.isGameComplete) {
      _saveScoreAndShowDialog();
    }
  }

  Future<void> _saveScoreAndShowDialog() async {
    final user = ref.read(authNotifierProvider);
    if (user != null) {
      final stat = GameStat(
        userId: user.uid,
        gameName: AppStrings.sudokuTitle,
        difficulty: widget.difficulty,
        moves: 0,
        timeSeconds: _gameProvider.timeSeconds,
        date: DateTime.now().toIso8601String(),
      );
      await BrainGamesDB.instance.insertStat(stat);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.wellDone,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        content: Text(
            '${AppStrings.level} Completed: ${_gameProvider.currentLevel}\n\n'
            '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s\n'
            '${AppStrings.hintsUsed} ${_gameProvider.hintsUsed}',
            style: const TextStyle(fontSize: 20)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.quitGame,
                style: TextStyle(fontSize: 18, color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _gameProvider.resetForNextLevel();
            },
            child: const Text(AppStrings.continueGame,
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameProvider.removeListener(_onGameStateChanged);
    _gameProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate a responsive board size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Board takes up 90% of screen width, but caps at 450px for tablets
    final double boardSize = (screenWidth * 0.9).clamp(250.0, 450.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.sudokuTitle} - ${widget.difficulty}'),
        centerTitle: true,
      ),
      // 2. Wrap the entire body in a SingleChildScrollView
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _gameProvider,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center everything
                children: [
                  // Top Stats Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${AppStrings.level} ${_gameProvider.currentLevel}',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800)),
                        Text(
                            '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(AppStrings.sudokuInstructions,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black87)),
                  ),
                  const SizedBox(height: 24),

                  // Responsive Game Board
                  SizedBox(
                    width: boardSize,
                    height: boardSize, // Enforces a perfect square
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Handled by outer scroll view
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gameProvider.gridSize,
                        ),
                        itemCount:
                            _gameProvider.gridSize * _gameProvider.gridSize,
                        itemBuilder: (context, index) {
                          int r = index ~/ _gameProvider.gridSize;
                          int c = index % _gameProvider.gridSize;
                          final cell = _gameProvider.grid[r][c];

                          bool isSelected = _gameProvider.selectedRow == r &&
                              _gameProvider.selectedCol == c;
                          bool isRelated = (_gameProvider.selectedRow == r ||
                                  _gameProvider.selectedCol == c) &&
                              !isSelected;

                          Color bgColor = Colors.white;
                          if (isSelected)
                            bgColor = Colors.amber.shade300;
                          else if (cell.isConflict)
                            bgColor = Colors.red.shade100;
                          else if (isRelated) bgColor = Colors.blue.shade50;

                          Color textColor = Colors.black;
                          if (cell.isConflict)
                            textColor = Colors.red.shade900;
                          else if (cell.isHinted)
                            textColor = Colors.green.shade800;
                          else if (cell.isFixed)
                            textColor = Colors.black;
                          else
                            textColor = Colors.blue.shade900;

                          BorderSide thickBorder =
                              const BorderSide(color: Colors.black, width: 2.5);
                          BorderSide thinBorder =
                              BorderSide(color: Colors.grey.shade400, width: 1);

                          return GestureDetector(
                            onTap: () => _gameProvider.selectCell(r, c),
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border(
                                  top: (r % _gameProvider.blockH == 0 && r != 0)
                                      ? thickBorder
                                      : thinBorder,
                                  left:
                                      (c % _gameProvider.blockW == 0 && c != 0)
                                          ? thickBorder
                                          : thinBorder,
                                  bottom: thinBorder,
                                  right: thinBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cell.value == 0 ? '' : cell.value.toString(),
                                  style: TextStyle(
                                    // Scale text size down slightly for hard mode
                                    fontSize:
                                        _gameProvider.gridSize > 6 ? 22 : 32,
                                    fontWeight: cell.isFixed
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Clear breathing room

                  // Number Pad Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(_gameProvider.gridSize, (index) {
                        int num = index + 1;
                        return SizedBox(
                          width: 65, // Generous tap area for elderly users
                          height: 65,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _gameProvider.inputNumber(num),
                            child: Text(num.toString(),
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bottom Actions (Erase & Hint)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _gameProvider.eraseCell(),
                          icon: const Icon(Icons.backspace, size: 24),
                          label: const Text(AppStrings.eraseButton,
                              style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 16), // Space between buttons
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _gameProvider.useHint(),
                          icon: const Icon(Icons.lightbulb, size: 24),
                          label: const Text(AppStrings.hintButton,
                              style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Extra bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
