import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Bank_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
    MaterialApp(
      title: 'Bank Voucher App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: BankVoucherListScreen(),
    );
  }
}

// Database Helper Class
class BankDatabase {
  static final BankDatabase _instance = BankDatabase._internal();
  static Database? _database;

  BankDatabase._internal();

  factory BankDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bank_voucher.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vouchers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        debit TEXT NOT NULL,
        amount REAL NOT NULL,
        credit TEXT NOT NULL,
        remarks TEXT
      )
    ''');
  }

  Future<int> insertVoucher(BankVoucher voucher) async {
    final db = await database;
    return await db.insert('vouchers', voucher.toMap());
  }

  Future<List<BankVoucher>> getVouchers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vouchers');
    return List.generate(maps.length, (i) {
      return BankVoucher.fromMap(maps[i]);
    });
  }

  Future<int> updateVoucher(BankVoucher voucher) async {
    final db = await database;
    return await db.update(
      'vouchers',
      voucher.toMap(),
      where: 'id = ?',
      whereArgs: [voucher.id],
    );
  }

  Future<int> deleteVoucher(int id) async {
    final db = await database;
    return await db.delete(
      'vouchers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Bank Voucher Model
class BankVoucher {
  int? id;
  String date;
  String debit;
  double amount;
  String credit;
  String? remarks;

  BankVoucher({
    this.id,
    required this.date,
    required this.debit,
    required this.amount,
    required this.credit,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'debit': debit,
      'amount': amount,
      'credit': credit,
      'remarks': remarks,
    };
  }

  factory BankVoucher.fromMap(Map<String, dynamic> map) {
    return BankVoucher(
      id: map['id'],
      date: map['date'],
      debit: map['debit'],
      amount: map['amount'],
      credit: map['credit'],
      remarks: map['remarks'],
    );
  }
}