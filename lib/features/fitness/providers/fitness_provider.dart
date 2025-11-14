import 'package:elderly_prototype_app/features/fitness/data/datasources/fitness_db_helper.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Database Provider ---
// Exposes the DB Helper instance (using the singleton)
final fitnessDbProvider = Provider<FitnessDatabaseHelper>((ref) {
  return FitnessDatabaseHelper();
});

// --- Category Filter Provider ---
// Holds the currently selected category chip
final fitnessCategoryFilterProvider =
    StateProvider<ExerciseCategory>((ref) => ExerciseCategory.all);

// --- Main Fitness Notifier ---
// Manages the list of exercises and all progress updates
final fitnessProvider = StateNotifierProvider<FitnessNotifier,
    AsyncValue<List<ExerciseWithProgress>>>((ref) {
  return FitnessNotifier(ref.watch(fitnessDbProvider));
});

class FitnessNotifier
    extends StateNotifier<AsyncValue<List<ExerciseWithProgress>>> {
  final FitnessDatabaseHelper _db;

  FitnessNotifier(this._db) : super(const AsyncLoading()) {
    _loadData();
  }

  // Initial data load
  Future<void> _loadData() async {
    try {
      final data = await _db.fetchAllExercisesWithProgress();
      state = AsyncData(data);
    } catch (e, s) {
      state = AsyncError(e, stackTrace: s);
    }
  }

  // Helper to update the state list without a full reload
  void _updateState(String exerciseId, ExerciseProgress newProgress) {
    // Get the current list of data
    final List<ExerciseWithProgress> currentData = state.value ?? [];

    // Find and update the specific exercise
    final updatedList = [
      for (final item in currentData)
        if (item.exercise.id == exerciseId)
          item.copyWith(progress: newProgress)
        else
          item,
    ];

    // Set the new state
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

  // ⭐️⭐️ FIX: THIS IS THE METHOD THE ERROR IS ABOUT ⭐️⭐️
  /// Fetches the current progress for a single exercise *synchronously* from the db helper.
  ExerciseProgress getExerciseProgress(String exerciseId) {
    // This calls the method on the database helper instance
    return _db.getExerciseProgress(exerciseId);
  }
}

// --------------------------------------------------------------------------
// --- Filtered List Provider ---
// --------------------------------------------------------------------------
// Returns a *filtered* list based on the main provider + category filter
final filteredFitnessListProvider =
    Provider<AsyncValue<List<ExerciseWithProgress>>>((ref) {
  final category = ref.watch(fitnessCategoryFilterProvider);
  final asyncList = ref.watch(fitnessProvider);

  return asyncList.when(
    data: (list) {
      if (category == ExerciseCategory.all) {
        return AsyncData(list);
      }
      final filteredList =
          list.where((item) => item.exercise.category == category).toList();
      return AsyncData(filteredList);
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, stackTrace: s),
  );
});

// --- Total Time Provider ---
// Calculates the total time spent today across all exercises
final fitnessTotalTimeProvider = Provider<int>((ref) {
  final asyncList = ref.watch(fitnessProvider);
  return asyncList.when(
    data: (list) {
      return list.fold<int>(
        0,
        (sum, item) => sum + item.progress.secondsTracked,
      );
    },
    loading: () => 0,
    error: (e, s) => 0,
  );
});
