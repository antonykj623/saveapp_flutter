import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';

class AddJournal extends StatefulWidget {
  final Payment? payment;

  const AddJournal({super.key, this.payment});

  @override
  State<AddJournal> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedDebitAccount;
  String? selectedCreditAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<String> allAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    if (widget.payment != null) {
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(widget.payment!.date);
      } catch (e) {
        selectedDate = DateTime.now();
      }
      selectedDebitAccount = widget.payment!.accountName;
      selectedCreditAccount =
          widget.payment!.paymentMode; // Assuming stored as credit account
      _amountController.text = widget.payment!.amount.toString();
      _remarksController.text = widget.payment!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      List<Map<String, dynamic>> accounts = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      List<String> tempAccounts = [];

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          if (accountType != 'customers') {
            tempAccounts.add(accountName);
          }
        } catch (e) {
          print('Error parsing account data: $e');
        }
      }

      setState(() {
        allAccounts = tempAccounts;
      });
    } catch (e) {
      print('Error loading accounts: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading accounts: $e')));
      }
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
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> allRows = await db.query(
        'TABLE_ACCOUNTSETTINGS',
      );

      for (var row in allRows) {
        Map<String, dynamic> dat = jsonDecode(row["data"]);
        if (dat['Accountname'].toString().toLowerCase() == name.toLowerCase()) {
          return row['keyid'].toString();
        }
      }
      return '0';
    } catch (e) {
      print('Error getting setup ID for $name: $e');
      return '0';
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

  Future<void> _saveDoubleEntryAccounts() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDebitAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a debit account')),
      );
      return;
    }
    if (selectedCreditAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a credit account')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper().database;
      final dateString =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      final monthString = _getMonthName(selectedDate.month);
      final yearString = selectedDate.year.toString();

      final debitSetupId = await getNextSetupId(selectedDebitAccount!);
      final creditSetupId = await getNextSetupId(selectedCreditAccount!);

      if (debitSetupId == '0' || creditSetupId == '0') {
        throw Exception(
          'Invalid account selected: $selectedDebitAccount or $selectedCreditAccount',
        );
      }

      final double amount = double.parse(_amountController.text);

      if (widget.payment != null) {
        String entryId = widget.payment!.id.toString();
        // Update debit entry
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": debitSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype":
                '0', // Journal entries may not use cash/bank type
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [3, entryId, 'debit'],
        );

        // Update credit entry
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": creditSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": '0',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [3, entryId, 'credit'],
        );
      } else {
        // Insert new debit entry
        Map<String, dynamic> debitEntry = {
          'ACCOUNTS_VoucherType': 3, // Journal voucher type
          'ACCOUNTS_entryid': 0,
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': debitSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'debit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': '0',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        final debitId = await db.insert("TABLE_ACCOUNTS", debitEntry);

        // Insert new credit entry
        Map<String, dynamic> creditEntry = {
          'ACCOUNTS_VoucherType': 3,
          'ACCOUNTS_entryid': debitId.toString(),
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': creditSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'credit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': '0',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        await db.insert("TABLE_ACCOUNTS", creditEntry);

        // Update debit entry with entryId
        await db.update(
          "TABLE_ACCOUNTS",
          {"ACCOUNTS_entryid": debitId},
          where: "ACCOUNTS_id = ?",
          whereArgs: [debitId],
        );
      }

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) {
        throw Exception('Double-entry accounting is unbalanced');
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved successfully')),
        );
      }
    } catch (e) {
      print('Error saving journal entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving journal entry: $e')),
        );
      }
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
        title: Text(
          widget.payment != null ? 'Edit Journal Entry' : 'Add Journal Entry',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Debit Account
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select Debit Account'),
                          value: selectedDebitAccount,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a debit account';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDebitAccount = newValue;
                            });
                          },
                          items:
                              allAccounts.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    tooltip: 'Add Account',
                    shape: const CircleBorder(),
                    mini: true,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadAccounts();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account added successfully'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Amount
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
                    hintText: 'Amount',
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
              const SizedBox(height: 25),
              // Credit Account
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select Credit Account'),
                          value: selectedCreditAccount,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a credit account';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCreditAccount = newValue;
                            });
                          },
                          items:
                              allAccounts.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    tooltip: 'Add Account',
                    shape: const CircleBorder(),
                    mini: true,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadAccounts();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account added successfully'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Remarks
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
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
              const SizedBox(height: 50),
              // Save Button
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveDoubleEntryAccounts,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
