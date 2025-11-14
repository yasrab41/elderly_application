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
    final exercise =
        exerciseWithProgress.exercise; // Correctly accessing ExerciseModel
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            // 1. Icon / Indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: progress.isCompleted
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                progress.isCompleted
                    ? Icons.check_circle_outline
                    : exercise.category.icon,
                color: progress.isCompleted
                    ? Colors.green.shade700
                    : exercise.category == ExerciseCategory.stretching
                        ? const Color(0xFFC86DD7)
                        : exercise.category == ExerciseCategory.strength
                            ? const Color(0xFF5CB85C)
                            : const Color(0xFF337AB7),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // 2. Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${exercise.duration.inMinutes} min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '| ${exercise.category.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 3. Status/Set Counter
            _buildSetCounter(context, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildSetCounter(BuildContext context, ExerciseProgress progress) {
    final theme = Theme.of(context);
    if (progress.isCompleted) {
      return Text(
        'DONE',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${progress.timesCompleted} ${AppStrings.setsCompleted.split(':')[0]}', // Using AppStrings correctly
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// NOTE: The previous version might have had a separate _getCategoryIcon function. 
// We are now using the enum's built-in icon property (exercise.category.icon) 
// which is a more professional structure.