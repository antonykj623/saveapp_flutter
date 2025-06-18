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
  String generateEntryId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

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
      return '1';
    }
  }

  int getAccountTypeNumber(String type) {
    return type.toLowerCase() == 'debit' ? 1 : 2;
  }

  String getOpeningBalanceContraSetupId(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
      case 'cash':
        return '2';
      case 'asset account':
      case 'investment':
        return '2';
      case 'liability account':
      case 'credit card':
        return '2';
      case 'expense account':
        return '2';
      case 'income account':
        return '2';
      default:
        return '2';
    }
  }

  Future<void> saveDoubleEntryAccounts() async {
    final accname = accountname.text.trim();
    final accountType = dropdownvalu1;
    final openbalance = openingbalance.text;
    final type = dropdownvalu2;

    if (accname.toLowerCase() == 'cash') {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Account name "Cash" is reserved. Please choose a different name.'),
        ),
      );
      return;
    }

    final currentDate = DateTime.now();
    final dateString =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final monthString = _getMonthName(currentDate.month);
    final yearString = currentDate.year.toString();
    final entryId = generateEntryId();

    try {
      final db = await DatabaseHelper().database;
      final setupId = await getNextSetupId();
      final contraSetupId = getOpeningBalanceContraSetupId(accountType);

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

      Map<String, dynamic> mainAccountEntry = {
        'ACCOUNTS_VoucherType': 1,
        'ACCOUNTS_entryid': "0",
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': setupId,
        'ACCOUNTS_amount': openbalance,
        'ACCOUNTS_type': type.toLowerCase(),  
        'ACCOUNTS_remarks': 'Opening Balance for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype': getAccountTypeNumber(type).toString(),
        'ACCOUNTS_billId': '',
        'ACCOUNTS_billVoucherNumber': '',
      };


//add to db

   var id=   await db.insert('TABLE_ACCOUNTS', mainAccountEntry);




      Map<String, dynamic> contraEntry = {
        'ACCOUNTS_VoucherType': 1,
        'ACCOUNTS_entryid': id.toString(),
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': contraSetupId,
        'ACCOUNTS_amount': openbalance,
        'ACCOUNTS_type':
            type.toLowerCase() == 'debit' ? 'credit' : 'debit',
        'ACCOUNTS_remarks': 'Opening Balance contra for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype':
            type.toLowerCase() == 'debit' ? '2' : '1',
        'ACCOUNTS_billId': '',
        'ACCOUNTS_billVoucherNumber': '',
      };

      await db.insert('TABLE_ACCOUNTS', contraEntry);

      print(
        'Main Account Entry - Setup ID: $setupId, Type: ${type.toLowerCase()}, Entry ID: $entryId',
      );
      print(
        'Contra Entry - Setup ID: $contraSetupId, Type: ${type.toLowerCase() == 'debit' ? 'credit' : 'debit'}, Entry ID: $entryId',
      );

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Account saved with double entry successfully!'),
        ),
      );

      accountname.clear();
      openingbalance.clear();
      setState(() {
        dropdownvalu1 = 'Asset Account';
        dropdownvalu2 = 'Debit';
      });

      Navigator.pop(context as BuildContext, true);
    } catch (e) {
      print('Error saving account: $e');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error saving account: $e')),
      );
    }
  }

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Add Account Setup', style: TextStyle(color: Colors.white)),
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
                    fillColor: const Color.fromARGB(0, 170, 30, 255),
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
                    items: items1.map((String items) {
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
                const SizedBox(height: 20),
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
                    items: items2.map((String items) {
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
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
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