import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:elderly_prototype_app/features/fitness/providers/fitness_provider.dart';
import 'package:elderly_prototype_app/features/fitness/screens/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseListItem extends ConsumerWidget {
  final ExerciseWithProgress exerciseWithProgress;

  const ExerciseListItem({
    super.key,
    required this.exerciseWithProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = exerciseWithProgress.exercise;
    final progress = exerciseWithProgress.progress;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exerciseId: exercise.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Icon / Indicator (Slightly larger for elderly visibility)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: progress.isCompleted
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                progress.isCompleted
                    ? Icons.check_circle
                    : exercise.category.icon,
                color: progress.isCompleted
                    ? Colors.green.shade700
                    : _getCategoryColor(exercise.category),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // 2. Title and Subtitle (Wrapped in Expanded to prevent overflow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Slightly larger for readability
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Using a Wrap instead of a Row to handle long text/large fonts
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${exercise.duration.inMinutes} min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|',
                            style: TextStyle(color: Colors.grey.shade400)),
                      ),
                      Text(
                        exercise.category.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Status/Set Counter
            _buildSetCounter(context, progress),
          ],
        ),
      ),
    );
  }

  // Helper for consistent coloring
  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.stretching:
        return const Color(0xFFC86DD7);
      case ExerciseCategory.strength:
        return const Color(0xFF5CB85C);
      case ExerciseCategory.cardio:
        return const Color(0xFF337AB7);
      default:
        return Colors.grey;
    }
  }

  Widget _buildSetCounter(BuildContext context, ExerciseProgress progress) {
    final theme = Theme.of(context);

    if (progress.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(Icons.check_circle, color: Colors.green.shade700),
      );
    }

    return Container(
      constraints:
          const BoxConstraints(minWidth: 80), // Ensure consistent width
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        '${progress.timesCompleted} Sets',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
