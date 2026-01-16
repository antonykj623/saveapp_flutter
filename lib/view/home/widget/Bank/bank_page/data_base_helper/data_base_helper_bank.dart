import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Addaccountsdet1 extends StatefulWidget {
  final String defaultAccountType;

  const Addaccountsdet1({super.key, required this.defaultAccountType});

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

class _SlidebleListState1 extends State<Addaccountsdet1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountname = TextEditingController();
  final TextEditingController openingbalance = TextEditingController();

  var dropdownvalu = '2025';
  late String dropdownvalu1;
  late String dropdownvalu2;

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    String accountType = widget.defaultAccountType.toLowerCase();

    switch (accountType) {
      case 'bank':
        dropdownvalu1 = 'Bank';
        dropdownvalu2 = 'Debit';
        break;
      case 'cash':
        dropdownvalu1 = 'Cash';
        dropdownvalu2 = 'Debit';
        break;
      case 'asset':
        dropdownvalu1 = 'Asset Account';
        dropdownvalu2 = 'Debit';
        break;
      case 'liability':
        dropdownvalu1 = 'Liability Account';
        dropdownvalu2 = 'Credit';
        break;
      case 'income':
        dropdownvalu1 = 'Income Account';
        dropdownvalu2 = 'Credit';
        break;
      case 'expense':
        dropdownvalu1 = 'Expense Account';
        dropdownvalu2 = 'Debit';
        break;
      case 'customers':
        dropdownvalu1 = 'Customers';
        dropdownvalu2 = 'Debit';
        break;
      case 'credit card':
        dropdownvalu1 = 'Credit Card';
        dropdownvalu2 = 'Credit';
        break;
      case 'investment':
        dropdownvalu1 = 'Investment';
        dropdownvalu2 = 'Debit';
        break;
      case 'insurance':
        dropdownvalu1 = 'Insurance';
        dropdownvalu2 = 'Debit';
        break;
      default:
        dropdownvalu1 = 'Asset Account';
        dropdownvalu2 = 'Debit';
    }
  }

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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Add Account Setup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Name Field
                Text(
                  'Account Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: accountname,
                    decoration: InputDecoration(
                      hintText: 'Enter account name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Colors.teal[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Account Type Dropdown
                Text(
                  'Account Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: dropdownvalu1,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category, color: Colors.teal[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items:
                        items1.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalu1 = newValue!;
                        print("Account type selected: $dropdownvalu1");
                      });
                    },
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.teal[400],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Opening Balance Field
                Text(
                  'Opening Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: openingbalance,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter opening balance',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.monetization_on,
                        color: Colors.teal[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter opening balance';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Account Side Dropdown
                Text(
                  'Account Side',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: dropdownvalu2,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.teal[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items:
                        items2.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalu2 = newValue!;
                        print("Account side selected: $dropdownvalu2");
                      });
                    },
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.teal[400],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.teal.withOpacity(0.3),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Processing Data'),
                              backgroundColor: Colors.teal,
                            ),
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
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Clear form fields
                            accountname.clear();
                            openingbalance.clear();

                            // Reset to default values based on the original parameter
                            setState(() {
                              _setDefaultValues();
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
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// FILE: lib/view/home/widget/Bank/bank_page/data_base_helper/BankVoucher.dart
// BankVoucher Model Class

class BankVoucher {
  final int? id;
  final String date;
  final String debit;
  final String credit;
  final double amount;
  final String remarks;
  final String? transactionType;

  BankVoucher({
    this.id,
    required this.date,
    required this.debit,
    required this.credit,
    required this.amount,
    required this.remarks,
    this.transactionType,
  });

  // Convert BankVoucher to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'debit': debit,
      'credit': credit,
      'amount': amount,
      'remarks': remarks,
      'transactionType': transactionType,
    };
  }

  // Create BankVoucher from Map
  factory BankVoucher.fromMap(Map<String, dynamic> map) {
    return BankVoucher(
      id: map['id'],
      date: map['date'],
      debit: map['debit'],
      credit: map['credit'],
      amount: map['amount'],
      remarks: map['remarks'],
      transactionType: map['transactionType'],
    );
  }

  @override
  String toString() => 'BankVoucher(id: $id, date: $date, debit: $debit, credit: $credit, amount: $amount)';
}