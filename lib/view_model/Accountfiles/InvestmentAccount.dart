import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
class InvestmentAccount {
  static final List<String> investmentAccounts = [
    "My Saving",
  ];

  static Future<void> insertInvestmentAccount() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = await prefs.getInt("investmentaccountadded")!;
    if (value == null || value == 0) {

      Map<String, dynamic> investmentAccount = {
        'Accountname': 'My Saving',
        'Accounttype': 'Investment',
        'Amount': '0',
        'Type': 'Debit',
        'year': DateTime
            .now()
            .year
            .toString(),
      };

      try {
        final db = await DatabaseHelper().database;
        final _databaseHelper = await DatabaseHelper().addData(
            "CREATE_ACCOUNTSETTINGS", jsonEncode(investmentAccount));
        print("Investment account inserted.");
        await prefs.setInt('investmentaccountadded', 1);
      } catch (e) {
        print("Error inserting investment account: $e");
      }
    }
  }
}