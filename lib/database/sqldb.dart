import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class Sqldb {
  static Database? _db;

  // Create database if not created
  Future<Database?> get db async {
    _db ??= await initDb();
    return _db;
  }

  // Initialize database
  Future<Database> initDb() async {
    final String databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'germanquestions.db');
    Database mydb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return mydb;
  }

  // Create database
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_questions
      (question_index INTEGER PRIMARY KEY)
      ''');

    await db.execute('''
      CREATE TABLE analysed_questions
      (question_index INTEGER PRIMARY KEY, correct_count INTEGER DEFAULT 0, incorrect_count INTEGER DEFAULT 0)
      ''');

    await db.execute('''
      CREATE TABLE test_results
      (test_index INTEGER PRIMARY KEY AUTOINCREMENT, correct_count INTEGER DEFAULT 0, incorrect_count INTEGER DEFAULT 0)
      ''');

    if (kDebugMode) {
      print("----------------------Created---------------------------");
    }
  }

  // Upgrade database
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) print("onUpgrade");
  }

  // Read data from database
  Future<List<Map<String, dynamic>>> readData(String sql) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> response = await mydb!.rawQuery(sql);
    return response;
  }

  // Insert data from database
  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  // Update data from database
  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  // Delete data from database
  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  // Delete the database
  Future<void> deleteMyDb() async {
    _db?.close(); // Close db before delete
    String dbPath = await getDatabasesPath();
    String path = p.join(dbPath, 'germanquestions.db');

    await deleteDatabase(path);
    if (kDebugMode) print("Database deleted");
  }
}
