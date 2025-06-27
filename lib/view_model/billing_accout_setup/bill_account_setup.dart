import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Addaccountsdet1 extends StatefulWidget {
  const Addaccountsdet1({super.key});

  @override
  State<Addaccountsdet1> createState() => _SlidebleListState1();
}

class MenuItem {
  final String label;
  MenuItem(this.label);
}

// Account types list
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

// Account side types
var items2 = ['Debit', 'Credit'];

class _SlidebleListState1 extends State<Addaccountsdet1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountname = TextEditingController();
  final TextEditingController openingbalance = TextEditingController();
  String dropdownvalu1 = 'Customers'; // Default to Customers for bills
  String dropdownvalu2 = 'Debit';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false); // Return false when cancelled
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Add Account Setup',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('Saving Account...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account Name Field
                      Text(
                        'Account Name:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: accountname,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Enter account name",
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter account name';
                          }
                          if (value.trim().length < 3) {
                            return 'Account name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Account Type Dropdown
                      Text(
                        'Account Type:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: dropdownvalu1,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.teal,
                            ),
                            items:
                                items1.map((String items) {
                                  return DropdownMenuItem<String>(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  dropdownvalu1 = newValue;
                                  print(
                                    "Account type selected: $dropdownvalu1",
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Opening Balance Field
                      Text(
                        'Opening Balance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: openingbalance,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixText: "₹ ",
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter opening balance';
                          }
                          final double? amount = double.tryParse(value.trim());
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          if (amount < 0) {
                            return 'Amount cannot be negative';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Account Side Dropdown
                      Text(
                        'Account Side:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: dropdownvalu2,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.teal,
                            ),
                            items:
                                items2.map((String items) {
                                  return DropdownMenuItem<String>(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  dropdownvalu2 = newValue;
                                  print(
                                    "Account side selected: $dropdownvalu2",
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Information Card
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This account will be available for selection in the billing module.',
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _saveAccount,
                        child: Text(
                          _isLoading ? "Saving..." : "Save Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accname = accountname.text.trim();
      final category = dropdownvalu1;
      final openbalance = openingbalance.text.trim();
      final type = dropdownvalu2;

      // Check if account name already exists
      final existingData = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      bool accountExists = false;

      for (var item in existingData) {
        try {
          Map<String, dynamic> dat = jsonDecode(item["data"]);
          String existingName =
              dat['Accountname']?.toString().toLowerCase() ?? '';
          if (existingName == accname.toLowerCase()) {
            accountExists = true;
            break;
          }
        } catch (e) {
          print('Error checking existing account: $e');
        }
      }

      if (accountExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account with name "$accname" already exists!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create account data
      Map<String, dynamic> accountsetupData = {
        "Accountname": accname,
        "Accounttype": category,
        "OpeningBalance": openbalance,
        "Type": type,
        "CreatedDate": DateTime.now().toIso8601String(),
      };

      // Save to database
      final result = await DatabaseHelper().addData(
        "TABLE_ACCOUNTSETTINGS",
        jsonEncode(accountsetupData),
      );

      print('Account saved: $accname, Result: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account "$accname" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        accountname.clear();
        openingbalance.clear();
        setState(() {
          dropdownvalu1 = 'Customers';
          dropdownvalu2 = 'Debit';
        });

        // Return to previous screen with success result
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    accountname.dispose();
    openingbalance.dispose();
    super.dispose();
  }
}
