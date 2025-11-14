// 3 class: Exercise, ExerciseProgress, ExerciseWithProgress
// Defines the data structures for static content and daily progress.

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:flutter/material.dart';

// Enum for exercise categories, used for filtering
enum ExerciseCategory { all, stretching, strength, cardio }

// Extension to get a display-friendly string from the enum
extension ExerciseCategoryExtension on ExerciseCategory {
  String get name {
    switch (this) {
      case ExerciseCategory.stretching:
        return AppStrings.filterStretching;
      case ExerciseCategory.strength:
        return AppStrings.filterStrength;
      case ExerciseCategory.cardio:
        return AppStrings.filterCardio;
      case ExerciseCategory.all:
        return AppStrings.filterAll;
    }
  }
}

// 1. STATIC EXERCISE DATA
// This model represents the *definition* of an exercise.
// This data will be stored in the `static_exercises` table.
class Exercise {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String difficulty;
  final ExerciseCategory category;
  final int estimatedMinutes;
  final List<String> steps;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    required this.category,
    required this.estimatedMinutes,
    required this.steps,
  });

  // Convert Exercise object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'category': category.name, // Store category as string
      'estimatedMinutes': estimatedMinutes,
      'steps': steps.join('||'), // Store list of steps as a single string
    };
  }

  // Create Exercise object from a Map (from database)
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      difficulty: map['difficulty'],
      category:
          ExerciseCategory.values.firstWhere((e) => e.name == map['category']),
      estimatedMinutes: map['estimatedMinutes'],
      steps: (map['steps'] as String).split('||'), // Split string back to list
    );
  }
}

// 2. DYNAMIC EXERCISE PROGRESS
// This model represents the *user's progress* for a specific exercise on a specific day.
// This data will be stored in the `exercise_progress` table.
class ExerciseProgress {
  final int? id; // Database primary key
  final String userId;
  final String exerciseId;
  final String date; // Format: 'YYYY-MM-DD'
  final int setsCompleted;
  final int secondsTracked;
  final bool isCompleted;

  ExerciseProgress({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    this.setsCompleted = 0,
    this.secondsTracked = 0,
    this.isCompleted = false,
  });

  // Convert ExerciseProgress object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date,
      'setsCompleted': setsCompleted,
      'secondsTracked': secondsTracked,
      'isCompleted': isCompleted ? 1 : 0, // Store boolean as 0 or 1
    };
  }

  // Create ExerciseProgress object from a Map (from database)
  factory ExerciseProgress.fromMap(Map<String, dynamic> map) {
    return ExerciseProgress(
      id: map['id'],
      userId: map['userId'],
      exerciseId: map['exerciseId'],
      date: map['date'],
      setsCompleted: map['setsCompleted'],
      secondsTracked: map['secondsTracked'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Helper to create a copy with modified values
  ExerciseProgress copyWith({
    int? setsCompleted,
    int? secondsTracked,
    bool? isCompleted,
  }) {
    return ExerciseProgress(
      id: id,
      userId: userId,
      exerciseId: exerciseId,
      date: date,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      secondsTracked: secondsTracked ?? this.secondsTracked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// 3. UI HELPER CLASS
// This class combines the static exercise data with its dynamic progress.
// This is the main object the UI will use.
class ExerciseWithProgress {
  final Exercise exercise;
  final ExerciseProgress progress;

  ExerciseWithProgress({
    required this.exercise,
    required this.progress,
  });

  // Helper to create a copy with a new progress
  ExerciseWithProgress copyWith({
    ExerciseProgress? newProgress,
  }) {
    return ExerciseWithProgress(
      exercise: exercise,
      progress: newProgress ?? progress,
    );
  }
}
