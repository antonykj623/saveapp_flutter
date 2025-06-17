import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Addaccountsdet extends StatefulWidget {
  const Addaccountsdet({super.key});

  @override
  State<Addaccountsdet> createState() => _SlidebleListState1();
}

class MenuItem {
  final String label;
  MenuItem(this.label);
}

class MenuItem1 {
  final String label1;
  MenuItem1(this.label1);
}

var items1 = [
  'Asset Account',
  'Bank',
  'Cash',
  'Credit Card',
  'Customers',
  'Expense Account',
  'Income Account',
  'Insurance',
  'Investment',
  'Liability Account',
];
var items2 = ['Debit', 'Credit'];
var items3 = ['2025', '2026', '2027', '2028', '2029', '2030'];

final _formKey = GlobalKey<FormState>();
final TextEditingController accountname = TextEditingController();
final TextEditingController catogory = TextEditingController();
final TextEditingController openingbalance = TextEditingController();
var dropdownvalu = '2025';
var dropdownvalu1 = 'Asset Account';
var dropdownvalu2 = 'Debit';

class _SlidebleListState1 extends State<Addaccountsdet> {
  // Function to generate entry ID
  String generateEntryId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Function to get next available setup ID
  Future<String> getNextSetupId() async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery(
        'SELECT MAX(CAST(ACCOUNTS_setupid AS INTEGER)) as max_id FROM TABLE_ACCOUNTS',
      );

      int maxId = 0;
      if (result.isNotEmpty && result.first['max_id'] != null) {
        maxId = result.first['max_id'] as int;
      }

      return (maxId + 1).toString();
    } catch (e) {
      // If error, start from 1
      return '1';
    }
  }

  // Function to get account type number
  int getAccountTypeNumber(String type) {
    return type.toLowerCase() == 'debit' ? 1 : 2;
  }

  // Function to get opening balance contra account setup ID
  String getOpeningBalanceContraSetupId(String accountType) {
    // For opening balance entries, we typically use:
    // - Setup ID 1 for the main account being created
    // - Setup ID 2 for the contra account (usually Opening Balance or Capital)
    switch (accountType.toLowerCase()) {
      case 'bank':
      case 'cash':
        return '2'; // Bank/Cash contra is typically Capital or Opening Balance
      case 'asset account':
      case 'investment':
        return '2'; // Asset contra is typically Capital or Opening Balance
      case 'liability account':
      case 'credit card':
        return '2'; // Liability contra is typically Capital or Opening Balance
      case 'expense account':
        return '2'; // Expense contra is typically Cash/Bank
      case 'income account':
        return '2'; // Income contra is typically Cash/Bank
      default:
        return '2';
    }
  }

  // Function to save double entry accounts
  Future<void> saveDoubleEntryAccounts() async {
    final accname = accountname.text;
    final accountType = dropdownvalu1;
    final openbalance = openingbalance.text;
    final type = dropdownvalu2;
    final currentDate = DateTime.now();
    final dateString =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final monthString = _getMonthName(currentDate.month);
    final yearString = currentDate.year.toString();
    final entryId = generateEntryId();

    try {
      final db = await DatabaseHelper().database;

      // Get the next setup ID for this account
      final setupId = await getNextSetupId();
      final contraSetupId = getOpeningBalanceContraSetupId(accountType);

      // First, save the account settings
      Map<String, dynamic> accountsetupData = {
        "Accountname": accname,
        "Accounttype": accountType,
        "OpeningBalance": openbalance,
        "Type": type,
      };

      await DatabaseHelper().addData(
        "TABLE_ACCOUNTSETTINGS",
        jsonEncode(accountsetupData),
      );

      // Create the main account entry (based on selected debit/credit)
      Map<String, dynamic> mainAccountEntry = {
        'ACCOUNTS_VoucherType': 1, // payment voucher
        'ACCOUNTS_entryid': entryId,
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': setupId, // Use the new setup ID for this account
        'ACCOUNTS_amount': openbalance,
        'ACCOUNTS_type': type.toLowerCase(), // Use selected type (debit/credit)
        'ACCOUNTS_remarks': 'Opening Balance for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype': getAccountTypeNumber(type).toString(),
        'ACCOUNTS_billId': '',
        'ACCOUNTS_billVoucherNumber': '',
      };

      // Create the contra entry (opposite side for double entry)
      Map<String, dynamic> contraEntry = {
        'ACCOUNTS_VoucherType': 1, // payment voucher
        'ACCOUNTS_entryid': entryId, // Same entry ID to link both entries
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': contraSetupId, // Contra account setup ID
        'ACCOUNTS_amount': openbalance,
        'ACCOUNTS_type':
            type.toLowerCase() == 'debit' ? 'credit' : 'debit', // Opposite type
        'ACCOUNTS_remarks': 'Opening Balance contra for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype':
            type.toLowerCase() == 'debit' ? '2' : '1', // Opposite type number
        'ACCOUNTS_billId': '',
        'ACCOUNTS_billVoucherNumber': '',
      };

      // Insert both entries to maintain double entry
      await db.insert('TABLE_ACCOUNTS', mainAccountEntry);
      await db.insert('TABLE_ACCOUNTS', contraEntry);

      print(
        'Main Account Entry - Setup ID: $setupId, Type: ${type.toLowerCase()}, Entry ID: $entryId',
      );
      print(
        'Contra Entry - Setup ID: $contraSetupId, Type: ${type.toLowerCase() == 'debit' ? 'credit' : 'debit'}, Entry ID: $entryId',
      );

      // Show success message
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Account saved with double entry successfully!'),
        ),
      );

      // Clear form
      accountname.clear();
      openingbalance.clear();
      setState(() {
        dropdownvalu1 = 'Asset Account';
        dropdownvalu2 = 'Debit';
      });

      // Return to previous screen with success result
      Navigator.pop(context as BuildContext, true);
    } catch (e) {
      print('Error saving account: $e');
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
    }
  }

  // Helper function to get month name
  String _getMonthName(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Add Account Setup', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Container(
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  enabled: true,
                  controller: accountname,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    hintText: "Account name",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    fillColor: const Color.fromARGB(0, 170, 30, 30),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: ShapeDecoration(
                    shape: BeveledRectangleBorder(
                      side: BorderSide(width: .5, style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    value: dropdownvalu1,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        items1.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    onChanged: (String? newValue2) {
                      setState(() {
                        dropdownvalu1 = newValue2!;
                        print("Account type selected: $dropdownvalu1");
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  textAlign: TextAlign.end,
                  enabled: true,
                  controller: openingbalance,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    hintText: "Enter Opening Balance",
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please add Opening Balance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    value: dropdownvalu2,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        items2.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    onChanged: (String? newValue1) {
                      setState(() {
                        dropdownvalu2 = newValue1!;
                        print("Account side selected: $dropdownvalu2");
                      });
                    },
                  ),
                ),
                const SizedBox(height: 90),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveDoubleEntryAccounts();
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
