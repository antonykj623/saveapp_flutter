import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';

class AddPaymentVoucherPage extends StatefulWidget {
  final Payment? payment;

  const AddPaymentVoucherPage({super.key, this.payment});

  @override
  State<AddPaymentVoucherPage> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddPaymentVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();

  List<String> cashOptions = ['Cash'];
  List<String> bankOptions = [];
  List<String> allBankCashOptions = [];

  @override
  void initState() {
    super.initState();
    _loadBankCashOptions();

    if (widget.payment != null) {
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(widget.payment!.date);
      } catch (e) {
        try {
          selectedDate = DateFormat('yyyy-MM-dd').parse(widget.payment!.date);
        } catch (e2) {
          try {
            selectedDate = DateFormat('dd-MM-yyyy').parse(widget.payment!.date);
          } catch (e3) {
            print(
              'Error parsing date: ${widget.payment!.date}, using current date',
            );
            selectedDate = DateTime.now();
          }
        }
      }

      selectedAccount = widget.payment!.accountName;
      _amountController.text = widget.payment!.amount.toString();
      paymentMode = widget.payment!.paymentMode;
      selectedCashOption = widget.payment!.paymentMode;
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

  Future<void> _loadBankCashOptions() async {
    try {
      List<Map<String, dynamic>> accounts = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );

      List<String> banks = [];
      List<String> cashAccounts = [];

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // Exclude 'Customers' account type
          if (accountType == 'customers') {
            continue; // Skip Customers accounts
          }

          if (accountType == 'bank') {
            banks.add(accountName);
          } else if (accountType == 'cash' &&
              accountName.toLowerCase() != 'cash') {
            cashAccounts.add(accountName);
          }
        } catch (e) {
          print('Error parsing account data: $e');
        }
      }

      setState(() {
        cashOptions = ['Cash', ...cashAccounts];
        bankOptions = banks;
        allBankCashOptions = [...cashOptions, ...bankOptions];

        if (paymentMode == 'Cash') {
          if (selectedCashOption == null ||
              !cashOptions.contains(selectedCashOption)) {
            selectedCashOption =
                cashOptions.isNotEmpty ? cashOptions.first : 'Cash';
          }
        } else {
          if (selectedCashOption == null ||
              !bankOptions.contains(selectedCashOption)) {
            selectedCashOption =
                bankOptions.isNotEmpty ? bankOptions.first : null;
          }
        }
      });
    } catch (e) {
      print('Error loading bank/cash options: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank/cash options: $e')),
        );
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

  void _showSearchableAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchableAccountDialog(
          onAccountSelected: (String accountName) {
            setState(() {
              selectedAccount = accountName;
            });
          },
        );
      },
    );
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
      return name.toLowerCase() == 'cash' ? '1' : '0';
    } catch (e) {
      print('Error getting setup ID: $e');
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
    if (selectedAccount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }
    if (selectedCashOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cash/bank option')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper().database;
      final currentDate = selectedDate;
      final dateString =
          "${currentDate.day}/${currentDate.month}/${currentDate.year}";
      final monthString = _getMonthName(currentDate.month);
      final yearString = currentDate.year.toString();

      final firstSetupId = await getNextSetupId(selectedAccount!);
      final contraSetupId = await getNextSetupId(selectedCashOption!);

      if (widget.payment != null) {
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": firstSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [1, widget.payment!.id.toString(), 'debit'],
        );

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": contraSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [1, widget.payment!.id.toString(), 'credit'],
        );
      } else {
        Map<String, dynamic> mainAccountEntry = {
          'ACCOUNTS_VoucherType': 1,
          'ACCOUNTS_entryid': 0,
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': firstSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'debit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        final debitId = await db.insert("TABLE_ACCOUNTS", mainAccountEntry);

        Map<String, dynamic> contraEntry = {
          'ACCOUNTS_VoucherType': 1,
          'ACCOUNTS_entryid': debitId.toString(),
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': contraSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'credit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        await db.insert("TABLE_ACCOUNTS", contraEntry);

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
          const SnackBar(content: Text('Payment saved successfully')),
        );
      }
    } catch (e) {
      print('Error saving payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving payment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.payment != null
              ? 'Edit Payment Voucher'
              : 'Add Payment Voucher',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: InkWell(
                        onTap: () => _showSearchableAccountDialog(context),
                        child: Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAccount ?? 'Select an Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      selectedAccount != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadBankCashOptions();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account added successfully'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget setting feature')),
                      );
                    },
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Radio<String>(
                    value: 'Bank',
                    groupValue: paymentMode,
                    activeColor: Colors.blue,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        if (bankOptions.isNotEmpty) {
                          selectedCashOption = bankOptions.first;
                        }
                      });
                    },
                  ),
                  const Text('Bank'),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: 'Cash',
                    groupValue: paymentMode,
                    activeColor: Colors.blue,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = 'Cash';
                      });
                    },
                  ),
                  const Text('Cash'),
                ],
              ),
              const SizedBox(height: 16),
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
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value:
                              paymentMode == 'Cash'
                                  ? (cashOptions.contains(selectedCashOption)
                                      ? selectedCashOption
                                      : cashOptions.first)
                                  : (bankOptions.contains(selectedCashOption)
                                      ? selectedCashOption
                                      : (bankOptions.isNotEmpty
                                          ? bankOptions.first
                                          : null)),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCashOption = newValue!;
                              paymentMode =
                                  bankOptions.contains(newValue)
                                      ? 'Bank'
                                      : 'Cash';
                            });
                          },
                          items:
                              paymentMode == 'Cash'
                                  ? cashOptions.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList()
                                  : bankOptions.map<DropdownMenuItem<String>>((
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
                    mini: true,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadBankCashOptions();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Color.fromRGBO(33, 150, 243, 0.8)],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _saveDoubleEntryAccounts();
                    },
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

class SearchableAccountDialog extends StatefulWidget {
  final Function(String) onAccountSelected;

  const SearchableAccountDialog({super.key, required this.onAccountSelected});

  @override
  State<SearchableAccountDialog> createState() =>
      _SearchableAccountDialogState();
}

class _SearchableAccountDialogState extends State<SearchableAccountDialog> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by Account Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Map<String, dynamic>> items = [];
                  List<Map<String, dynamic>> allItems = snapshot.data ?? [];

                  for (var item in allItems) {
                    try {
                      Map<String, dynamic> dat = jsonDecode(item["data"]);
                      String accountType =
                          dat['Accounttype'].toString().toLowerCase();
                      String accountName = dat['Accountname'].toString();

                      // Exclude 'Customers' accounts
                      if (accountType == 'customers') {
                        continue;
                      }

                      if (searchQuery.isEmpty ||
                          accountName.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          )) {
                        items.add(item);
                      }
                    } catch (e) {
                      print('Error parsing account: $e');
                    }
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      Map<String, dynamic> dat = jsonDecode(item["data"]);
                      String accountName = dat['Accountname'].toString();

                      return ListTile(
                        title: Text(accountName),
                        onTap: () {
                          widget.onAccountSelected(accountName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
