import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Addaccountsdet extends StatefulWidget {
  final String id;
  final Map<String, dynamic> accountData;
  final String?
  preselectedAccountType; // ✅ NEW: Accept preselected type from Add Receipt

  const Addaccountsdet({
    super.key,
    this.id = "0",
    this.accountData = const {},
    this.preselectedAccountType, // ✅ NEW: Parameter to receive Bank/Cash
  });

  @override
  State<Addaccountsdet> createState() => _SlidebleListState1();
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

class _SlidebleListState1 extends State<Addaccountsdet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountname = TextEditingController();
  final TextEditingController openingbalance = TextEditingController();

  String dropdownvalu1 = 'Asset Account';
  String dropdownvalu2 = 'Debit';

  String getAccountTypeDebitCredit(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'liability account':
      case 'credit card':
      case 'income account':
        return 'Credit';
      case 'asset account':
      case 'bank':
      case 'cash':
      case 'customers':
      case 'expense account':
      case 'insurance':
      case 'investment':
      default:
        return 'Debit';
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ FIX: Priority 1 - Check if preselected type was passed from Add Receipt page
    if (widget.preselectedAccountType != null && widget.id == "0") {
      // Auto-select Bank or Cash based on what was passed
      dropdownvalu1 = widget.preselectedAccountType!;
      dropdownvalu2 = getAccountTypeDebitCredit(dropdownvalu1);
      print('✅ Auto-selected account type from Add Receipt: $dropdownvalu1');
    } else {
      // Priority 2 - Load from SharedPreferences if no preselected type
      _loadPreferences();
    }

    // Load existing data if editing
    _loadExistingData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? preselectedAccountType = prefs.getString("account_type");

    if (preselectedAccountType != null && widget.id == "0") {
      setState(() {
        dropdownvalu1 = preselectedAccountType;
        dropdownvalu2 = getAccountTypeDebitCredit(dropdownvalu1);
      });
    }
  }

  void _loadExistingData() {
    if (widget.accountData.isNotEmpty) {
      setState(() {
        accountname.text = widget.accountData["Accountname"] ?? "";
        openingbalance.text =
            widget.accountData["balance"] ??
            widget.accountData["OpeningBalance"] ??
            widget.accountData["Amount"] ??
            "";
        dropdownvalu1 = widget.accountData["Accounttype"] ?? 'Asset Account';
        dropdownvalu2 =
            widget.accountData["Type"] ??
            getAccountTypeDebitCredit(dropdownvalu1);
      });
    }
  }

  @override
  void dispose() {
    accountname.dispose();
    openingbalance.dispose();
    super.dispose();
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
        title: Text(
          widget.id == "0" ? 'Add Account Setup' : 'Edit Account Setup',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============================================================
              // ACCOUNT NAME FIELD
              // ============================================================
              TextFormField(
                enabled: true,
                controller: accountname,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  hintText: "Account name",
                  labelText: "Account Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
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

              // ============================================================
              // ACCOUNT TYPE DROPDOWN
              // ============================================================
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
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
                        dropdownvalu2 = getAccountTypeDebitCredit(
                          dropdownvalu1,
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ============================================================
              // OPENING BALANCE FIELD
              // ============================================================
              TextFormField(
                textAlign: TextAlign.end,
                enabled: true,
                controller: openingbalance,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  hintText: "0.00",
                  labelText: "Opening Balance",
                  prefixText: "₹ ",
                  fillColor: Colors.white,
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

              // ============================================================
              // DEBIT/CREDIT TYPE (Auto-selected)
              // ============================================================
              InputDecorator(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  labelText: "Account Type",
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dropdownvalu2,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      "(Auto-selected)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ============================================================
              // SAVE/UPDATE BUTTON
              // ============================================================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );

                      final accname = accountname.text.trim();
                      final openbalance = openingbalance.text.trim();
                      final type = dropdownvalu2;

                      // Prepare account data
                      Map<String, dynamic> accountsetupData = {
                        "Accountname": accname,
                        "Accounttype": dropdownvalu1,
                        "balance": openbalance,
                        "Type": type,
                      };

                      int result = 0;
                      if (widget.id != "0" && widget.id.isNotEmpty) {
                        // Update existing account
                        Map<String, dynamic> updateData = {
                          "data": jsonEncode(accountsetupData),
                        };
                        result = await DatabaseHelper().update(
                          updateData,
                          widget.id,
                          "TABLE_ACCOUNTSETTINGS",
                        );
                        print(
                          "Updated account ID: ${widget.id}, Result: $result",
                        );
                      } else {
                        // Insert new account
                        result = await DatabaseHelper().addData(
                          "TABLE_ACCOUNTSETTINGS",
                          jsonEncode(accountsetupData),
                        );
                        print("Inserted new account, Result: $result");
                      }

                      if (result > 0 && mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.id == "0"
                                  ? 'Account "$accname" added successfully!'
                                  : 'Account "$accname" updated successfully!',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Clear SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove("account_type");

                        // ✅ FIX: Return account details to Add Receipt page
                        Navigator.pop(context, {
                          'success': true,
                          'accountName': accname,
                          'accountType':
                              dropdownvalu1, // Returns 'Bank', 'Cash', etc.
                          'isNewAccount': widget.id == "0",
                        });
                      } else {
                        throw Exception("Database operation failed");
                      }
                    } catch (e) {
                      print('Error saving account: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving account: $e'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  widget.id == "0" ? "Save" : "Update",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
