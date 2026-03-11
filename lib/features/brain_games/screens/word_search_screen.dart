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
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.wordSearchTitle} - ${widget.difficulty}'),
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
                            color: Colors.teal.shade700)),
                    Text(
                        '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Instruction
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(AppStrings.tapFirstTapLast,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87)),
              ),
              const SizedBox(height: 16),

              // The Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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

                        Color bgColor = Colors.grey.shade200;
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
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                _gameProvider.grid[y][x],
                                style: TextStyle(
                                  fontSize: _gameProvider.gridSize > 6
                                      ? 20
                                      : 24, // Scale down slightly for harder levels
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

              // Target Words List
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -4))
                ]),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _gameProvider.targetWords.map((word) {
                    bool isFound = _gameProvider.foundWords.contains(word);
                    return Chip(
                      label: Text(word,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration:
                                isFound ? TextDecoration.lineThrough : null,
                            color: isFound ? Colors.white : Colors.black87,
                          )),
                      backgroundColor:
                          isFound ? Colors.teal : Colors.grey.shade200,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
