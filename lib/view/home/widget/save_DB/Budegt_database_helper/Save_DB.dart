import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT NOT NULL,
        year INTEGER NOT NULL,
        month TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_TARGETCATEGORY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        iconimage BLOB,
        isCustom TEXT
      )
    ''');

    // ... (other tables as in your previous code)
  }

  Future<int> insertData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  Future<int> updateData(
    String tableName,
    Map<String, dynamic> data,
    int id,
    List<String> list,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> updateCategoryById(
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconImage': iconImage,
      'isCustom': isCustom,
    };
  }

  factory TargetCategory.fromMap(Map<String, dynamic> map) {
    return TargetCategory(
      id: map['id'],
      name: map['name'] ?? '',
      iconImage: map['iconImage'],
      isCustom: map['isCustom'] ?? false,
    );
  }

  TargetCategory copyWith({
    int? id,
    String? name,
    Uint8List? iconImage,
    IconData? iconData,
    bool? isCustom,
  }) {
    return TargetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconImage: iconImage ?? this.iconImage,
      iconData: iconData ?? this.iconData,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
