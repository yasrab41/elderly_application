import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:intl/intl.dart';

import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';

// Handles all SQLite CRUD operations.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final String remindersTable = 'reminders';
  final String takenDosesTable = 'taken_doses';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders_v4.db'); // New DB name to be safe
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Start at v1 for the new DB
      onCreate: _createDB,
    );
  }

  // Create DB with userId columns from the start
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    // 1. Add userId to reminders table
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

    // 2. Add userId to taken_doses table and make the combo unique
    await db.execute('''
      CREATE TABLE $takenDosesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId $textType,
        unique_dose_id TEXT NOT NULL,
        date_taken TEXT NOT NULL,
        UNIQUE(userId, unique_dose_id, date_taken)
      )
    ''');
  }

  // --- 7. MODIFIED: Get Taken Doses ---
  Future<Set<String>> getTakenDosesForDate(String date, String userId) async {
    final db = await instance.database;
    final result = await db.query(
      takenDosesTable,
      columns: ['unique_dose_id'],
      where: 'date_taken = ? AND userId = ?', // 3. Filter by userId
      whereArgs: [date, userId],
    );

    return result.map((json) => json['unique_dose_id'] as String).toSet();
  }

  // --- 8. MODIFIED: Mark a Dose as Taken ---
  Future<void> markDoseAsTaken(
      String uniqueDoseId, String dateTaken, String userId) async {
    final db = await instance.database;
    try {
      await db.insert(
        takenDosesTable,
        {
          'unique_dose_id': uniqueDoseId,
          'date_taken': dateTaken,
          'userId': userId, // 4. Add userId
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      debugPrint('Error marking dose as taken: $e');
    }
  }

  // --- Reminder CRUD (All MODIFIED) ---

  // CREATE
  Future<MedicineReminder> create(
      MedicineReminder reminder, String userId) async {
    final db = await instance.database;
    // 5. Add userId to the map before inserting
    var map = reminder.toMap();
    map['userId'] = userId;

    final id = await db.insert(remindersTable, map);
    return reminder.copyWith(id: id);
  }

  // READ ALL
  Future<List<MedicineReminder>> readAllReminders(String userId) async {
    final db = await instance.database;
    // 6. Filter by userId
    final result = await db.query(remindersTable,
        where: 'userId = ?', whereArgs: [userId], orderBy: 'startDate ASC');
    return result.map((json) => MedicineReminder.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(MedicineReminder reminder, String userId) async {
    final db = await instance.database;
    // 7. Filter by userId
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
    // 8. Filter by userId
    return await db.delete(
      remindersTable,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }
}
