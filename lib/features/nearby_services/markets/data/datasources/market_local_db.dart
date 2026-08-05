import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/market_facility_model.dart';

class MarketLocalDb {
  static final MarketLocalDb instance = MarketLocalDb._init();
  static Database? _database;

  MarketLocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nearby_markets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        const columns = '''
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          name TEXT NOT NULL,
          district TEXT,
          neighborhood TEXT,
          street TEXT,
          buildingNo TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          notes TEXT,
          scheduleDays TEXT
        ''';
        await db.execute('CREATE TABLE bazaars ($columns)');
        // Single-slot fallback cache for the live, location-centered
        // Overpass query — not a full city dataset, just "last known good".
        await db.execute('CREATE TABLE shops ($columns)');
        await db.execute('''
          CREATE TABLE sync_meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> replaceBazaars(List<MarketFacilityModel> items) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('bazaars');
    for (final item in items) {
      batch.insert('bazaars', item.toMap());
    }
    await batch.commit(noResult: true);
    await _setLastSyncedAt('bazaars_last_synced', DateTime.now());
  }

  Future<List<MarketFacilityModel>> getBazaars() => _getAll('bazaars');

  Future<void> replaceShops(List<MarketFacilityModel> items) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('shops');
    for (final item in items) {
      batch.insert('shops', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<MarketFacilityModel>> getShops() => _getAll('shops');

  Future<List<MarketFacilityModel>> _getAll(String table) async {
    final db = await instance.database;
    final maps = await db.query(table);
    return maps.map((m) => MarketFacilityModel.fromMap(m)).toList();
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
