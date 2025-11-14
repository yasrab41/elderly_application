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

    // ⭐️ FIX: Style swapped to match the "You are doing great" card
    final cardColor =
        const Color(0xFF8D6E63); // Brown color from your reference image
    final titleColor = Colors.white; // White text for contrast

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: cardColor,
        elevation: 4, // Added elevation back
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onStart, // Start the workout on tap
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 20, 10, 20), // Adjusted padding to fit play button
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next workout',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise.duration.inMinutes} min',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ⭐️ FIX: Play button on the right
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color:
                        cardColor, // Use the card color for the icon contrast
                    size: 32,
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
