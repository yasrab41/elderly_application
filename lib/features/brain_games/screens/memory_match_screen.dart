import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_db/brain_games_db.dart';
import '../data/models/game_stat_model.dart';
import '../providers/memory_game_provider.dart';
import 'package:elderly_prototype_app/core/constants.dart';

class MemoryMatchScreen extends ConsumerStatefulWidget {
  final String difficulty;
  const MemoryMatchScreen({super.key, required this.difficulty});

  @override
  ConsumerState<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends ConsumerState<MemoryMatchScreen> {
  late MemoryGameProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    _gameProvider = MemoryGameProvider(difficulty: widget.difficulty);
    _gameProvider.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (_gameProvider.isGameComplete) {
      _saveScoreAndShowDialog();
    }
  }

  // Future<void> _saveScoreAndShowDialog() async {
  //   final user = ref.read(authNotifierProvider);
  //   if (user != null) {
  //     final stat = GameStat(
  //       userId: user.uid,
  //       gameName: 'Memory Match',
  //       difficulty: widget.difficulty,
  //       moves: _gameProvider.moves,
  //       timeSeconds: _gameProvider.timeSeconds,
  //       date: DateTime.now().toIso8601String(),
  //     );
  //     await BrainGamesDB.instance.insertStat(stat);
  //   }

  //   if (!mounted) return;
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: const Text(AppStrings.wellDone,
  //           style: TextStyle(
  //               fontSize: 28,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.green)),
  //       content: Text(
  //           '${AppStrings.gameCompleteMsg}\n\n'
  //           '${AppStrings.movesCounter} ${_gameProvider.moves}\n'
  //           '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s',
  //           style: const TextStyle(fontSize: 20)),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context); // Close dialog
  //             Navigator.pop(context); // Exit game
  //           },
  //           child:
  //               const Text(AppStrings.quitGame, style: TextStyle(fontSize: 20)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _saveScoreAndShowDialog() async {
    final user = ref.read(authNotifierProvider);
    if (user != null) {
      final stat = GameStat(
        userId: user.uid,
        gameName: 'Memory Match',
        difficulty: widget.difficulty,
        moves: _gameProvider.moves,
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
            '${AppStrings.gameCompleteMsg}\n\n'
            '${AppStrings.movesCounter} ${_gameProvider.moves}\n'
            '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s\n'
            '${AppStrings.level} Completed: ${_gameProvider.currentLevel}',
            style: const TextStyle(fontSize: 20)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit game back to details screen
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
              Navigator.pop(context); // Close dialog
              _gameProvider
                  .resetForNextLevel(); // Resets board and increments level
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
    // Determine grid columns based on difficulty
    int crossAxisCount = widget.difficulty == 'Easy'
        ? 2
        : (widget.difficulty == 'Medium' ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.memoryMatchTitle} - ${widget.difficulty}'),
      ),
      body: ListenableBuilder(
        listenable: _gameProvider,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${AppStrings.level} ${_gameProvider.currentLevel}',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700)),
                    Text(
                        '${AppStrings.timeCounter} ${_gameProvider.timeSeconds}s',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _gameProvider.cards.length,
                    itemBuilder: (context, index) {
                      final card = _gameProvider.cards[index];
                      return GestureDetector(
                        onTap: () => _gameProvider.flipCard(card),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                              color: card.isFaceUp || card.isMatched
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1)
                              ]),
                          child: Center(
                            child: card.isFaceUp || card.isMatched
                                ? Icon(card.icon,
                                    size: 40,
                                    color: card.isMatched
                                        ? Colors.grey
                                        : Theme.of(context).primaryColor)
                                : const Icon(Icons.help_outline,
                                    size: 40, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
