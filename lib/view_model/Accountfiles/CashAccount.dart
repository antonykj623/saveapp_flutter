import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class CashAccountHelper {
  static final List<String> cashAccounts = ["Cash"];

  static Future<void> insertCashAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? value = await prefs.getInt("cashaccountadded");

    if (value == null || value == 0) {
      Map<String, dynamic> cashAccount = {
        'Accountname': 'Cash',
        'Accounttype': 'Cash',
        'Amount': '0',
        'Type': 'Debit',
        'year':
            DateTime.now().year
                .toString(), // optional, add only if your table has this column
      };

      try {
        final _databaseHelper = await DatabaseHelper().addData(
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
}
