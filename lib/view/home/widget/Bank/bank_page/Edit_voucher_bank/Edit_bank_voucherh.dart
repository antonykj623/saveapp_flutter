import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'dart:convert';

class AddEditVoucherScreen extends StatefulWidget {
  final BankVoucher? voucher;

  AddEditVoucherScreen({this.voucher});

  @override
  _AddEditVoucherScreenState createState() => _AddEditVoucherScreenState();
}

class _AddEditVoucherScreenState extends State<AddEditVoucherScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;

  String? _selectedDebit;
  String _selectedTransactionType = 'Deposit';
  String? _selectedCredit;

  List<String> _debitOptions = [];
  List<String> _transactionTypes = ['Deposit', 'Withdrawal'];
  List<String> _creditOptions = ['Cash'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text:
          widget.voucher?.date ??
          DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );
    _amountController = TextEditingController(
      text: widget.voucher?.amount.toString() ?? '',
    );
    _remarksController = TextEditingController(
      text: widget.voucher?.remarks ?? '',
    );

    if (widget.voucher != null) {
      _selectedDebit = widget.voucher!.debit;
      _selectedCredit = widget.voucher!.credit;
      _selectedTransactionType = widget.voucher!.transactionType ?? 'Deposit';
    }

    _loadAccountsFromDB();
  }

  Future<void> _loadAccountsFromDB() async {
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

          if (accountType == 'customers') continue;

          if (accountType == 'bank') {
            banks.add(accountName);
          } else if (accountType == 'cash') {
            cashAccounts.add(accountName);
          }
        } catch (e) {
          print('Error parsing account data: $e');
        }
      }

      setState(() {
        _debitOptions = banks;

        if (_debitOptions.isEmpty) {
          _selectedDebit = null;
        } else {
          if (_selectedDebit == null ||
              !_debitOptions.contains(_selectedDebit)) {
            _selectedDebit = _debitOptions.first;
          }
        }

        Set<String> creditSet = {'Cash'};
        if (cashAccounts.isNotEmpty) {
          creditSet.addAll(cashAccounts);
        }
        _creditOptions = creditSet.toList();

        if (_selectedCredit == null ||
            !_creditOptions.contains(_selectedCredit)) {
          _selectedCredit = _creditOptions.first;
        }
      });
    } catch (e) {
      print('Error loading accounts: $e');
      setState(() {
        _debitOptions = [];
        _creditOptions = ['Cash'];
        _selectedDebit = null;
        _selectedCredit = 'Cash';
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

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.voucher != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          isEdit ? 'Edit Bank Voucher' : 'Add Bank Voucher',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4,
        shadowColor: Colors.teal.withOpacity(0.4),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Field
                Text(
                  'Date',
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
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.teal[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onTap: () => _selectDate(),
                  ),
                ),
                const SizedBox(height: 20),

                // Debit Account Field with Add Button
                Text(
                  'Debit Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                        child:
                            _debitOptions.isEmpty
                                ? Container(
                                  height: 56,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'No bank accounts found. Please add a bank account.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                                : DropdownButtonFormField<String>(
                                  value: _selectedDebit,
                                  decoration: InputDecoration(
                                    hintText: 'Select Bank Account',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.account_balance,
                                      color: Colors.teal[400],
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items:
                                      _debitOptions.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedDebit = newValue;
                                    });
                                  },
                                  dropdownColor: Colors.white,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.teal[400],
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () => _navigateToAddAccount('bank'),
                      backgroundColor: Colors.teal,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      elevation: 4,
                      tooltip: 'Add Bank Account',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Amount Field
                Text(
                  'Amount',
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
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.monetization_on,
                        color: Colors.teal[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Transaction Type Field
                Text(
                  'Transaction Type',
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
                    value: _selectedTransactionType,
                    decoration: InputDecoration(
                      hintText: 'Select Transaction Type',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(
                        Icons.swap_horiz,
                        color: Colors.teal[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items:
                        _transactionTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTransactionType = newValue!;
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

                // Credit Account Field with Add Button
                Text(
                  'Credit Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                          value: _selectedCredit,
                          decoration: InputDecoration(
                            hintText: 'Select Credit Account',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.teal[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items:
                              _creditOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCredit = newValue;
                            });
                          },
                          dropdownColor: Colors.white,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.teal[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () => _navigateToAddAccount('cash'),
                      backgroundColor: Colors.teal,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      elevation: 4,
                      tooltip: 'Add Cash Account',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Remarks Field
                Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
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
                    controller: _remarksController,
                    decoration: InputDecoration(
                      hintText: 'Enter Remarks (Optional)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.note, color: Colors.teal[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: null,
                    expands: true,
                  ),
                ),
                const SizedBox(height: 40),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canSave() ? _saveVoucher : null,
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
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _deleteVoucher,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.red.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canSave() {
    return _selectedDebit != null && _selectedCredit != null;
  }

  Future<void> _navigateToAddAccount(String defaultType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Addaccountsdet1(defaultAccountType: defaultType),
      ),
    );
    if (result == true) {
      await _loadAccountsFromDB();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account added successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _saveVoucher() async {
    if (_formKey.currentState!.validate() && _canSave()) {
      try {
        final db = await DatabaseHelper().database;
        final dateString = DateFormat(
          'dd/MM/yyyy',
        ).format(DateFormat('dd-MM-yyyy').parse(_dateController.text));
        final monthString = _getMonthName(
          DateFormat('dd-MM-yyyy').parse(_dateController.text).month,
        );
        final yearString =
            DateFormat(
              'dd-MM-yyyy',
            ).parse(_dateController.text).year.toString();

        final debitSetupId = await getNextSetupId(_selectedDebit!);
        final creditSetupId = await getNextSetupId(_selectedCredit!);

        if (widget.voucher == null) {
          Map<String, dynamic> debitEntry = {
            'ACCOUNTS_VoucherType': 5,
            'ACCOUNTS_entryid': 0,
            'ACCOUNTS_date': dateString,
            'ACCOUNTS_setupid': debitSetupId,
            'ACCOUNTS_amount': _amountController.text,
            'ACCOUNTS_type':
                _selectedTransactionType == 'Deposit' ? 'debit' : 'credit',
            'ACCOUNTS_remarks':
                _remarksController.text.isEmpty
                    ? 'Bank ${_selectedTransactionType.toLowerCase()}'
                    : _remarksController.text,
            'ACCOUNTS_year': yearString,
            'ACCOUNTS_month': monthString,
            'ACCOUNTS_cashbanktype': '2',
            'ACCOUNTS_billId': '',
            'ACCOUNTS_billVoucherNumber': '',
          };

          final debitId = await db.insert("TABLE_ACCOUNTS", debitEntry);

          Map<String, dynamic> creditEntry = {
            'ACCOUNTS_VoucherType': 5,
            'ACCOUNTS_entryid': debitId.toString(),
            'ACCOUNTS_date': dateString,
            'ACCOUNTS_setupid': creditSetupId,
            'ACCOUNTS_amount': _amountController.text,
            'ACCOUNTS_type':
                _selectedTransactionType == 'Deposit' ? 'credit' : 'debit',
            'ACCOUNTS_remarks':
                _remarksController.text.isEmpty
                    ? 'Bank ${_selectedTransactionType.toLowerCase()}'
                    : _remarksController.text,
            'ACCOUNTS_year': yearString,
            'ACCOUNTS_month': monthString,
            'ACCOUNTS_cashbanktype': _selectedCredit == 'Cash' ? '1' : '2',
            'ACCOUNTS_billId': '',
            'ACCOUNTS_billVoucherNumber': '',
          };

          await db.insert("TABLE_ACCOUNTS", creditEntry);

          await db.update(
            "TABLE_ACCOUNTS",
            {"ACCOUNTS_entryid": debitId},
            where: "ACCOUNTS_id = ?",
            whereArgs: [debitId],
          );
        } else {
          await db.update(
            "TABLE_ACCOUNTS",
            {
              "ACCOUNTS_date": dateString,
              "ACCOUNTS_setupid": debitSetupId,
              "ACCOUNTS_amount": _amountController.text,
              "ACCOUNTS_remarks":
                  _remarksController.text.isEmpty
                      ? 'Bank ${_selectedTransactionType.toLowerCase()}'
                      : _remarksController.text,
              "ACCOUNTS_year": yearString,
              "ACCOUNTS_month": monthString,
            },
            where:
                "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
            whereArgs: [
              5,
              widget.voucher!.id.toString(),
              _selectedTransactionType == 'Deposit' ? 'debit' : 'credit',
            ],
          );

          await db.update(
            "TABLE_ACCOUNTS",
            {
              "ACCOUNTS_date": dateString,
              "ACCOUNTS_setupid": creditSetupId,
              "ACCOUNTS_amount": _amountController.text,
              "ACCOUNTS_remarks":
                  _remarksController.text.isEmpty
                      ? 'Bank ${_selectedTransactionType.toLowerCase()}'
                      : _remarksController.text,
              "ACCOUNTS_year": yearString,
              "ACCOUNTS_month": monthString,
            },
            where:
                "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
            whereArgs: [
              5,
              widget.voucher!.id.toString(),
              _selectedTransactionType == 'Deposit' ? 'credit' : 'debit',
            ],
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bank voucher saved successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving voucher: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving voucher: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteVoucher() async {
    if (widget.voucher != null) {
      try {
        final db = await DatabaseHelper().database;
        await db.delete(
          "TABLE_ACCOUNTS",
          where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
          whereArgs: [5, widget.voucher!.id.toString()],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bank voucher deleted successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Error deleting voucher: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting voucher: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
