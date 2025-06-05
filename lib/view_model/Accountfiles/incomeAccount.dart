import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
class IncomeAccount {

 static Future<void> addIncomeAccount() async {

   SharedPreferences prefs = await SharedPreferences.getInstance();
   int value=await prefs.getInt("incomeaccountadded")!;

   if(value == null || value==0) {
     List<String> incomeAccounts = [
       "Salary",
       "Agriculture income",
       "Income from business",
       "Interest from investments",
       "Dividend from share and debentures",
       "Rent received",
       "Professional income",
       "Miscellaneous income"
     ];

     int year = DateTime
         .now()
         .year;

     for (int i = 0; i < incomeAccounts.length; i++) {
       Map<String, dynamic> accountData = {
         "Accountname": incomeAccounts[i],
         "Accounttype": "Income account",
         "Amount": "0",
         "Type": "Credit",
         "year": year.toString()
       };

       final _databaseHelper = await DatabaseHelper().addData(
           "CREATE_ACCOUNTSETTINGS", jsonEncode(accountData));
     }

     await prefs.setInt('incomeaccountadded', 1);
   }
  }


}