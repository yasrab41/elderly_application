import 'package:elderly_prototype_app/core/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/exercise_model.dart';

//Handles all SQFlite interactions, including table creation, seeding the manual exercise data, and progress saving/loading.
class FitnessDatabaseHelper {
  FitnessDatabaseHelper._privateConstructor();
  static final FitnessDatabaseHelper instance =
      FitnessDatabaseHelper._privateConstructor();

  static Database? _database;
  static const String _dbName = 'fitness.db';
  static const String _staticExerciseTable = 'static_exercises';
  static const String _progressTable = 'exercise_progress';

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables on DB creation
  Future<void> _onCreate(Database db, int version) async {
    // 1. Create table for static exercise data
    await db.execute('''
      CREATE TABLE $_staticExerciseTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        difficulty TEXT,
        category TEXT,
        estimatedMinutes INTEGER,
        steps TEXT
      )
    ''');

    // 2. Create table for user's daily progress
    await db.execute('''
      CREATE TABLE $_progressTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        date TEXT NOT NULL,
        setsCompleted INTEGER DEFAULT 0,
        secondsTracked INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0,
        UNIQUE(userId, exerciseId, date) 
      )
    ''');
  }

  // --- Static Exercise Methods ---

  // Seed the database with our manual exercises
  Future<void> seedDatabase() async {
    final db = await database;
    // Check if data already exists
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_staticExerciseTable'));
    if (count == 0) {
      // Data doesn't exist, so insert it
      for (var exercise in _manualExercises) {
        await db.insert(_staticExerciseTable, exercise.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  // Get all static exercises
  Future<List<Exercise>> getStaticExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_staticExerciseTable);
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  // --- Exercise Progress Methods ---

  // Get today's progress for a specific user
  Future<List<ExerciseProgress>> getTodayProgress(
      String userId, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _progressTable,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
    );
    return List.generate(maps.length, (i) => ExerciseProgress.fromMap(maps[i]));
  }

  // Save or update progress (the "auto-save")
  Future<void> upsertExerciseProgress(ExerciseProgress progress) async {
    final db = await database;
    await db.insert(
      _progressTable,
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- MANUAL EXERCISE DATA ---
  // This is where you define all your exercises.
  // This list can be translated or modified easily.

  // ⭐️==========================================================
  // ⭐️ IMAGE LOCATION INSTRUCTIONS:
  // ⭐️ 1. Create a folder: `assets/images/` in your project root.
  // ⭐️ 2. Add your images (e.g., `neck_stretch.png`, `arm_circles.png`).
  // ⭐️ 3. Open `pubspec.yaml` and ensure the assets are declared:
  // ⭐️    flutter:
  // ⭐️      assets:
  // ⭐️        - assets/images/
  // ⭐️ 4. Change the `imageUrl` lines below from "https://placehold.co/..." to "assets/images/your_file_name.png"
  // ⭐️==========================================================

  static final List<Exercise> _manualExercises = [
    Exercise(
      id: 'stretch_01',
      title: 'Morning Neck Stretch',
      description: 'Gently stretch your neck muscles to relieve stiffness.',
      // ⭐️ Use a placeholder for now
      imageUrl: 'https://placehold.co/600x400/EAD9F7/48352A?text=Neck+Stretch',
      difficulty: AppStrings.difficultyEasy,
      category: ExerciseCategory.stretching,
      estimatedMinutes: 5,
      steps: [
        'Sit or stand tall, relaxing your shoulders.',
        'Slowly tilt your head to your right shoulder, holding for 15-20 seconds.',
        'Gently return to center.',
        'Slowly tilt your head to your left shoulder, holding for 15-20 seconds.',
        'Repeat 2-3 times on each side.',
      ],
    ),
    Exercise(
      id: 'strength_01',
      title: 'Seated Arm Circles',
      description: 'Strengthen your shoulders while seated.',
      imageUrl: 'https://placehold.co/600x400/D7E9CD/48352A?text=Arm+Circles',
      difficulty: AppStrings.difficultyEasy,
      category: ExerciseCategory.strength,
      estimatedMinutes: 8,
      steps: [
        'Sit upright in a sturdy chair.',
        'Extend both arms out to the sides at shoulder height.',
        'Make small circles forward for 30 seconds.',
        'Reverse direction and circle backward for 30 seconds.',
        'Rest and repeat 3 times.',
      ],
    ),
    Exercise(
      id: 'strength_02',
      title: 'Chair Squats',
      description: 'Build leg strength using a chair for support.',
      imageUrl: 'https://placehold.co/600x400/F7EAD9/48352A?text=Chair+Squats',
      difficulty: AppStrings.difficultyMedium,
      category: ExerciseCategory.strength,
      estimatedMinutes: 7,
      steps: [
        'Stand in front of a sturdy chair.',
        'Slowly lower yourself as if sitting down, but stop just before touching the seat.',
        'Keep your knees behind your toes.',
        'Push through your heels to stand back up.',
        'Repeat 10-12 times.',
      ],
    ),
    Exercise(
      id: 'cardio_01',
      title: 'Gentle Walking in Place',
      description: 'A light cardio exercise to get your heart rate up safely.',
      imageUrl:
          'https://placehold.co/600x400/D9F3F7/48352A?text=Walking+in+Place',
      difficulty: AppStrings.difficultyEasy,
      category: ExerciseCategory.cardio,
      estimatedMinutes: 10,
      steps: [
        'Stand next to a chair or wall for support.',
        'Lift one knee up, then the other, as if walking.',
        'Swing your arms naturally as you step.',
        'Continue for 2 minutes, then rest.',
        'Repeat 3-5 times throughout the day.',
      ],
    ),
    // You can add more exercises here!
  ];
}
