import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BudgetDatabaseHelper {
  static final BudgetDatabaseHelper _instance =
      BudgetDatabaseHelper._internal();
  static Database? _database;

  BudgetDatabaseHelper._internal();

  factory BudgetDatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'budget.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT NOT NULL,
        year INTEGER NOT NULL,
        month TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  Future<List<Map<String, dynamic>>> getBudgets(
    String accountName,
    int year,
  ) async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'account_name = ? AND year = ?',
      whereArgs: [accountName, year],
      orderBy: 'month',
    );
  }

  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update('budgets', budget, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getAccountNames() async {
    final db = await database;
    final result = await db.query(
      'budgets',
      columns: ['DISTINCT account_name'],
    );
    return result.map((e) => e['account_name'] as String).toList();
  }
}

class BudgetClass {
  final int? id;
  final String accountName;
  final int year;
  final String month;
  final double amount;

  BudgetClass({
    this.id,
    required this.accountName,
    required this.year,
    required this.month,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_name': accountName,
      'year': year,
      'month': month,
      'amount': amount,
    };
  }

  factory BudgetClass.fromMap(Map<String, dynamic> map) {
    return BudgetClass(
      id: map['id'],
      accountName: map['account_name'],
      year: map['year'],
      month: map['month'],
      amount: map['amount'].toDouble(),
    );
  }
}
