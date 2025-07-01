import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/billing_accout_setup/bill_account_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBill extends StatefulWidget {
  final Payment? payment;

  const AddBill({super.key, this.payment});

  @override
  State<AddBill> createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate = DateTime.now();
  String? selectedAccount;
  String? selectedIncomeAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  List<String> accountNames = [];
  List<String> incomeAccountNames = [];

  @override
  void initState() {
    super.initState();
    _incrementCounterAutomatically();
    _loadAccountsFromDB();
  }

  Future<void> _incrementCounterAutomatically() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('bill_counter') ?? 0;
    counter++;
    await prefs.setInt('bill_counter', counter);
    setState(() {
      _counter = counter;
    });
  }

  Future<void> _loadAccountsFromDB() async {
    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
      print("Loading accounts from DB: ${data.length} records found");

      setState(() {
        accountNames.clear();
        incomeAccountNames.clear();

        for (var item in data) {
          try {
            Map<String, dynamic> dat = jsonDecode(item["data"]);
            String accountType = dat['Accounttype']?.toString() ?? '';
            String accountName = dat['Accountname']?.toString() ?? '';

            print("Account: $accountName, Type: $accountType");

            if (accountType.toLowerCase().contains("customers")) {
              accountNames.add(accountName);
              print("Added to customer accounts: $accountName");
            } else if (accountType.toLowerCase().contains("income account")) {
              incomeAccountNames.add(accountName);
              print("Added to income accounts: $accountName");
            }
          } catch (e) {
            print("Error parsing account data: $e");
          }
        }

        selectedAccount = accountNames.isNotEmpty ? accountNames[0] : null;
        selectedIncomeAccount =
            incomeAccountNames.isNotEmpty ? incomeAccountNames[0] : null;

        print("Customer accounts: $accountNames");
        print("Income accounts: $incomeAccountNames");
      });
    } catch (e) {
      print("Error loading accounts: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<String> getNextSetupId(String name) async {
    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
      for (var row in data) {
        Map<String, dynamic> dat = jsonDecode(row["data"]);
        if (dat['Accountname'].toString().toLowerCase() == name.toLowerCase()) {
          return row['keyid'].toString();
        }
      }
      return '0';
    } catch (e) {
      print('Error getting setup ID: $e');
      return '0';
    }
  }

  Future<void> _navigateToAddAccount({bool isIncomeAccount = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Addaccountsdet1()),
    );

    if (result == true) {
      await _loadAccountsFromDB();
      if (mounted) {
        String message =
            isIncomeAccount
                ? 'Income Account added successfully'
                : 'Customer Account added successfully';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
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
        title: const Text('Add Bill', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Text('Bill no                                      :'),
                    Text(' Bill_000$_counter ', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Customer Account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedAccount,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items:
                              accountNames.map((String account) {
                                return DropdownMenuItem<String>(
                                  value: account,
                                  child: Text(account),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAccount = newValue;
                            });
                          },
                          hint: const Text('Select Customer Account'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: "customer_account_btn",
                    backgroundColor: Colors.red,
                    tooltip: 'Add Customer Account',
                    shape: const CircleBorder(),
                    onPressed:
                        () => _navigateToAddAccount(isIncomeAccount: false),
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Amount',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Income Account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedIncomeAccount,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items:
                              incomeAccountNames.map((String account) {
                                return DropdownMenuItem<String>(
                                  value: account,
                                  child: Text(account),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedIncomeAccount = newValue;
                            });
                          },
                          hint: const Text('Select Income Account'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: "income_account_btn", // Added unique hero tag
                    backgroundColor: Colors.red,
                    tooltip: 'Add Income Account',
                    shape: const CircleBorder(),
                    onPressed:
                        () => _navigateToAddAccount(isIncomeAccount: true),
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Remarks Field
              Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Remarks',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (accountNames.isEmpty || incomeAccountNames.isEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please add at least one Customer Account and one Income Account before saving.',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed:
                      (accountNames.isEmpty ||
                              incomeAccountNames.isEmpty ||
                              selectedAccount == null ||
                              selectedIncomeAccount == null)
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Processing Bill Data...'),
                                  ),
                                );

                                final billno = _counter;
                                final date = selectedDate;
                                DateTime date1 = selectedDate!;
                                int year = date1.year;
                                int month = date1.month;
                                final customersdata = selectedAccount;
                                final amount = _amountController.text;
                                final income = selectedIncomeAccount;
                                final remarks = _remarksController.text;

                                String setid = await getNextSetupId(
                                  customersdata.toString(),
                                );
                                String setupid = await getNextSetupId(
                                  income.toString(),
                                );

                                // Credit entry for customer
                                Map<String, dynamic> creditDatas = {
                                  "ACCOUNTS_date": DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDate!),
                                  "ACCOUNTS_billVoucherNumber":
                                      billno.toString(),
                                  "ACCOUNTS_amount": amount,
                                  "ACCOUNTS_setupid": setid,
                                  "ACCOUNTS_VoucherType":
                                      3, // Bill voucher type
                                  "ACCOUNTS_entryid": "0",
                                  "ACCOUNTS_type": "credit",
                                  "ACCOUNTS_remarks": remarks,
                                  "ACCOUNTS_year": year.toString(),
                                  "ACCOUNTS_month": month.toString(),
                                  "ACCOUNTS_cashbanktype": "0",
                                  "ACCOUNTS_billId": "0",
                                };

                                final id = await DatabaseHelper().insertData(
                                  "TABLE_ACCOUNTS",
                                  creditDatas,
                                );

                                if (id != null) {
                                  print("Credit data inserted...$id");

                                  // Debit entry for income
                                  Map<String, dynamic> debitDatas = {
                                    "ACCOUNTS_date": DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(selectedDate!),
                                    "ACCOUNTS_billVoucherNumber":
                                        billno.toString(),
                                    "ACCOUNTS_amount": amount,
                                    "ACCOUNTS_setupid": setupid,
                                    "ACCOUNTS_VoucherType":
                                        3, // Bill voucher type
                                    "ACCOUNTS_entryid": id.toString(),
                                    "ACCOUNTS_type": "debit",
                                    "ACCOUNTS_remarks": remarks,
                                    "ACCOUNTS_year": year.toString(),
                                    "ACCOUNTS_month": month.toString(),
                                    "ACCOUNTS_cashbanktype": "0",
                                    "ACCOUNTS_billId": "0",
                                  };

                                  var debtdata = await DatabaseHelper()
                                      .insertData("TABLE_ACCOUNTS", debitDatas);

                                  if (debtdata != null) {
                                    print("Debit data inserted...$debtdata");

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Bill saved successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context, true);
                                    }
                                  } else {
                                    throw Exception(
                                      "Failed to insert debit data",
                                    );
                                  }
                                } else {
                                  throw Exception(
                                    "Failed to insert credit data",
                                  );
                                }
                              } catch (e) {
                                print("Error saving bill: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error saving bill: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Save Bill",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
