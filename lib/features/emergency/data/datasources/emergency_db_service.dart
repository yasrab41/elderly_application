// lib/features/emergency/data/datasources/emergency_db_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class EmergencyDbService {
  static const String _tableName = 'emergency_contacts';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'elderly_care_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            is_primary INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // --- CRUD Operations ---

  // Get Contacts (User Specific)
  Future<List<EmergencyContact>> getContacts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'user_id = ?', // Filter by User ID
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => EmergencyContact.fromMap(maps[i]));
  }

  // Insert Contact
  Future<int> insertContact(EmergencyContact contact) async {
    final db = await database;

    // Logic: If setting as primary, remove primary status from others for this user
    if (contact.isPrimary) {
      await _clearPrimary(db, contact.userId);
    }

    return await db.insert(
      _tableName,
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update Contact
  Future<int> updateContact(EmergencyContact contact) async {
    final db = await database;

    if (contact.isPrimary) {
      await _clearPrimary(db, contact.userId);
    }

    return await db.update(
      _tableName,
      contact.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [contact.id, contact.userId],
    );
  }

  // Delete Contact
  Future<int> deleteContact(int id, String userId) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Helper: Uncheck 'isPrimary' for all user's contacts
  Future<void> _clearPrimary(Database db, String userId) async {
    await db.update(
      _tableName,
      {'is_primary': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
