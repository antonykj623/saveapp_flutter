

import 'package:new_project_2025/model/insurance.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'insurance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE insurances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT NOT NULL,
        amount REAL DEFAULT 0.0,
        premium_amount REAL DEFAULT 0.0,
        insurance_type TEXT DEFAULT '',
        payment_frequency TEXT DEFAULT 'Monthly',
        payment_date INTEGER,
        closing_date INTEGER,
        remarks TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  // Insert insurance
  Future<int> insertInsurance(Insurance insurance) async {
    final db = await database;
    return await db.insert('insurances', insurance.toMap());
  }

  // Get all insurances
  Future<List<Insurance>> getInsurances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'insurances',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Insurance.fromMap(maps[i]));
  }

  // Get insurance by ID
  Future<Insurance?> getInsurance(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'insurances',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Insurance.fromMap(maps.first);
    }
    return null;
  }

  // Update insurance
  Future<int> updateInsurance(Insurance insurance) async {
    final db = await database;
    return await db.update(
      'insurances',
      insurance.toMap(),
      where: 'id = ?',
      whereArgs: [insurance.id],
    );
  }

  // Delete insurance
  Future<int> deleteInsurance(int id) async {
    final db = await database;
    return await db.delete(
      'insurances',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total amount
  Future<double> getTotalAmount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM insurances');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}