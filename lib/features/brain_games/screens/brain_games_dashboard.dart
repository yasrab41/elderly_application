import 'package:flutter/material.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'memory_match_screen.dart';

class BrainGamesDashboard extends StatelessWidget {
  const BrainGamesDashboard({super.key});

  void _startGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryMatchScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.brainGamesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.memoryMatchTitle,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(AppStrings.memoryMatchDesc,
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  _buildLevelButton(
                      context, AppStrings.difficultyEasy, Colors.green),
                  const SizedBox(height: 12),
                  _buildLevelButton(
                      context, AppStrings.difficultyMedium, Colors.orange),
                  const SizedBox(height: 12),
                  _buildLevelButton(
                      context, AppStrings.difficultyHard, Colors.red),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _startGame(context, level),
        child: Text('Play $level',
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}
