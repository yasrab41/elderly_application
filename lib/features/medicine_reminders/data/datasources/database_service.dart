import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:sqflite/sqflite.dart';

import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';

import 'package:path/path.dart';

// Handles all SQLite CRUD operations.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final String remindersTable = 'reminders';
  final String takenDosesTable = 'taken_doses'; // 1. New table name

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // 2. INCREMENT VERSION to 3
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // 3. Ensure onUpgrade is set
    );
  }

  Future _createDB(Database db, int version) async {
    // --- Create Reminders Table ---
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE $remindersTable (
        id $idType,
        name $textType,
        dosage $textType,
        times $textType, 
        startDate $textType,
        endDate $textType,
        isActive $boolType
      )
    ''');

    // 4. --- Create Taken Doses Table ---
    await _createTakenDosesTable(db);
  }

  // 5. --- New Table Creation Method ---
  Future<void> _createTakenDosesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $takenDosesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unique_dose_id TEXT NOT NULL,
        date_taken TEXT NOT NULL,
        UNIQUE(unique_dose_id, date_taken)
      )
    ''');
  }

  // 6. --- Handle Upgrading from v2 to v3 ---
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Logic from v1 to v2 (rebuild reminders table)
      await db.execute('DROP TABLE IF EXISTS $remindersTable');
      await _createDB(
          db, newVersion); // This will call _createTakenDosesTable too
    }
    if (oldVersion < 3) {
      // Logic from v2 to v3 (just add the new table)
      await _createTakenDosesTable(db);
    }
  }

  // --- 7. NEW: Get Taken Doses for Today ---
  Future<Set<String>> getTakenDosesForDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      takenDosesTable,
      columns: ['unique_dose_id'],
      where: 'date_taken = ?',
      whereArgs: [date],
    );

    // Convert the list of maps into a Set of strings
    return result.map((json) => json['unique_dose_id'] as String).toSet();
  }

  // --- 8. NEW: Mark a Dose as Taken ---
  Future<void> markDoseAsTaken(String uniqueDoseId, String dateTaken) async {
    final db = await instance.database;
    try {
      await db.insert(
        takenDosesTable,
        {
          'unique_dose_id': uniqueDoseId,
          'date_taken': dateTaken,
        },
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Ignore if it already exists
      );
    } catch (e) {
      debugPrint('Error marking dose as taken: $e');
    }
  }

  // --- Reminder CRUD (No Changes) ---

  // CREATE
  Future<MedicineReminder> create(MedicineReminder reminder) async {
    final db = await instance.database;
    final id = await db.insert(remindersTable, reminder.toMap());
    return reminder.copyWith(id: id);
  }

  // READ ALL
  Future<List<MedicineReminder>> readAllReminders() async {
    final db = await instance.database;
    final result = await db.query(remindersTable, orderBy: 'startDate ASC');
    return result.map((json) => MedicineReminder.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(MedicineReminder reminder) async {
    final db = await instance.database;
    return db.update(
      remindersTable,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
