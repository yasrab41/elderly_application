import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/healthcare_facility_model.dart';

class HealthcareLocalDb {
  static final HealthcareLocalDb instance = HealthcareLocalDb._init();
  static Database? _database;

  HealthcareLocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nearby_healthcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        const facilityColumns = '''
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          name TEXT NOT NULL,
          district TEXT,
          neighborhood TEXT,
          street TEXT,
          buildingNo TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          phone TEXT,
          address TEXT,
          notes TEXT,
          isOnDuty INTEGER NOT NULL DEFAULT 0
        ''';
        await db.execute('CREATE TABLE facilities ($facilityColumns)');
        await db.execute('CREATE TABLE pharmacies ($facilityColumns)');
        await db.execute('''
          CREATE TABLE sync_meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> replaceFacilities(List<HealthcareFacilityModel> items) async {
    await _replaceTable('facilities', items, 'facilities_last_synced');
  }

  Future<void> replacePharmacies(List<HealthcareFacilityModel> items) async {
    await _replaceTable('pharmacies', items, 'pharmacies_last_synced');
  }

  Future<void> _replaceTable(
      String table, List<HealthcareFacilityModel> items, String syncKey) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete(table);
    for (final item in items) {
      batch.insert(table, item.toMap());
    }
    await batch.commit(noResult: true);
    await _setLastSyncedAt(syncKey, DateTime.now());
  }

  Future<List<HealthcareFacilityModel>> getFacilities() =>
      _getAll('facilities');

  Future<List<HealthcareFacilityModel>> getPharmacies() =>
      _getAll('pharmacies');

  Future<List<HealthcareFacilityModel>> _getAll(String table) async {
    final db = await instance.database;
    final maps = await db.query(table);
    return maps.map((m) => HealthcareFacilityModel.fromMap(m)).toList();
  }

  Future<void> _setLastSyncedAt(String key, DateTime time) async {
    final db = await instance.database;
    await db.insert(
      'sync_meta',
      {'key': key, 'value': time.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DateTime?> getLastSyncedAt(String key) async {
    final db = await instance.database;
    final result =
        await db.query('sync_meta', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return null;
    return DateTime.tryParse(result.first['value'] as String);
  }
}
