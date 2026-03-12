import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import '../data/local_db/brain_games_db.dart';
import '../data/models/game_stat_model.dart';
import '../providers/word_search_provider.dart';

class WordSearchScreen extends ConsumerStatefulWidget {
  final String difficulty;
  const WordSearchScreen({super.key, required this.difficulty});

  @override
  ConsumerState<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends ConsumerState<WordSearchScreen> {
  late WordSearchProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    _gameProvider = WordSearchProvider(difficulty: widget.difficulty);
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
        gameName: AppStrings.wordSearchTitle,
        difficulty: widget.difficulty,
        moves: _gameProvider.attempts, // Using attempts as moves metric
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
            '${AppStrings.wordsFound} ${_gameProvider.foundWords.length}/${_gameProvider.targetWords.length}',
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
    // 1. Calculate responsive board size
    final screenWidth = MediaQuery.of(context).size.width;
    // The grid will take 95% of screen width, but we cap it at 500px for tablets
    final double gridSizeDimension = (screenWidth * 0.95).clamp(280.0, 500.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.wordSearchTitle} - ${widget.difficulty}'),
        centerTitle: true,
      ),
      // 2. Wrap body in SafeArea and SingleChildScrollView for responsiveness
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _gameProvider,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Stats Bar (Level & Timer)
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
                              color: Colors.teal.shade700),
                        ),
                        Text(
                          '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions - Clear and readable
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      AppStrings.tapFirstTapLast,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. The Grid - Contained in a SizedBox to maintain square ratio
                  Center(
                    child: SizedBox(
                      width: gridSizeDimension,
                      height: gridSizeDimension,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.teal.shade800, width: 2),
                        ),
                        child: GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // Important!
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gameProvider.gridSize,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount:
                              _gameProvider.gridSize * _gameProvider.gridSize,
                          itemBuilder: (context, index) {
                            int x = index % _gameProvider.gridSize;
                            int y = index ~/ _gameProvider.gridSize;
                            Point currentPoint = Point(x, y);

                            bool isFound =
                                _gameProvider.foundCells.contains(currentPoint);
                            bool isFirstTap =
                                _gameProvider.firstTap == currentPoint;

                            Color bgColor = Colors.white;
                            Color textColor = Colors.black87;

                            if (isFound) {
                              bgColor = Colors.teal.shade200;
                              textColor = Colors.teal.shade900;
                            } else if (isFirstTap) {
                              bgColor = Colors.amber.shade300;
                              textColor = Colors.black;
                            }

                            return GestureDetector(
                              onTap: () => _gameProvider.handleCellTap(x, y),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 1,
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _gameProvider.grid[y][x],
                                    style: TextStyle(
                                      // Scale font based on grid size to prevent overflow inside cells
                                      fontSize:
                                          _gameProvider.gridSize > 8 ? 18 : 22,
                                      fontWeight: FontWeight.bold,
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
                  ),
                  const SizedBox(height: 32),

                  // 4. Target Words List - Wrapped for responsiveness
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Words to Find:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: _gameProvider.targetWords.map((word) {
                            bool isFound =
                                _gameProvider.foundWords.contains(word);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isFound
                                    ? Colors.teal
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFound
                                      ? Colors.teal.shade800
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                word,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  decoration: isFound
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color:
                                      isFound ? Colors.white : Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 40), // Bottom padding for comfortable scrolling
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
