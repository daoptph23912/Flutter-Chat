import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/User.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        userName TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        avatar TEXT
      )
    ''');
  }

  Future<void> insertUser(User user) async {
    final Database db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String userName) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'userName = ?',
      whereArgs: [userName],
    );
    if (maps.isNotEmpty) {
      return User(
        userName: maps[0]['userName'],
        fullName: maps[0]['fullName'],
        avatar: maps[0]['avatar'],
      );
    } else {
      return null;
    }
  }

  Future<void> saveAvatarPath(String userName, String avatarPath) async {
    final db = await database;
    await db.update(
      'users',
      {'avatar': avatarPath},
      where: 'userName = ?',
      whereArgs: [userName],
    );
  }

  Future<String?> getAvatarPath(String userName) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['avatar'],
      where: 'userName = ?',
      whereArgs: [userName],
    );
    if (maps.isNotEmpty) {
      return maps[0]['avatar'] as String?;
    } else {
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User(
        userName: maps[i]['userName'],
        fullName: maps[i]['fullName'],
        avatar: maps[i]['avatar'],
      );
    });
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'userName = ?',
      whereArgs: [user.userName],
    );
  }

  Future<void> deleteUser(String userName) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'userName = ?',
      whereArgs: [userName],
    );
  }
}
