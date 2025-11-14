import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

// Assuming ExerciseCategory and related constants are imported
// from a model or constants file.

class CategoryCard extends StatelessWidget {
  final ExerciseCategory category;
  final String? titleOverride;
  final Color color;
  final Color iconColor;
  final IconData? icon; // Allows overriding the default icon
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.titleOverride,
    required this.color,
    required this.iconColor,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the icon and title to display
    final displayIcon = icon ?? _getCategoryIcon(category);
    final displayText = titleOverride ?? category.name;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              displayIcon,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .black87, // Ensure text is visible on colored background
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper to get icon based on category (FIXED ERROR 2 HERE) ---
  IconData _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.stretching:
        return Icons.self_improvement;
      case ExerciseCategory.strength:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      case ExerciseCategory
            .all: // Though 'all' is usually overridden, keep it covered
        return Icons.list_alt;
      default:
        // Replaced Icons.exercise with a valid icon constant
        return Icons.local_fire_department;
    }
  }
}
