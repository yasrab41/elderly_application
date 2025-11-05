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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // <-- INCREMENT VERSION
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // <-- ADD UPGRADE HANDLER
    );
  }

  // This is the new table structure
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE $tableName (
        id $idType,
        name $textType,
        dosage $textType,
        times $textType, 
        startDate $textType,
        endDate $textType,
        isActive $boolType
      )
    ''');
  }

  // This handles migrating from the old table
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // For simplicity, we drop the old table and create a new one.
      // In production, you would migrate data with ALTER TABLE.
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await _createDB(db, newVersion);
    }
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
    final result = await db.query(tableName,
        orderBy: 'startDate ASC'); // Order by new field
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
