// A professional mock implementation for Fitness Database operations.
// This class simulates fetching and updating exercise progress data
// without connecting to an actual database (like SQLite or Firebase).

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';

import 'package:flutter/foundation.dart';

class FitnessDatabaseHelper {
  // Simulates a persistent store for progress data
  // Key: Exercise ID, Value: ExerciseProgress
  Map<String, ExerciseProgress> _progressStore = {
    'S1': ExerciseProgress(
        isCompleted: true, timesCompleted: 3, secondsTracked: 180),
    'T1': ExerciseProgress(
        isCompleted: false, timesCompleted: 1, secondsTracked: 60),
    'C1': ExerciseProgress(
        isCompleted: true, timesCompleted: 2, secondsTracked: 600),
    'S3': ExerciseProgress(
        isCompleted: false, timesCompleted: 0, secondsTracked: 0),
    'T2': ExerciseProgress(
        isCompleted: false, timesCompleted: 0, secondsTracked: 0),
  };

  // --- Singleton Pattern ---
  static final FitnessDatabaseHelper _instance =
      FitnessDatabaseHelper._internal();
  factory FitnessDatabaseHelper() => _instance;
  FitnessDatabaseHelper._internal();

  /// Simulates fetching all exercises with the user's current progress.
  Future<List<ExerciseWithProgress>> fetchAllExercisesWithProgress() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // ⭐️ FIX: Changed AppStrings.exercises to just exercises (the global list)
    final allExercises = exercises.map((exercise) {
      final progress = _progressStore[exercise.id] ?? ExerciseProgress();
      return ExerciseWithProgress(exercise: exercise, progress: progress);
    }).toList();

    return allExercises;
  }

  /// Simulates fetching the progress for a single exercise.
  ExerciseProgress getExerciseProgress(String exerciseId) {
    return _progressStore[exerciseId] ?? ExerciseProgress();
  }

  /// Simulates updating the time for a single exercise.
  Future<ExerciseProgress> updateTime(
      String exerciseId, int totalSeconds) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final progress = _progressStore[exerciseId] ?? ExerciseProgress();
    final newProgress = progress.copyWith(secondsTracked: totalSeconds);
    _progressStore[exerciseId] = newProgress;
    if (kDebugMode) {
      print('Updated time for $exerciseId: $totalSeconds seconds');
    }
    return newProgress;
  }

  /// Simulates updating the sets for a single exercise.
  Future<ExerciseProgress> updateSets(String exerciseId, int sets) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final progress = _progressStore[exerciseId] ?? ExerciseProgress();
    final newProgress = progress.copyWith(timesCompleted: sets);
    _progressStore[exerciseId] = newProgress;
    if (kDebugMode) {
      print('Updated sets for $exerciseId: $sets sets');
    }
    return newProgress;
  }

  /// Simulates toggling the completion status.
  /// ⭐️ FIX: Correct logic to set secondsTracked based on completion status.
  Future<ExerciseProgress> toggleComplete(
      String exerciseId, int finalSeconds) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final progress = _progressStore[exerciseId] ?? ExerciseProgress();

    final bool newIsCompleted = !progress.isCompleted;
    int newSecondsTracked = 0; // Default to 0 if incomplete

    if (newIsCompleted) {
      // If marking as COMPLETE, we save the final time.
      newSecondsTracked = finalSeconds;
    } else {
      // If marking as INCOMPLETE, we intentionally reset time to 0.
      newSecondsTracked = 0;
    }

    final newProgress = progress.copyWith(
      isCompleted: newIsCompleted,
      secondsTracked: newSecondsTracked,
      // We don't touch timesCompleted here, that's handled by updateSets
    );
    _progressStore[exerciseId] = newProgress;
    if (kDebugMode) {
      print(
          'Toggled complete for $exerciseId: ${newProgress.isCompleted}. Time set to: ${newProgress.secondsTracked}');
    }
    return newProgress;
  }
}
