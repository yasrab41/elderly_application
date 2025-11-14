import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/features/fitness/data/datasources/fitness_db_helper.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// 1. Provider for the Database Helper
final fitnessDbProvider = Provider((ref) => FitnessDatabaseHelper.instance);

// 2. Provider for the selected category filter
final fitnessCategoryFilterProvider =
    StateProvider<ExerciseCategory>((ref) => ExerciseCategory.all);

// 3. Provider for the filtered list of exercises
final filteredFitnessListProvider =
    Provider<AsyncValue<List<ExerciseWithProgress>>>((ref) {
  // Watch the main provider
  final fitnessState = ref.watch(fitnessProvider);
  // Watch the filter provider
  final filter = ref.watch(fitnessCategoryFilterProvider);

  return fitnessState.when(
    data: (list) {
      if (filter == ExerciseCategory.all) {
        return AsyncData(list);
      }
      // Filter the list based on the selected category
      final filteredList =
          list.where((item) => item.exercise.category == filter).toList();
      return AsyncData(filteredList);
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, stackTrace: s),
  );
});

// 4. The Main State Notifier Provider
final fitnessProvider = StateNotifierProvider<FitnessNotifier,
    AsyncValue<List<ExerciseWithProgress>>>((ref) {
  return FitnessNotifier(ref);
});

// 5. The State Notifier
class FitnessNotifier
    extends StateNotifier<AsyncValue<List<ExerciseWithProgress>>> {
  final Ref _ref;
  final FitnessDatabaseHelper _db;
  String? _userId;
  String _today = '';

  FitnessNotifier(this._ref)
      : _db = _ref.read(fitnessDbProvider),
        super(const AsyncLoading()) {
    _init();
  }

  // Get current date as 'YYYY-MM-DD' string
  String _getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Initialize and load data
  Future<void> _init() async {
    // 1. Get User ID from AuthService
    // Note: AuthService is typically outside the feature folder in lib/features/authentication/
    final user = _ref.read(authNotifierProvider);
    if (user == null) {
      state = AsyncError('User not logged in', stackTrace: StackTrace.empty);
      return;
    }
    _userId = user.uid;
    _today = _getTodayDate();

    // 2. Load data
    await loadData();
  }

  // Load data from database
  Future<void> loadData() async {
    state = const AsyncLoading();
    try {
      // 1. Initialize and seed database
      await _db.database;
      await _db.seedDatabase();

      // 2. Get static exercises and today's progress
      final staticExercises = await _db.getStaticExercises();
      final todayProgress = await _db.getTodayProgress(_userId!, _today);

      // 3. Merge the two lists
      final mergedList = staticExercises.map((exercise) {
        // Find progress for this exercise
        final progress = todayProgress.firstWhere(
          (p) => p.exerciseId == exercise.id,
          // If no progress found, create a default one
          orElse: () => ExerciseProgress(
            userId: _userId!,
            exerciseId: exercise.id,
            date: _today,
          ),
        );
        return ExerciseWithProgress(exercise: exercise, progress: progress);
      }).toList();

      state = AsyncData(mergedList);
    } catch (e, s) {
      state = AsyncError(e, stackTrace: s);
    }
  }

  // --- Methods to update progress (Auto-Save) ---

  // Update sets
  Future<void> updateSets(String exerciseId, int newSetCount) async {
    // Get the current progress object
    final currentProgress = _findProgressById(exerciseId).progress.copyWith(
          setsCompleted: newSetCount,
        );
    // Save to DB
    await _db.upsertExerciseProgress(currentProgress);
    // Update local state
    _updateStateWithNewProgress(exerciseId, currentProgress);
  }

  // Update time tracked
  Future<void> updateTime(String exerciseId, int newSeconds) async {
    final currentProgress = _findProgressById(exerciseId).progress.copyWith(
          secondsTracked: newSeconds,
        );
    await _db.upsertExerciseProgress(currentProgress);
    _updateStateWithNewProgress(exerciseId, currentProgress);
  }

  // Toggle exercise completion
  Future<void> toggleComplete(String exerciseId, int finalSeconds) async {
    final oldProgress = _findProgressById(exerciseId).progress;
    final newProgress = oldProgress.copyWith(
      isCompleted: !oldProgress.isCompleted,
      secondsTracked: finalSeconds, // Save the final time
    );
    await _db.upsertExerciseProgress(newProgress);
    _updateStateWithNewProgress(exerciseId, newProgress);
  }

  // --- Helper Methods ---

  // Find a specific exercise from the current state
  ExerciseWithProgress _findProgressById(String exerciseId) {
    return state.value!.firstWhere((e) => e.exercise.id == exerciseId);
  }

  // Update the notifier's state immutably
  void _updateStateWithNewProgress(
      String exerciseId, ExerciseProgress newProgress) {
    state.whenData((list) {
      final index = list.indexWhere((e) => e.exercise.id == exerciseId);
      if (index != -1) {
        // Create a new list with the updated item
        final newList = List<ExerciseWithProgress>.from(list);
        newList[index] = list[index].copyWith(newProgress: newProgress);
        state = AsyncData(newList);
      }
    });
  }
}
