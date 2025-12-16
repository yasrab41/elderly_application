import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class HealthDatabaseHelper {
  static final HealthDatabaseHelper instance = HealthDatabaseHelper._init();
  static Database? _database;

  HealthDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('elderly_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            type TEXT NOT NULL,
            value1 REAL NOT NULL,
            value2 REAL,
            timestamp TEXT NOT NULL,
            note TEXT
          )
        ''');
      },
    );
  }

  Future<int> create(HealthRecord record) async {
    final db = await instance.database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> readRecords(String userId, String type) async {
    final db = await instance.database;
    final maps = await db.query(
      'health_records',
      where: 'userId = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'timestamp DESC', // Newest first
    );
    return maps.map((json) => HealthRecord.fromMap(json)).toList();
  }
}
