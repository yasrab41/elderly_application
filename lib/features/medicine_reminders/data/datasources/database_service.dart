import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:intl/intl.dart';

// Medicine Model Import
import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';

// --- NEW: Water Models Import ---
// Ensure this path matches where you placed your water_models.dart
import 'package:elderly_prototype_app/features/water_reminder/data/models/water_models.dart';

// Handles all SQLite CRUD operations.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final String remindersTable = 'reminders';
  final String takenDosesTable = 'taken_doses';
  // --- NEW: Water Tables ---
  final String waterLogsTable = 'water_logs';
  final String waterSettingsTable = 'water_settings';

  Future<Database> get database async {
    if (_database != null) return _database!;
    // If you have already run the app with 'reminders_v4.db',
    // change this to 'reminders_v5.db' to force creation of new water tables.
    _database = await _initDB('reminders_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create DB with userId columns
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // 1. Medicine Reminders Table
    await db.execute('''
      CREATE TABLE $remindersTable (
        id $idType,
        userId $textType, 
        name $textType,
        dosage $textType,
        times $textType, 
        startDate $textType,
        endDate $textType,
        isActive $boolType
      )
    ''');

    // 2. Taken Doses Table
    await db.execute('''
      CREATE TABLE $takenDosesTable (
        id $idType,
        userId $textType,
        unique_dose_id TEXT NOT NULL,
        date_taken TEXT NOT NULL,
        UNIQUE(userId, unique_dose_id, date_taken)
      )
    ''');

    // --- NEW: 3. Water Logs Table ---
    await db.execute('''
      CREATE TABLE $waterLogsTable (
        id $idType,
        userId $textType,
        amount $intType,
        timestamp $textType
      )
    ''');

    // --- NEW: 4. Water Settings Table ---
    // userId is the PRIMARY KEY because each user only has ONE settings row
    await db.execute('''
      CREATE TABLE $waterSettingsTable (
        userId TEXT PRIMARY KEY,
        dailyGoal $intType,
        intervalMinutes $intType,
        startTime $textType,
        endTime $textType,
        isEnabled $intType,
        isVibration $intType,
        soundType $textType
      )
    ''');
  }

  // ==========================================
  //      SECTION: MEDICINE FEATURES
  // ==========================================

  // --- Get Taken Doses ---
  Future<Set<String>> getTakenDosesForDate(String date, String userId) async {
    final db = await instance.database;
    final result = await db.query(
      takenDosesTable,
      columns: ['unique_dose_id'],
      where: 'date_taken = ? AND userId = ?',
      whereArgs: [date, userId],
    );

    return result.map((json) => json['unique_dose_id'] as String).toSet();
  }

  // --- Mark a Dose as Taken ---
  Future<void> markDoseAsTaken(
      String uniqueDoseId, String dateTaken, String userId) async {
    final db = await instance.database;
    try {
      await db.insert(
        takenDosesTable,
        {
          'unique_dose_id': uniqueDoseId,
          'date_taken': dateTaken,
          'userId': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      debugPrint('Error marking dose as taken: $e');
    }
  }

  // --- Reminder CRUD ---

  // CREATE
  Future<MedicineReminder> create(
      MedicineReminder reminder, String userId) async {
    final db = await instance.database;
    var map = reminder.toMap();
    map['userId'] = userId;

    final id = await db.insert(remindersTable, map);
    return reminder.copyWith(id: id);
  }

  // READ ALL
  Future<List<MedicineReminder>> readAllReminders(String userId) async {
    final db = await instance.database;
    final result = await db.query(remindersTable,
        where: 'userId = ?', whereArgs: [userId], orderBy: 'startDate ASC');
    return result.map((json) => MedicineReminder.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(MedicineReminder reminder, String userId) async {
    final db = await instance.database;
    return db.update(
      remindersTable,
      reminder.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [reminder.id, userId],
    );
  }

  // DELETE
  Future<int> delete(int id, String userId) async {
    final db = await instance.database;
    return await db.delete(
      remindersTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // ==========================================
  //      SECTION: WATER FEATURES (NEW)
  // ==========================================

  // --- Water Settings Methods ---

  Future<void> saveWaterSettings(WaterSettings settings) async {
    final db = await database;
    await db.insert(
      waterSettingsTable,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WaterSettings?> getWaterSettings(String userId) async {
    final db = await database;
    final maps = await db.query(
      waterSettingsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return WaterSettings.fromMap(maps.first);
    }
    return null; // Logic will handle defaults if null
  }

  // --- Water Log Methods ---

  Future<int> addWaterLog(WaterLog log) async {
    final db = await database;
    return await db.insert(waterLogsTable, log.toMap());
  }

  Future<void> deleteWaterLog(int id) async {
    final db = await database;
    await db.delete(waterLogsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WaterLog>> getTodayWaterLogs(String userId) async {
    final db = await database;
    final now = DateTime.now();

    // Construct simplified date strings for "start of today" and "end of today"
    // Note: This relies on the fact that DateTime.toIso8601String() is comparable.
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    // End of day is effectively the start of the next day for comparison purposes
    // Or we can just check if the timestamp string starts with YYYY-MM-DD
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .toIso8601String();

    final maps = await db.query(
      waterLogsTable,
      where: 'userId = ? AND timestamp BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );

    return maps.map((e) => WaterLog.fromMap(e)).toList();
  }
}
