import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bus_stop_model.dart';

/// Local cache of the İzmir open-data bus stop dataset. The municipality
/// only refreshes the source data twice a day, so we cache it locally and
/// only re-fetch when the cache is stale (or empty) — this also keeps the
/// feature usable with no/poor signal.
class BusStopLocalDb {
  static final BusStopLocalDb instance = BusStopLocalDb._init();
  static Database? _database;

  BusStopLocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nearby_bus_stops.db');
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
          CREATE TABLE bus_stops (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            lines TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> replaceAllStops(List<BusStopModel> stops) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('bus_stops');
    for (final stop in stops) {
      batch.insert('bus_stops', stop.toMap());
    }
    await batch.commit(noResult: true);
    await setLastSyncedAt(DateTime.now());
  }

  Future<List<BusStopModel>> getAllStops() async {
    final db = await instance.database;
    final maps = await db.query('bus_stops');
    return maps.map((m) => BusStopModel.fromMap(m)).toList();
  }

  Future<void> setLastSyncedAt(DateTime time) async {
    final db = await instance.database;
    await db.insert(
      'sync_meta',
      {'key': 'bus_stops_last_synced', 'value': time.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DateTime?> getLastSyncedAt() async {
    final db = await instance.database;
    final result = await db.query(
      'sync_meta',
      where: 'key = ?',
      whereArgs: ['bus_stops_last_synced'],
    );
    if (result.isEmpty) return null;
    return DateTime.tryParse(result.first['value'] as String);
  }
}
