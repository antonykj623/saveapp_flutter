import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('payments.db');
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
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        accountName TEXT NOT NULL, 
        amount REAL NOT NULL,
        paymentMode TEXT NOT NULL,
        remarks TEXT
      )
    ''');
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await instance.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getPaymentsByMonth(String yearMonth) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonth%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<int> deletePayment(int id) async {
    final db = await instance.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await instance.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }
}