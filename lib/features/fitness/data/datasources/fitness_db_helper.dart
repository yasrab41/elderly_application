// Uses SQFlite for persistent local storage of fitness progress.

import 'dart:async';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/fitness/data/models/exercise_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FitnessDatabaseHelper {
  // --- SQFlite Instances ---
  late Database _database;
  late bool _isInitialized = false;
  final String _tableName = 'exerciseProgress';
  final String _databaseName = 'fitness_db.db';

  // --- Singleton Pattern ---
  static final FitnessDatabaseHelper _instance =
      FitnessDatabaseHelper._internal();
  factory FitnessDatabaseHelper() => _instance;
  FitnessDatabaseHelper._internal();

  /// Initializes SQFlite database and opens the connection.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _databaseName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            '''
            CREATE TABLE $_tableName(
              id TEXT PRIMARY KEY,
              isCompleted INTEGER,
              timesCompleted INTEGER,
              secondsTracked INTEGER,
              lastUpdateDate INTEGER
            )
            ''',
          );
        },
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('SQFlite database initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SQFlite: $e');
      }
      // Re-throw the error so the provider can handle the failure
      rethrow;
    }
  }

  // --- Data Loading and Reset Logic ---

  /// Loads all progress from SQFlite
  Future<Map<String, ExerciseProgress>> _loadAllProgress() async {
    if (!_isInitialized) await initialize();

    final progressMap = <String, ExerciseProgress>{};
    try {
      final List<Map<String, dynamic>> maps = await _database.query(_tableName);

      for (var map in maps) {
        final progress = ExerciseProgress.fromSqlite(map);
        progressMap[map['id'] as String] = progress;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading progress from SQFlite: $e');
      }
    }
    return progressMap;
  }

  /// This helper finds the progress for an exercise from the map, applying the daily reset check.
  ExerciseProgress _getResettableProgress(
      String exerciseId, Map<String, ExerciseProgress> progressMap) {
    // Get the current saved progress, or initial if none exists
    final progress = progressMap[exerciseId] ?? ExerciseProgress.initial();

    // Check if the progress was last updated on a different day
    final now = DateTime.now();
    final lastUpdate = progress.lastUpdateDate;

    final isNewDay = now.year != lastUpdate.year ||
        now.month != lastUpdate.month ||
        now.day != lastUpdate.day;

    if (isNewDay) {
      // If it's a new day, reset all progress metrics to 0/false,
      // but preserve the old lastUpdateDate until a new action is saved.
      return ExerciseProgress(
        isCompleted: false,
        timesCompleted: 0,
        secondsTracked: 0,
        lastUpdateDate: lastUpdate,
      );
    }
    return progress;
  }

  /// Simulates fetching all exercises with the user's current progress.
  Future<List<ExerciseWithProgress>> fetchAllExercisesWithProgress() async {
    if (!_isInitialized) await initialize();

    final progressMap = await _loadAllProgress();

    final allExercises = exercises.map((exercise) {
      // Use the helper to check for and apply daily reset
      final progress = _getResettableProgress(exercise.id, progressMap);
      return ExerciseWithProgress(exercise: exercise, progress: progress);
    }).toList();

    return allExercises;
  }

  /// Fetches the progress for a single exercise synchronously (Placeholder, relies on provider state).
  ExerciseProgress getExerciseProgress(String exerciseId) {
    return ExerciseProgress.initial();
  }

  // --- Data Saving ---

  Future<ExerciseProgress> _saveProgress(
      String exerciseId, ExerciseProgress newProgress) async {
    if (!_isInitialized) await initialize();

    // Ensure the lastUpdateDate is set to NOW when saving to mark this moment
    final finalProgress = newProgress.copyWith(lastUpdateDate: DateTime.now());

    try {
      // Use ConflictAlgorithm.replace to either insert a new record or update an existing one
      await _database.insert(
        _tableName,
        finalProgress.toSqlite(exerciseId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) {
        print('Saved progress for $exerciseId to SQFlite.');
      }
      return finalProgress;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving progress for $exerciseId: $e');
      }
      // Return the desired progress even if save fails, to update local state
      return finalProgress;
    }
  }

  /// Updates the time for a single exercise.
  Future<ExerciseProgress> updateTime(
      String exerciseId, int totalSeconds) async {
    // Load current state to base the update on
    final initialProgress =
        (await _loadAllProgress())[exerciseId] ?? ExerciseProgress.initial();

    // Check for daily reset on the read
    final progress =
        _getResettableProgress(exerciseId, {exerciseId: initialProgress});

    // Simple logic: Mark complete if time exceeds 90% of target duration
    final targetDuration =
        exercises.firstWhere((e) => e.id == exerciseId).duration.inSeconds;
    final isNowComplete = totalSeconds >= (targetDuration * 0.9);

    final newProgress = progress.copyWith(
      secondsTracked: totalSeconds,
      isCompleted: isNowComplete,
    );
    return await _saveProgress(exerciseId, newProgress);
  }

  /// Updates the sets for a single exercise.
  Future<ExerciseProgress> updateSets(String exerciseId, int sets) async {
    final initialProgress =
        (await _loadAllProgress())[exerciseId] ?? ExerciseProgress.initial();
    final progress =
        _getResettableProgress(exerciseId, {exerciseId: initialProgress});

    final newProgress = progress.copyWith(timesCompleted: sets);
    return await _saveProgress(exerciseId, newProgress);
  }

  /// Toggles the completion status.
  Future<ExerciseProgress> toggleComplete(
      String exerciseId, int finalSeconds) async {
    final initialProgress =
        (await _loadAllProgress())[exerciseId] ?? ExerciseProgress.initial();
    final progress =
        _getResettableProgress(exerciseId, {exerciseId: initialProgress});

    final bool newIsCompleted = !progress.isCompleted;
    int newSecondsTracked = newIsCompleted ? finalSeconds : 0;

    // Update completed status and time
    final newProgress = progress.copyWith(
      isCompleted: newIsCompleted,
      secondsTracked: newSecondsTracked,
    );

    return await _saveProgress(exerciseId, newProgress);
  }
}
