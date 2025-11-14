import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class NextWorkoutCard extends StatelessWidget {
  final ExerciseWithProgress? exerciseWithProgress;
  final VoidCallback onStart;

  const NextWorkoutCard({
    super.key,
    required this.exerciseWithProgress,
    required this.onStart,
    // Removed progressPercent which was causing the error in FitnessScreen
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if there is an exercise to display
    if (exerciseWithProgress == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No exercises loaded yet.',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      );
    }

    // Correctly extract the ExerciseModel and Progress
    final exercise = exerciseWithProgress!.exercise;
    final progress = exerciseWithProgress!.progress;

    // Determine the card's background color based on completion status
    final cardColor = progress.isCompleted
        ? theme.colorScheme.tertiaryContainer // A lighter color for completed
        : const Color(0xFFC9C9FF); // A soothing lavender/purple for pending

    final titleColor = progress.isCompleted
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onStart,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.nextWorkoutTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.title, // Accessing via .exercise
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 18, color: titleColor.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise.duration.inMinutes} min',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: titleColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play Button
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    progress.isCompleted ? Icons.check : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
