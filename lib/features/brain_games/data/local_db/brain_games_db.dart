import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_stat_model.dart';

class BrainGamesDB {
  static final BrainGamesDB instance = BrainGamesDB._init();
  static Database? _database;

  BrainGamesDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('brain_games.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memory_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        gameName TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        moves INTEGER NOT NULL,
        timeSeconds INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertStat(GameStat stat) async {
    final db = await instance.database;
    await db.insert('memory_stats', stat.toMap());
  }

  Future<List<Map<String, dynamic>>> getUserStats(String userId) async {
    final db = await instance.database;
    return await db.query(
      'memory_stats',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // Fetches aggregated stats for a specific game and user
  Future<Map<String, dynamic>> getGameStatsSummary(
      String userId, String gameName) async {
    final db = await instance.database;

    // 1. Get Overall Totals (Wins, Total Time, Avg Time)
    final overallResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalWins,
        SUM(timeSeconds) as totalTime,
        AVG(timeSeconds) as avgTime
      FROM memory_stats 
      WHERE userId = ? AND gameName = ?
    ''', [userId, gameName]);

    // 2. Get Best Times grouped by Difficulty
    final bestTimesResult = await db.rawQuery('''
      SELECT difficulty, MIN(timeSeconds) as bestTime
      FROM memory_stats
      WHERE userId = ? AND gameName = ?
      GROUP BY difficulty
    ''', [userId, gameName]);

    return {
      'overview': overallResult.isNotEmpty ? overallResult.first : {},
      'bestTimes': bestTimesResult,
    };
  }
}
