import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart'; // <-- UPDATED IMPORT

// Handles all SQLite CRUD operations.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final String tableName = 'reminders';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  // ... (rest of the file remains the same: _initDB, _createDB, CRUD methods) ...
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableName (
        id $idType,
        name $textType,
        dosage $textType,
        time $textType,
        isActive $boolType,
        notificationId $intType
      )
    ''');
  }

  // CREATE
  Future<MedicineReminder> create(MedicineReminder reminder) async {
    final db = await instance.database;
    final id = await db.insert(tableName, reminder.toMap());
    return reminder.copyWith(id: id);
  }

  // READ ALL
  Future<List<MedicineReminder>> readAllReminders() async {
    final db = await instance.database;
    final result = await db.query(tableName, orderBy: 'time ASC');
    return result.map((json) => MedicineReminder.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(MedicineReminder reminder) async {
    final db = await instance.database;
    return db.update(
      tableName,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
