import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import '../data/local_db/brain_games_db.dart';
import 'memory_match_screen.dart';

class GameDetailsScreen extends ConsumerStatefulWidget {
  final String gameTitle;
  const GameDetailsScreen({super.key, required this.gameTitle});

  @override
  ConsumerState<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends ConsumerState<GameDetailsScreen> {
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final user = ref.read(authNotifierProvider);
    if (user != null) {
      setState(() {
        _statsFuture = BrainGamesDB.instance
            .getGameStatsSummary(user.uid, widget.gameTitle);
      });
    }
  }

  // Use this to refresh stats when returning from a game
  void _startGame(String difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MemoryMatchScreen(difficulty: difficulty)),
    );
    _loadStats(); // Refresh stats when user returns
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 30),
            const Text("Select Difficulty",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _buildPlayButton(AppStrings.difficultyEasy, Colors.green),
            const SizedBox(height: 12),
            _buildPlayButton(AppStrings.difficultyMedium, Colors.orange),
            const SizedBox(height: 12),
            _buildPlayButton(AppStrings.difficultyHard, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(String difficulty, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _startGame(difficulty),
      child: Text('Play $difficulty',
          style: const TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsSection() {
    if (_statsFuture == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        final overview = data?['overview'] as Map<String, dynamic>? ?? {};
        final bestTimes =
            data?['bestTimes'] as List<Map<String, dynamic>>? ?? [];

        int totalWins = overview['totalWins'] ?? 0;

        if (totalWins == 0) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(AppStrings.noStatsYet,
                    style: TextStyle(fontSize: 20, color: Colors.grey)),
              ),
            ),
          );
        }

        // Parse overview data
        int totalSeconds = (overview['totalTime'] ?? 0).toInt();
        int avgSeconds = (overview['avgTime'] ?? 0).toInt();

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppStrings.statsTitle,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
                const Divider(thickness: 1.5, height: 24),

                // Overall Stats
                _statRow(Icons.emoji_events, AppStrings.totalWinsLabel,
                    totalWins.toString()),
                _statRow(Icons.timer, AppStrings.totalTimeLabel,
                    '${(totalSeconds / 60).toStringAsFixed(1)} min'),
                _statRow(
                    Icons.speed, AppStrings.avgTimeLabel, '$avgSeconds sec'),

                const SizedBox(height: 16),
                const Text("Best Times",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Best Times per difficulty
                ...bestTimes.map((row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 12),
                          Text('${row['difficulty']}: ',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          Text('${row['bestTime']} seconds',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 18, color: Colors.black87)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
