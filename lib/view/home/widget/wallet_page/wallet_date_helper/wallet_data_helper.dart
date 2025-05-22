import 'dart:async';
import 'dart:io';
import 'package:new_project_2025/view/home/widget/wallet_page/wallet_transation_class/wallet_transtion_class.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class WalletDatabaseHelper {
  static final WalletDatabaseHelper _instance = WalletDatabaseHelper._internal();
  static Database? _database;

  WalletDatabaseHelper._internal();

  static WalletDatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'wallet_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallet_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_wallet_date ON wallet_transactions(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_wallet_type ON wallet_transactions(type)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
    
    }
  }

  Future<int> insertWalletTransaction(WalletTransaction transaction) async {
    final db = await database;
    
    Map<String, dynamic> transactionMap = transaction.toMap();
    transactionMap['created_at'] = DateTime.now().toIso8601String();
    transactionMap['updated_at'] = DateTime.now().toIso8601String();
    
    try {
      return await db.insert(
        'wallet_transactions',
        transactionMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert wallet transaction: $e');
    }
  }


  Future<List<WalletTransaction>> getAllWalletTransactions() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        orderBy: 'date DESC, id DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get wallet transactions: $e');
    }
  }

  Future<List<WalletTransaction>> getWalletTransactionsByMonth(String yearMonth) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        where: 'date LIKE ?',
        whereArgs: ['$yearMonth%'],
        orderBy: 'date DESC, id DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get wallet transactions by month: $e');
    }
  }

  Future<List<WalletTransaction>> getWalletTransactionsByDateRange(
    String startDate, 
    String endDate
  ) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date DESC, id DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get wallet transactions by date range: $e');
    }
  }

  Future<double> getWalletOpeningBalance(String yearMonth) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT COALESCE(SUM(
          CASE 
            WHEN type = 'credit' THEN amount
            WHEN type = 'debit' THEN -amount
            ELSE 0
          END
        ), 0) as opening_balance
        FROM wallet_transactions 
        WHERE date < ?
      ''', ['$yearMonth-01']);

      return result.first['opening_balance']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get opening balance: $e');
    }
  }

  Future<double> getWalletClosingBalance(String yearMonth) async {
    final db = await database;
    
    try {
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      final nextYearMonth = '$nextYear-${nextMonth.toString().padLeft(2, '0')}';

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT COALESCE(SUM(
          CASE 
            WHEN type = 'credit' THEN amount
            WHEN type = 'debit' THEN -amount
            ELSE 0
          END
        ), 0) as closing_balance
        FROM wallet_transactions 
        WHERE date < ?
      ''', ['$nextYearMonth-01']);

      return result.first['closing_balance']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get closing balance: $e');
    }
  }

  // Get current wallet balance
  Future<double> getCurrentWalletBalance() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT COALESCE(SUM(
          CASE 
            WHEN type = 'credit' THEN amount
            WHEN type = 'debit' THEN -amount
            ELSE 0
          END
        ), 0) as current_balance
        FROM wallet_transactions
      ''');

      return result.first['current_balance']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get current balance: $e');
    }
  }

  // Update wallet transaction
  Future<int> updateWalletTransaction(WalletTransaction transaction) async {
    final db = await database;
    
    if (transaction.id == null) {
      throw Exception('Transaction ID is required for update');
    }

    Map<String, dynamic> transactionMap = transaction.toMap();
    transactionMap['updated_at'] = DateTime.now().toIso8601String();
    transactionMap.remove('id'); // Remove id from update map
    
    try {
      return await db.update(
        'wallet_transactions',
        transactionMap,
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      throw Exception('Failed to update wallet transaction: $e');
    }
  }

  // Delete wallet transaction
  Future<int> deleteWalletTransaction(int id) async {
    final db = await database;
    
    try {
      return await db.delete(
        'wallet_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete wallet transaction: $e');
    }
  }

  // Get wallet transaction by ID
  Future<WalletTransaction?> getWalletTransactionById(int id) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return WalletTransaction.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wallet transaction by ID: $e');
    }
  }

  // Get wallet transactions by type (credit/debit)
  Future<List<WalletTransaction>> getWalletTransactionsByType(String type) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'date DESC, id DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get wallet transactions by type: $e');
    }
  }

  // Get wallet transaction statistics for a month
  Future<Map<String, dynamic>> getWalletMonthlyStats(String yearMonth) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_transactions,
          COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credits,
          COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debits,
          COUNT(CASE WHEN type = 'credit' THEN 1 END) as credit_count,
          COUNT(CASE WHEN type = 'debit' THEN 1 END) as debit_count
        FROM wallet_transactions 
        WHERE date LIKE ?
      ''', ['$yearMonth%']);

      final stats = result.first;
      final totalCredits = stats['total_credits']?.toDouble() ?? 0.0;
      final totalDebits = stats['total_debits']?.toDouble() ?? 0.0;
      
      return {
        'total_transactions': stats['total_transactions'] ?? 0,
        'total_credits': totalCredits,
        'total_debits': totalDebits,
        'net_amount': totalCredits - totalDebits,
        'credit_count': stats['credit_count'] ?? 0,
        'debit_count': stats['debit_count'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get monthly stats: $e');
    }
  }

  // Search wallet transactions
  Future<List<WalletTransaction>> searchWalletTransactions(String query) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'wallet_transactions',
        where: 'description LIKE ? OR amount LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC, id DESC',
      );

      return List.generate(maps.length, (i) {
        return WalletTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search wallet transactions: $e');
    }
  }

  // Get all available months with transactions
  Future<List<String>> getAvailableMonths() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT DISTINCT substr(date, 1, 7) as year_month
        FROM wallet_transactions 
        ORDER BY year_month DESC
      ''');

      return result.map((row) => row['year_month'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get available months: $e');
    }
  }

  // Backup wallet data
  Future<List<Map<String, dynamic>>> backupWalletData() async {
    final db = await database;
    
    try {
      return await db.query('wallet_transactions', orderBy: 'id ASC');
    } catch (e) {
      throw Exception('Failed to backup wallet data: $e');
    }
  }

  // Restore wallet data
  Future<void> restoreWalletData(List<Map<String, dynamic>> backupData) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('wallet_transactions');
        
        // Insert backup data
        for (final data in backupData) {
          await txn.insert('wallet_transactions', data);
        }
      });
    } catch (e) {
      throw Exception('Failed to restore wallet data: $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Delete all wallet transactions (use with caution)
  Future<void> deleteAllWalletTransactions() async {
    final db = await database;
    
    try {
      await db.delete('wallet_transactions');
    } catch (e) {
      throw Exception('Failed to delete all wallet transactions: $e');
    }
  }
}