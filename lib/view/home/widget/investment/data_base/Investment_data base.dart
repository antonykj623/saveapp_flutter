import 'package:new_project_2025/view/home/widget/investment/model_class1/model_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'investments.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountName TEXT NOT NULL,
        amount REAL NOT NULL,
        dateOfPurchase INTEGER,
        remarks TEXT,
        documentPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminder_dates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        investmentId INTEGER NOT NULL,
        date INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (investmentId) REFERENCES investments (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertInvestment(InvestmentAsset investment) async {
    final db = await database;
    return await db.insert('investments', investment.toMap());
  }

  Future<List<InvestmentAsset>> getAllInvestments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('investments');
    
    List<InvestmentAsset> investments = [];
    for (var map in maps) {
      InvestmentAsset investment = InvestmentAsset.fromMap(map);
      investment.reminderDates = await getReminderDatesForInvestment(investment.id!);
      investments.add(investment);
    }
    return investments;
  }

  Future<InvestmentAsset?> getInvestment(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      InvestmentAsset investment = InvestmentAsset.fromMap(maps.first);
      investment.reminderDates = await getReminderDatesForInvestment(id);
      return investment;
    }
    return null;
  }

  Future<int> updateInvestment(InvestmentAsset investment) async {
    final db = await database;
    return await db.update(
      'investments',
      investment.toMap(),
      where: 'id = ?',
      whereArgs: [investment.id],
    );
  }

  Future<int> deleteInvestment(int id) async {
    final db = await database;
    await deleteReminderDatesForInvestment(id);
    return await db.delete(
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertReminderDate(ReminderDate reminderDate) async {
    final db = await database;
    return await db.insert('reminder_dates', reminderDate.toMap());
  }

  Future<List<ReminderDate>> getReminderDatesForInvestment(int investmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder_dates',
      where: 'investmentId = ?',
      whereArgs: [investmentId],
    );

    return List.generate(maps.length, (i) => ReminderDate.fromMap(maps[i]));
  }

  Future<int> deleteReminderDatesForInvestment(int investmentId) async {
    final db = await database;
    return await db.delete(
      'reminder_dates',
      where: 'investmentId = ?',
      whereArgs: [investmentId],
    );
  }

  Future<int> deleteReminderDate(int id) async {
    final db = await database;
    return await db.delete(
      'reminder_dates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}