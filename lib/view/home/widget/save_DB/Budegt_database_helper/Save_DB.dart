import 'dart:convert';

import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

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
    String path = join(await getDatabasesPath(), 'save.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE TABLE_TARGETCATEGORY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        iconimage BLOB,
        isCustom TEXT
      )
    ''');

    // ... (other tables as in your previous code)

    // Payment voucher table
    String CREATE_PAYMENTVOUCHER_TABLE =
        "CREATE TABLE TABLE_PAYMENTVOUCHER ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "voucherdata TEXT)";
    await db.execute(CREATE_PAYMENTVOUCHER_TABLE);

    // Insurance number table
    String CREATE_INSURANCE_NO =
        "CREATE TABLE INSURANCE_NO ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "insuranceNO TEXT)";
    await db.execute(CREATE_INSURANCE_NO);

    // Investment names table
    String CREATE_INVESTNAMES =
        "CREATE TABLE INVESTNAMES_TABLE ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "investname TEXT)";
    await db.execute(CREATE_INVESTNAMES);

    // Cash balance table
    String CREATE_CASHBALANCE =
        "CREATE TABLE CASHBALANCE_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "cashbalancedata TEXT)";
    await db.execute(CREATE_CASHBALANCE);

    // Loan table
    String CREATE_LOAN =
        "CREATE TABLE LOAN_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "loan_data TEXT)";
    await db.execute(CREATE_LOAN);

    // Receipt table
    String CREATE_RECEIPT =
        "CREATE TABLE RECEIPT_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "receipt_data TEXT)";
    await db.execute(CREATE_RECEIPT);

    // Document table
    String CREATE_DOCUMENT =
        "CREATE TABLE TABLE_DOCUMENT ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_DOCUMENT);

    // Wallet table
    String CREATE_WALLET =
        "CREATE TABLE TABLE_WALLET ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_WALLET);

    // Password table
    String CREATE_PASSWORD =
        "CREATE TABLE TABLE_PASSWORD ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_PASSWORD);

    // Visit card image table
    String CREATE_VISIT_CARD_IMAGE =
        "CREATE TABLE TABLE_VISITCARD_IMAGE ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data BLOB)";
    await db.execute(CREATE_VISIT_CARD_IMAGE);

    // Target category table

    // App PIN table
    String CREATE_APP_PIN =
        "CREATE TABLE TABLE_APP_PIN ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_APP_PIN);

    // Milestone table
    String CREATE_MILESTONE =
        "CREATE TABLE TABLE_MILESTONE ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_MILESTONE);

    // Accounts table
    String CREATE_TABLE_ACCOUNTS =
        "CREATE TABLE TABLE_ACCOUNTS ("
        "ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "ACCOUNTS_VoucherType INTEGER, "
        "ACCOUNTS_entryid TEXT, "
        "ACCOUNTS_date TEXT, "
        "ACCOUNTS_setupid TEXT, "
        "ACCOUNTS_amount TEXT, "
        "ACCOUNTS_type TEXT, "
        "ACCOUNTS_remarks TEXT, "
        "ACCOUNTS_year TEXT, "
        "ACCOUNTS_month TEXT, "
        "ACCOUNTS_cashbanktype TEXT, "
        "ACCOUNTS_billId TEXT, "
        "ACCOUNTS_billVoucherNumber TEXT)";
    await db.execute(CREATE_TABLE_ACCOUNTS);

    // Accounts receipt table
    String CREATE_TABLE_ACCOUNTS_RECEIPT =
        "CREATE TABLE TABLE_ACCOUNTS_RECEIPT ("
        "ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "ACCOUNTS_entryid TEXT, "
        "ACCOUNTS_date TEXT, "
        "ACCOUNTS_setupid TEXT, "
        "ACCOUNTS_amount TEXT, "
        "ACCOUNTS_type TEXT, "
        "ACCOUNTS_remarks TEXT, "
        "ACCOUNTS_year TEXT, "
        "ACCOUNTS_month TEXT, "
        "ACCOUNTS_cashbanktype TEXT)";
    await db.execute(CREATE_TABLE_ACCOUNTS_RECEIPT);

    // Asset table
    String CREATE_ASSET =
        "CREATE TABLE TABLE_ASSET ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_ASSET);

    // Liability table
    String CREATE_LIABILITY =
        "CREATE TABLE TABLE_LIABILITY ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_LIABILITY);

    // Insurance table
    String CREATE_INSURANCE =
        "CREATE TABLE TABLE_INSURANCE ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_INSURANCE);

    // Account settings table
    String CREATE_ACCOUNTSETTINGS =
        "CREATE TABLE TABLE_ACCOUNTSETTINGS ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_ACCOUNTSETTINGS);

    // Diary subject table
    String CREATE_DIARYSUBJECT =
        "CREATE TABLE DIARYSUBJECT_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_DIARYSUBJECT);

    // Budget table
    String CREATE_BUDGET =
        "CREATE TABLE TABLE_BUDGET ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_BUDGET);

    // Diary table
    String CREATE_DIARY =
        "CREATE TABLE DIARY_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_DIARY);

    // Investment table
    String CREATE_INVESTMENT =
        "CREATE TABLE INVESTMENT_table ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_INVESTMENT);

    // Task table
    String CREATE_TASK =
        "CREATE TABLE TABLE_TASK ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_TASK);

    // Visit card table
    String CREATE_VISITCARD =
        "CREATE TABLE TABLE_VISITCARD ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT, "
        "logoimage BLOB, "
        "cardimg BLOB)";
    await db.execute(CREATE_VISITCARD);

    // Target table
    String CREATE_TARGET =
        "CREATE TABLE TABLE_TARGET ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_TARGET);

    // Added amount milestone table
    String CREATE_ADDEDAMOUNT_MILESTONE =
        "CREATE TABLE TABLE_ADDEDAMOUNT_MILESTONE ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_ADDEDAMOUNT_MILESTONE);

    // Backup table
    String CREATE_BACKUP =
        "CREATE TABLE TABLE_BACKUP ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_BACKUP);

    // Renewal message table
    String CREATE_RENEWALMSG =
        "CREATE TABLE TABLE_RENEWALMSG ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_RENEWALMSG);

    // Web links table
    String CREATE_WEBLINKS =
        "CREATE TABLE TABLE_WEBLINKS ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_WEBLINKS);

    // Emergency table
    String CREATE_EMERGENCY =
        "CREATE TABLE TABLE_EMERGENCY ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_EMERGENCY);

    // Bill details table
    String CREATE_BILLDETAILS =
        "CREATE TABLE TABLE_BILLDETAILS ("
        "keyid INTEGER PRIMARY KEY AUTOINCREMENT, "
        "data TEXT)";
    await db.execute(CREATE_BILLDETAILS);
  }

  Future<int> addData(String table, String data) async {
    int insertedId = 0;
    try {
      final db = await database;

      Map<String, dynamic> values = {'data': data};
      insertedId = await db.insert(table, values);

      // Optional condition as in your Java code
    } catch (e) {
      // Handle error gracefully
      print("Database insert error: $e");
    }

    return insertedId;
  }

  Future<void> updateaccountdet(
    String accountname,
    String catogory,
    String openingbalance,
    String accountype,
    String year,
    String keyid,
  ) async {
    Database db = await database;

    Map<String, dynamic> accountData = {
      "Accountname": accountname,
      "Accounttype": catogory,
      "Amount": openingbalance,
      "Type": accountype,
      "year": year,
    };

    Map<String, dynamic> datatoupdata = {
      "keyid": keyid,
      "data": jsonEncode(accountData),
    };

    var res = await db.update(
      'TABLE_ACCOUNTSETTINGS',
      datatoupdata,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );
    // var res = await dbClient.rawUpdate("update TABLE_ACCOUNTSETTINGS SET data = 'jsonEncode(accountData)'   where keyid = $keyid ");

    if (res == 1) {
      print("Res is: $res.");
      print("updatedRes is: $res.");
    } else {
      print("not updated");
    }
  }

  // Budget operations

  Future<List<String>> getAccountNames() async {
    final db = await database;
    final result = await db.query('savedb', columns: ['DISTINCT account_name']);
    return result.map((e) => e['account_name'] as String).toList();
  }

  Future<int> insertData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> queryallacc() async {
    Database db = await database;
    var res = await db.query('TABLE_ACCOUNTSETTINGS');

    List<Map<String, dynamic>> s = res.toList();
    print("queryallacc datas are: $s");

    return s;
  }

  Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> updateData(
    String tableName,
    Map<String, dynamic> data,
    int id,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCategoryByName(
    String tableName,
    Map<String, dynamic> data,
    String oldName,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'data = ?',
      whereArgs: [oldName],
    );
  }

  Future<int> deleteData(String tableName, int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'keyid = ?', whereArgs: [id]);
  }

  Future<List<Dream>> getAllDreams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dreams_table',
    ); // Replace with your actual dreams table name

    return List.generate(maps.length, (i) {
      return Dream(
        name: maps[i]['name'],
        category: maps[i]['category'],
        investment: maps[i]['investment'],
        targetAmount: maps[i]['targetAmount'],
        savedAmount: maps[i]['savedAmount'],
        targetDate: DateTime.parse(maps[i]['targetDate']),
        notes: maps[i]['notes'],
      );
    });
  }

  Future<bool> _isCategoryUsed(String categoryName) async {
    try {
      // Check if this category has been marked as "added" in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      bool isTargetAdded = prefs.getBool('target_$categoryName') ?? false;

      // If it's marked as added, it means it's being used
      return isTargetAdded;
    } catch (e) {
      print('Error checking if category is used: $e');
      return false;
    }
  }
  Future<int> insertPayment(Payment payment) async {
  final db = await database;
  
  Map<String, dynamic> paymentData = {
    "date": payment.date,
    "accountName": payment.accountName,
    "amount": payment.amount,
    "paymentMode": payment.paymentMode,
    "remarks": payment.remarks,
  };
  
  return await db.insert(
    'TABLE_PAYMENTVOUCHER', 
    {'voucherdata': jsonEncode(paymentData)}
  );
}

// Update Payment method
Future<int> updatePayment(Payment payment) async {
  final db = await database;
  
  Map<String, dynamic> paymentData = {
    "date": payment.date,
    "accountName": payment.accountName,
    "amount": payment.amount,
    "paymentMode": payment.paymentMode,
    "remarks": payment.remarks,
  };
  
  return await db.update(
    'TABLE_PAYMENTVOUCHER',
    {'voucherdata': jsonEncode(paymentData)},
    where: 'keyid = ?',
    whereArgs: [payment.id],
  );
}

// Get payments by month
Future<List<Payment>> getPaymentsByMonth(String yearMonth) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('TABLE_PAYMENTVOUCHER');
  
  List<Payment> payments = [];
  
  for (var map in maps) {
    try {
      Map<String, dynamic> paymentData = jsonDecode(map['voucherdata']);
      String paymentDate = paymentData['date'];
      
      // Check if payment belongs to selected month
      if (paymentDate.startsWith(yearMonth)) {
        payments.add(Payment(
          id: map['keyid'],
          date: paymentData['date'],
          accountName: paymentData['accountName'],
          amount: double.parse(paymentData['amount'].toString()),
          paymentMode: paymentData['paymentMode'],
          remarks: paymentData['remarks'],
        ));
      }
    } catch (e) {
      print('Error parsing payment data: $e');
    }
  }
  
  return payments;
}

// Delete payment method
Future<int> deletePayment(int id) async {
  final db = await database;
  return await db.delete(
    'TABLE_PAYMENTVOUCHER',
    where: 'keyid = ?',
    whereArgs: [id],
  );
}
}


class TargetCategory {
  final int? id;
  final String name;
  final Uint8List? iconImage;
  final IconData? iconData;
  final bool isCustom;

  TargetCategory({
    this.id,
    required this.name,
    this.iconImage,
    this.iconData,
    this.isCustom = false,
  });
}
