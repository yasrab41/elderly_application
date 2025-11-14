import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helper to format Duration to Hh Mmin
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  return '${hours}h ${minutes}min';
}

// Replaces the generic ProgressBanner with a card showing Total Time and Progress.
class TotalProgressCard extends ConsumerWidget {
  final List<ExerciseWithProgress> allExercises;

  const TotalProgressCard({super.key, required this.allExercises});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTime = ref.watch(fitnessTotalTimeProvider);

    final total = allExercises.length;
    final completed = allExercises.where((e) => e.progress.isCompleted).length;
    final progressPercent = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F3FF), // Light blue background
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Total Time/Timer Section
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Total Time Spent',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(totalTime),
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 20),

            // 2. Progress Section
            Text(
              'Daily Progress',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF5CB85C), // Green for progress
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),

            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completed of $total Exercises Completed',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${(progressPercent * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5CB85C),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
