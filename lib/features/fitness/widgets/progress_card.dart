import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Requires dependency: percent_indicator

class ProgressCard extends StatelessWidget {
  final List<ExerciseWithProgress> exercises;
  const ProgressCard({super.key, required this.exercises});

  // Helper to format total seconds into "Xh Ym"
  String _formatTotalTime(int totalSeconds) {
    if (totalSeconds == 0) return '0m';
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    String result = '';
    if (hours > 0) {
      result += '${hours}h ';
    }
    if (minutes > 0 || hours == 0) {
      result += '${minutes}m';
    }
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    final totalExercises = exercises.length;
    final completedExercises =
        exercises.where((e) => e.progress.isCompleted).length;
    final double percent =
        totalExercises > 0 ? completedExercises / totalExercises : 0;

    // Calculate total time
    final int totalSeconds = exercises.fold(
      0,
      (sum, item) => sum + item.progress.secondsTracked,
    );
    final String totalTimeFormatted = _formatTotalTime(totalSeconds);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Gradient background matching your design aesthetic
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFC86DD7), // Pinkish purple
              Color(0xFF8667E3), // Blueish purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.todayProgressTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Trophy Icon
                Icon(Icons.emoji_events, color: Colors.yellow[600], size: 30),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.keepUpTheWork,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Progress Bar
                Expanded(
                  child: LinearPercentIndicator(
                    percent: percent,
                    lineHeight: 12,
                    barRadius: const Radius.circular(6),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    progressColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$completedExercises of $totalExercises ${AppStrings.exercisesCompleted}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Total Exercise Time Tracker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${AppStrings.totalExerciseTime} $totalTimeFormatted',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
