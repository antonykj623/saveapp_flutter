import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.payment!.date);
      selectedAccount = widget.payment!.accountName;
      _amountController.text = widget.payment!.amount.toString();
      paymentMode = widget.payment!.paymentMode;
      selectedCashOption = widget.payment!.paymentMode;
      _remarksController.text = widget.payment!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
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

          if (accountType == 'bank') {
            banks.add('Bank - $accountName');
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

        if (selectedCashOption == null ||
            !allBankCashOptions.contains(selectedCashOption)) {
          selectedCashOption =
              allBankCashOptions.isNotEmpty ? allBankCashOptions.first : 'Cash';
        }
      });

      print('===== LOADED BANK/CASH OPTIONS =====');
      print('Cash Options: $cashOptions');
      print('Bank Options: $bankOptions');
      print('All Options: $allBankCashOptions');
      print('====================================');
    } catch (e) {
      print('Error loading bank/cash options: $e');
      if (context.mounted) {
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
            print('===== ACCOUNT SELECTED =====');
            print('Selected Account: $accountName');
            print('============================');
          },
        );
      },
    );
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      if (selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account')),
        );
        return;
      }

      print('===== SAVING PAYMENT DETAILS =====');
      print('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
      print('Account: $selectedAccount');
      print('Amount: ${_amountController.text}');
      print('Payment Mode: $paymentMode');
      print('Selected Cash/Bank Option: $selectedCashOption');
      print('Remarks: ${_remarksController.text}');
      print('==================================');

      try {
        saveDoubleEntryAccounts();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving payment: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Voucher'),
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
                        onTap: () {
                          _showSearchableAccountDialog(context);
                        },
                        child: Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAccount ?? 'Select An Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      selectedAccount != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
                        if (context.mounted) {
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
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        if (bankOptions.isNotEmpty) {
                          selectedCashOption = bankOptions.first;
                        }
                      });

                      print('===== RADIO SELECTION =====');
                      print('User selected: BANK');
                      print('Payment Mode changed to: $paymentMode');
                      print('Available Bank Options: $bankOptions');
                      print('Selected Bank Option: $selectedCashOption');
                      print('===========================');
                    },
                  ),
                  const Text('Bank'),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: 'Cash',
                    groupValue: paymentMode,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = 'Cash';
                      });

                      print('===== RADIO SELECTION =====');
                      print('User selected: CASH');
                      print('Payment Mode changed to: $paymentMode');
                      print('Available Cash Options: $cashOptions');
                      print('Selected Cash Option: $selectedCashOption');
                      print('===========================');
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
                          value: selectedCashOption,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCashOption = newValue;

                              print(selectedCashOption);
                              if (newValue == 'Cash') {
                                paymentMode = 'Cash';
                              } else if (newValue?.startsWith('Bank') == true) {
                                paymentMode = 'Bank';
                              }
                            });

                            print('===============================');
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        _loadBankCashOptions();
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
                    onPressed: _savePayment,
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

  Future<String> getNextSetupId(String name) async {
    try {
      String maxId = "0";
      List<Map<String, dynamic>> allrows = await DatabaseHelper().queryallacc();

      allrows.forEach((row) {
        Map<String, dynamic> dat = jsonDecode(row["data"]);
        if (dat['Accountname'].toString().compareTo(name) == 0) {
          maxId = row['keyid'].toString();
        }
      });

      return maxId;
    } catch (e) {
      return '0';
    }
  }

  int getAccountTypeNumber(String type) {
    return type.toLowerCase() == 'debit' ? 1 : 2;
  }

  Future<void> saveDoubleEntryAccounts() async {
    final accname = accountname.text.trim();
    final accountType = dropdownvalu1;

    final type = dropdownvalu2;

    if (accname.toLowerCase() == 'cash') {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Account name "Cash" is reserved. Please choose a different name.',
          ),
        ),
      );
      return;
    }

    final currentDate = DateTime.now();
    final dateString =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final monthString = _getMonthName(currentDate.month);
    final yearString = currentDate.year.toString();
    final entryId = 0;

    try {
      final db = await DatabaseHelper().database;
      final setupId = await getNextSetupId(selectedAccount.toString());
      final contraSetupId = await getNextSetupId(accountType);

      Map<String, dynamic> mainAccountEntry = {
        'ACCOUNTS_VoucherType': 1,
        'ACCOUNTS_entryid': "0",
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': setupId,
        'ACCOUNTS_amount': _amountController.text.toString(),
        'ACCOUNTS_type': type.toLowerCase(),
        'ACCOUNTS_remarks': 'Opening Balance for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype': getAccountTypeNumber(type).toString(),
        'ACCOUNTS_billId': '',
        'ACCOUNTS_billVoucherNumber': '',
      };

      var id = await db.insert('TABLE_ACCOUNTS', mainAccountEntry);

      Map<String, dynamic> contraEntry = {
        'ACCOUNTS_VoucherType': 1,
        'ACCOUNTS_entryid': id.toString(),
        'ACCOUNTS_date': dateString,
        'ACCOUNTS_setupid': contraSetupId,
        'ACCOUNTS_amount': _amountController.text.toString(),
        'ACCOUNTS_type': type.toLowerCase() == 'debit' ? 'credit' : 'debit',
        'ACCOUNTS_remarks': 'Opening Balance contra for $accname',
        'ACCOUNTS_year': yearString,
        'ACCOUNTS_month': monthString,
        'ACCOUNTS_cashbanktype': type.toLowerCase() == 'debit' ? '2' : '1',
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
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
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
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
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
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Map<String, dynamic>> items = [];
                  List<Map<String, dynamic>> allItems = snapshot.data ?? [];

                  if (searchQuery.isEmpty) {
                    items = allItems;
                  } else {
                    for (var item in allItems) {
                      try {
                        Map<String, dynamic> dat = jsonDecode(item["data"]);
                        String accountName = dat['Accountname'].toString();

                        if (accountName.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        )) {
                          items.add(item);
                        }
                      } catch (e) {}
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
