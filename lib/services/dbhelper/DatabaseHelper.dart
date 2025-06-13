
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/receipt.dart';

class DatabaseHelper1 {
  static final DatabaseHelper1 instance = DatabaseHelper1._init();
  static Database? _database;

  DatabaseHelper1._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('receipts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        accountName TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentMode TEXT NOT NULL,
        remarks TEXT
      )
    ''');
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.insert('receipts', receipt.toMap());
  }

  Future<List<Receipt>> getReceiptsByMonth(String yearMonth) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'receipts',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonth%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  Future<int> deleteReceipt(int id) async {
    final db = await instance.database;
    return await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }
// Add this method to your DatabaseHelper class
Future<int> updateData(String tableName, Map<String, dynamic> data, int id) async {
  try {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  } catch (e) {
    print('Error updating data in $tableName: $e');
    return 0;
  }
}
}