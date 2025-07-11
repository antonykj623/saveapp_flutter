
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:path/path.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


class Addaccountsdet1 extends StatefulWidget {
  const Addaccountsdet1({super.key, required String defaultAccountType,});

  @override
  State<Addaccountsdet1> createState() => _SlidebleListState1();
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

class _SlidebleListState1 extends State<Addaccountsdet1> {
  String generateEntryId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
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
        title: const Text(
          'Add Account Setup',
          style: TextStyle(color: Colors.white),
        ),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')),
                            );

                            final accname = accountname.text;
                            final catogory = dropdownvalu1;
                            final openbalance = openingbalance.text;
                            final type = dropdownvalu2;

                            Map<String, dynamic> accountsetupData = {
                              "Accountname": accname,
                              "Accounttype": dropdownvalu1,
                              "OpeningBalance": openbalance,
                              "Type": type,
                            };

                            // Save to database
                            await DatabaseHelper().addData(
                              "TABLE_ACCOUNTSETTINGS",
                              jsonEncode(accountsetupData),
                            );

                            print('account name is ...$accname');

                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Account "$accname" added successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Clear form fields
                              accountname.clear();
                              openingbalance.clear();
                              setState(() {
                                dropdownvalu1 = 'Asset Account';
                                dropdownvalu2 = 'Debit';
                              });

                              // Return true to indicate success and pop the page
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            print('Error saving account: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error saving account: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
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




class BankVoucher {
  int? id;
  String date;
  String debit;
  double amount;
  String credit;
  String? remarks;

  BankVoucher({
    this.id,
    required this.date,
    required this.debit,
    required this.amount,
    required this.credit,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'debit': debit,
      'amount': amount,
      'credit': credit,
      'remarks': remarks,
    };
  }

  factory BankVoucher.fromMap(Map<String, dynamic> map) {
    return BankVoucher(
      id: map['id'],
      date: map['date'],
      debit: map['debit'],
      amount: map['amount'],
      credit: map['credit'],
      remarks: map['remarks'],
    );
  }
}