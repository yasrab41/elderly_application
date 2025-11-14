// Defines the data models for the fitness feature.
import 'package:flutter/material.dart';

// Enum for filtering and categorization
enum ExerciseCategory {
  stretching(name: 'Stretching', icon: Icons.accessibility_new),
  strength(name: 'Strength', icon: Icons.fitness_center),
  cardio(name: 'Cardio', icon: Icons.directions_run),
  all(name: 'All Exercises', icon: Icons.list);

  final String name;
  final IconData icon;

  const ExerciseCategory({required this.name, required this.icon});
}

// Represents the core details of an exercise
class ExerciseModel {
  final String id;
  final String title;
  final String description;
  final ExerciseCategory category;
  final Duration duration; // Duration of the exercise
  final int difficultyLevel; // 1 (easy) to 5 (hard)
  final String instructions;
  final String imageUrl; // ⭐️ ADDED: For the detail screen image

  ExerciseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficultyLevel,
    required this.instructions,
    required this.imageUrl, // ⭐️ ADDED
  });
}

// Represents the user's progress for a specific exercise
class ExerciseProgress {
  final bool isCompleted;
  final int timesCompleted; // How many sets
  final int secondsTracked; // ⭐️ ADDED: For the timer

  ExerciseProgress({
    this.isCompleted = false,
    this.timesCompleted = 0,
    this.secondsTracked = 0, // ⭐️ ADDED
  });

  ExerciseProgress copyWith({
    bool? isCompleted,
    int? timesCompleted,
    int? secondsTracked,
  }) {
    return ExerciseProgress(
      isCompleted: isCompleted ?? this.isCompleted,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      secondsTracked: secondsTracked ?? this.secondsTracked, // ⭐️ ADDED
    );
  }
}

// Combines the core exercise with the user's progress
class ExerciseWithProgress {
  final ExerciseModel exercise;
  final ExerciseProgress progress;

  ExerciseWithProgress({
    required this.exercise,
    required this.progress,
  });

  ExerciseWithProgress copyWith({
    ExerciseModel? exercise,
    ExerciseProgress? progress,
  }) {
    return ExerciseWithProgress(
      exercise: exercise ?? this.exercise,
      progress: progress ?? this.progress,
    );
  }
}
