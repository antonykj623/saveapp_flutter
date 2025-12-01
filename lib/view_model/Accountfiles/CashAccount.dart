import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class CashAccountHelper {
  static final List<String> cashAccounts = ["Cash"];
  static final List<String> bankAccounts = ["Bank"];

  /// MAIN METHOD: Ensures default Cash and Bank accounts exist
  /// Call this in your app initialization (main.dart or splash screen)
  static Future<void> ensureDefaultAccountsExist() async {
    try {
      print("🔍 Checking if default accounts exist in database...");

      // Check if accounts actually exist in database (not just SharedPreferences)
      bool cashExists = await _accountExistsInDatabase('Cash', 'Cash');
      bool bankExists = await _accountExistsInDatabase('Bank', 'Bank');

      print("💵 Cash account exists: $cashExists");
      print("🏦 Bank account exists: $bankExists");

      // Insert missing accounts
      if (!cashExists) {
        print("➕ Inserting Cash account...");
        await _insertCashAccount();
      } else {
        print("✅ Cash account already exists");
      }

      if (!bankExists) {
        print("➕ Inserting Bank account...");
        await _insertBankAccount();
      } else {
        print("✅ Bank account already exists");
      }

      print("✅ Default accounts check completed");
    } catch (e) {
      print("❌ Error ensuring default accounts: $e");
    }
  }

  /// Check if account exists in database
  static Future<bool> _accountExistsInDatabase(
    String accountName,
    String accountType,
  ) async {
    try {
      final accounts = await DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS");

      for (final acc in accounts) {
        if (acc["data"] == null || acc["data"].toString().isEmpty) continue;

        final Map<String, dynamic> data = jsonDecode(acc["data"]);
        final String name = (data['Accountname'] ?? '').toString().trim();
        final String type = (data['Accounttype'] ?? '').toString().trim();

        if (name.toLowerCase() == accountName.toLowerCase() &&
            type.toLowerCase() == accountType.toLowerCase()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error checking account existence: $e");
      return false;
    }
  }

  /// Insert Cash account
  static Future<void> _insertCashAccount() async {
    try {
      Map<String, dynamic> cashAccount = {
        'Accountname': 'Cash',
        'Accounttype': 'Cash',
        'balance': '0', // Using 'balance' to match Add_Acount.dart
        'Type': 'Debit',
        'year': DateTime.now().year.toString(),
      };

      await DatabaseHelper().addData(
        "TABLE_ACCOUNTSETTINGS",
        jsonEncode(cashAccount),
      );
      print("✅ Cash account inserted successfully");
    } catch (e) {
      print("❌ Error inserting cash account: $e");
    }
  }

  /// Insert Bank account
  static Future<void> _insertBankAccount() async {
    try {
      Map<String, dynamic> bankAccount = {
        'Accountname': 'Bank',
        'Accounttype': 'Bank',
        'balance': '0', // Using 'balance' to match Add_Acount.dart
        'Type': 'Debit',
        'year': DateTime.now().year.toString(),
      };

      await DatabaseHelper().addData(
        "TABLE_ACCOUNTSETTINGS",
        jsonEncode(bankAccount),
      );
      print("✅ Bank account inserted successfully");
    } catch (e) {
      print("❌ Error inserting bank account: $e");
    }
  }

  /// Insert default Cash and Bank accounts (LEGACY METHOD)
  /// Use ensureDefaultAccountsExist() instead
  @Deprecated('Use ensureDefaultAccountsExist() instead')
  static Future<void> insertDefaultAccounts() async {
    await ensureDefaultAccountsExist();
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use ensureDefaultAccountsExist() instead')
  static Future<void> insertCashAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? value = prefs.getInt("cashaccountadded");

    if (value == null || value == 0) {
      Map<String, dynamic> cashAccount = {
        'Accountname': 'Cash',
        'Accounttype': 'Cash',
        'balance': '0',
        'Type': 'Debit',
        'year': DateTime.now().year.toString(),
      };

      try {
        await DatabaseHelper().addData(
          "TABLE_ACCOUNTSETTINGS",
          jsonEncode(cashAccount),
        );
        print("Cash account inserted successfully.");
        await prefs.setInt('cashaccountadded', 1);
      } catch (e) {
        print("Error inserting cash account: $e");
      }
    }
  }

  /// Check if default accounts exist and return details
  static Future<Map<String, bool>> checkDefaultAccountsStatus() async {
    try {
      bool cashExists = await _accountExistsInDatabase('Cash', 'Cash');
      bool bankExists = await _accountExistsInDatabase('Bank', 'Bank');

      return {
        'cashExists': cashExists,
        'bankExists': bankExists,
        'bothExist': cashExists && bankExists,
      };
    } catch (e) {
      print("❌ Error checking default accounts status: $e");
      return {
        'cashExists': false,
        'bankExists': false,
        'bothExist': false,
      };
    }
  }

  /// Force re-insert default accounts (useful for recovery)
  static Future<void> forceReinsertDefaultAccounts() async {
    try {
      print("🔄 Force re-inserting default accounts...");

      // Delete existing Cash and Bank accounts
      final accounts = await DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS");
      
      for (final acc in accounts) {
        if (acc["data"] == null || acc["data"].toString().isEmpty) continue;

        final Map<String, dynamic> data = jsonDecode(acc["data"]);
        final String name = (data['Accountname'] ?? '').toString().trim();
        final String type = (data['Accounttype'] ?? '').toString().trim();

        if ((name == 'Cash' && type.toLowerCase() == 'cash') ||
            (name == 'Bank' && type.toLowerCase() == 'bank')) {
          await DatabaseHelper().deleteData('TABLE_ACCOUNTSETTINGS', acc['keyid']);
          print("🗑️ Deleted old $name account");
        }
      }

      // Re-insert
      await _insertCashAccount();
      await _insertBankAccount();

      // Reset SharedPreferences flags
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cashaccountadded', 1);
      await prefs.setInt('bankaccountadded', 1);

      print("✅ Default accounts force re-inserted successfully");
    } catch (e) {
      print("❌ Error force re-inserting accounts: $e");
    }
  }

  /// Get count of default accounts in database
  static Future<int> getDefaultAccountsCount() async {
    try {
      int count = 0;
      bool cashExists = await _accountExistsInDatabase('Cash', 'Cash');
      bool bankExists = await _accountExistsInDatabase('Bank', 'Bank');
      
      if (cashExists) count++;
      if (bankExists) count++;
      
      return count;
    } catch (e) {
      print("❌ Error getting default accounts count: $e");
      return 0;
    }
  }

  /// Repair/Fix missing default accounts
  static Future<void> repairDefaultAccounts() async {
    try {
      print("🔧 Repairing default accounts...");
      
      final status = await checkDefaultAccountsStatus();
      
      if (!status['cashExists']!) {
        print("⚠️ Cash account missing, adding...");
        await _insertCashAccount();
      }
      
      if (!status['bankExists']!) {
        print("⚠️ Bank account missing, adding...");
        await _insertBankAccount();
      }
      
      if (status['bothExist']!) {
        print("✅ Both default accounts already exist");
      } else {
        print("✅ Default accounts repaired successfully");
      }
    } catch (e) {
      print("❌ Error repairing default accounts: $e");
    }
  }
}