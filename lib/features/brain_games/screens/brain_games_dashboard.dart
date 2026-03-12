import 'package:flutter/material.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'game_details_screen.dart';

class BrainGamesDashboard extends StatelessWidget {
  const BrainGamesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.brainGamesTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGameCard(
            context: context,
            title: AppStrings.memoryMatchTitle,
            icon: Icons.grid_view_rounded,
            color: Colors.blue.shade700,
            isActive: true,
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            context: context,
            title: AppStrings.wordSearchTitle,
            icon: Icons.manage_search_rounded,
            color: Colors.teal.shade600,
            isActive: true,
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            context: context,
            title: AppStrings.sudokuTitle,
            icon: Icons.apps_rounded,
            color: Colors.orange.shade700,
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    return InkWell(
      onTap: isActive
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GameDetailsScreen(gameTitle: title)))
          : null, // Disabled if not active yet
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: isActive ? color : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  if (!isActive)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(AppStrings.comingSoon,
                          style:
                              TextStyle(fontSize: 16, color: Colors.white70)),
                    )
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
