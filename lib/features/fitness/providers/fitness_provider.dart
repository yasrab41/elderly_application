import 'package:elderly_prototype_app/features/fitness/data/datasources/fitness_db_helper.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// ⭐️ CRITICAL CHANGE: Converted from FutureProvider to StateNotifierProvider
// This allows the UI to call methods to update the state.

// 1. Provider for the Notifier
final fitnessProvider = StateNotifierProvider<FitnessNotifier,
    AsyncValue<List<ExerciseWithProgress>>>((ref) {
  return FitnessNotifier(ref.read(fitnessDbProvider));
});

// 2. Provider for the DB Helper
final fitnessDbProvider = Provider((ref) => FitnessDatabaseHelper());

// 3. The Notifier class
class FitnessNotifier
    extends StateNotifier<AsyncValue<List<ExerciseWithProgress>>> {
  final FitnessDatabaseHelper _db;

  FitnessNotifier(this._db) : super(const AsyncLoading()) {
    _loadData();
  }

  // Load initial data from the database
  Future<void> _loadData() async {
    try {
      final data = await _db.fetchAllExercisesWithProgress();
      state = AsyncData(data);
    } catch (e, s) {
      state = AsyncError(e, stackTrace: s);
    }
  }

  // Helper to update state locally
  void _updateState(String exerciseId, ExerciseProgress newProgress) {
    // Get the current list of exercises
    final currentData = state.valueOrNull ?? [];
    if (currentData.isEmpty) return;

    // Create a new list with the updated progress
    final updatedList = currentData.map((item) {
      if (item.exercise.id == exerciseId) {
        return item.copyWith(progress: newProgress);
      }
      return item;
    }).toList();

    // Set the new list as the state
    state = AsyncData(updatedList);
  }

  // --- Methods for the UI to call (as seen in exercise_detail_screen.dart) ---

  Future<void> updateTime(String exerciseId, int totalSeconds) async {
    final newProgress = await _db.updateTime(exerciseId, totalSeconds);
    _updateState(exerciseId, newProgress);
  }

  Future<void> updateSets(String exerciseId, int sets) async {
    final newProgress = await _db.updateSets(exerciseId, sets);
    _updateState(exerciseId, newProgress);
  }

  Future<void> toggleComplete(String exerciseId, int finalSeconds) async {
    final newProgress = await _db.toggleComplete(exerciseId, finalSeconds);
    _updateState(exerciseId, newProgress);
  }
}

extension on AsyncValue<List<ExerciseWithProgress>> {
  get valueOrNull => null;
}

// --------------------------------------------------------------------------
// FILTERED VIEW PROVIDERS (These remain mostly the same)
// --------------------------------------------------------------------------

// 2. Filter State (Which category is currently selected)
final fitnessCategoryFilterProvider =
    StateProvider<ExerciseCategory>((ref) => ExerciseCategory.all);

// 3. Timer State (Total Time Spent Exercising)
final fitnessTotalTimeProvider = StateProvider<Duration>((ref) {
  final allExercises = ref.watch(fitnessProvider).value ?? [];
  if (allExercises.isEmpty) {
    return Duration.zero;
  }

  // Calculate total time from all progress items
  final totalSeconds = allExercises.fold<int>(
    0,
    (sum, item) => sum + item.progress.secondsTracked,
  );

  return Duration(seconds: totalSeconds);
});

// 4. Filtered List of Exercises
final filteredFitnessListProvider =
    Provider<AsyncValue<List<ExerciseWithProgress>>>((ref) {
  final allExercisesAsync = ref.watch(fitnessProvider);
  final selectedCategory = ref.watch(fitnessCategoryFilterProvider);

  return allExercisesAsync.whenData((allExercises) {
    if (selectedCategory == ExerciseCategory.all) {
      return allExercises;
    } else {
      return allExercises
          .where((e) => e.exercise.category == selectedCategory)
          .toList();
    }
  });
});
