import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class ExpenseAccountHelper {


  static Future<void> insertExpenseAccounts() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? value=await prefs.getInt("expenseaccountadded");

    if(value == null || value==0) {

      final List<String> expenseAccounts = [
      "Paper and periodicals",
      "Books and knowledge",
      "Education expenses",
      "Child care expenses",
      "Entertainments",
      "Hospital and healthcare",
      "Household items",
      "Utensils and kitchen items",
      "Furniture and fixtures",
      "Grocery and stationery",
      "Vegetables and meats",
      "Milk, bakery and snacks",
      "Agriculture expenses",
      "Telephone Expenses and recharges",
      "Electricity charges",
      "TV and internet charges",
      "Dress/clothing and footwear",
      "Personal care expenses",
      "Bank charges",
      "Interest paid expenses",
      "Tax/duties and levies",
      "Tolls",
      "Defaults and penalties",
      "Rent paid",
      "House maintenance expenses",
      "Conveyance",
      "Diesel/petrol charges",
      "Vehicle maintenance",
      "Tour and travelling expenses",
      "Hotel and outing Expenses",
      "Drinks and beverages",
      "Club and recreations",
      "Donations",
      "Charity",
      "Miscellaneous expenses",
    ];

    final currentYear = DateTime.now().year.toString();

    for (String accountName in expenseAccounts) {
      Map<String, dynamic> record = {
        'Accountname': accountName,
        'Accounttype': 'Expense Account',
        'Amount': '0',
        'Type': 'Debit',
        'year': currentYear,
      };

      final _databaseHelper = DatabaseHelper();
      await _databaseHelper.addData(
          "TABLE_ACCOUNTSETTINGS", jsonEncode(record));
    }
      await prefs.setInt('expenseaccountadded', 1);

    }
  }
}
