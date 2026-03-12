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
        moves: 0, // Not applicable for Sudoku
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.sudokuTitle} - ${widget.difficulty}'),
      ),
      body: ListenableBuilder(
        listenable: _gameProvider,
        builder: (context, _) {
          return Column(
            children: [
              // Top Stats Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${AppStrings.level} ${_gameProvider.currentLevel}',
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(AppStrings.sudokuInstructions,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87)),
              ),
              const SizedBox(height: 16),

              // Sudoku Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            width: 3), // Outer thick border
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
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

                          // Accessible coloring
                          Color bgColor = Colors.white;
                          if (isSelected)
                            bgColor = Colors.amber.shade200;
                          else if (isRelated)
                            bgColor = Colors.blue.shade50;
                          else if (cell.isConflict)
                            bgColor = Colors.red.shade100;

                          // Border logic for Sub-blocks
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
                                    fontSize: _gameProvider.gridSize > 6
                                        ? 24
                                        : 32, // Larger numbers for elderly
                                    fontWeight: cell.isFixed
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: cell.isConflict
                                        ? Colors.red.shade900
                                        : (cell.isFixed
                                            ? Colors.black
                                            : Colors.blue.shade900),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Controls List
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Number Pad
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_gameProvider.gridSize, (index) {
                        int num = index + 1;
                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _gameProvider.inputNumber(num),
                            child: Text(num.toString(),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons (Erase & Hint)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _gameProvider.eraseCell(),
                          icon: const Icon(Icons.backspace),
                          label: const Text(AppStrings.eraseButton,
                              style: TextStyle(fontSize: 18)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _gameProvider.useHint(),
                          icon: const Icon(Icons.lightbulb),
                          label: const Text(AppStrings.hintButton,
                              style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
