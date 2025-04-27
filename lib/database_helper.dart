import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'today_work.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE works(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT)',
        );
      },
    );
  }

  Future<void> insertWork(String task) async {
    final db = await database;
    await db.insert(
      'works',
      {'task': task},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWorks() async {
    final db = await database;
    return await db.query('works');
  }

  Future<void> updateWork(int id, String newTask) async {
    final db = await database;
    await db.update(
      'works',
      {'task': newTask},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWork(int id) async {
    final db = await database;
    await db.delete(
      'works',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
