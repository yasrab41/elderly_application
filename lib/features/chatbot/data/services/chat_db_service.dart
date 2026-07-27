import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';

class ChatDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'chat_history.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE chats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          message TEXT,
          is_user INTEGER,
          timestamp TEXT
        )
      ''');
    });
  }

  Future<void> insertMessage(ChatMessage chat) async {
    final db = await database;
    await db.insert('chats', chat.toMap());
  }

  Future<List<ChatMessage>> getMessages(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chats',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'timestamp ASC');
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }
}
