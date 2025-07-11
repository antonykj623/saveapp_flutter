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

  String _selectedDebit = 'Hdfc';
  String _selectedTransactionType = 'Deposit';
  String _selectedCredit = 'Cash';

  List<String> _debitOptions = ['Hdfc', 'SBI', 'ICICI', 'Axis'];
  List<String> _transactionTypes = ['Deposit', 'Withdrawal'];
  List<String> _creditOptions = ['Cash', 'Cheque', 'Online'];

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
        _debitOptions = banks.isNotEmpty ? banks : ['Hdfc', 'SBI', 'ICICI', 'Axis'];

        Set<String> creditSet = {'Cash', 'Cheque', 'Online'};
        creditSet.addAll(cashAccounts);
        _creditOptions = creditSet.toList();

        if (!_debitOptions.contains(_selectedDebit)) {
          _selectedDebit = _debitOptions.first;
        }
        if (!_creditOptions.contains(_selectedCredit)) {
          _selectedCredit = _creditOptions.first;
        }
      });
    } catch (e) {
      print('Error loading accounts: $e');
      setState(() {
        _debitOptions = ['Hdfc', 'SBI', 'ICICI', 'Axis'];
        _creditOptions = ['Cash', 'Cheque', 'Online'];
        if (!_debitOptions.contains(_selectedDebit)) {
          _selectedDebit = _debitOptions.first;
        }
        if (!_creditOptions.contains(_selectedCredit)) {
          _selectedCredit = _creditOptions.first;
        }
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
        title: Text(isEdit ? 'Edit bank voucher' : 'Bank'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Field
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(),
                ),
              ),

              // Debit Account Field with Add Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              _debitOptions.contains(_selectedDebit)
                                  ? _selectedDebit
                                  : _debitOptions.first,
                          isExpanded: true,
                          items:
                              _debitOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDebit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _navigateToAddAccount('bank'),
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Amount Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
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

              SizedBox(height: 16),

              // Transaction Type Field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTransactionType,
                    isExpanded: true,
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
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Credit Account Field with Add Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              _creditOptions.contains(_selectedCredit)
                                  ? _selectedCredit
                                  : _creditOptions.first,
                          isExpanded: true,
                          items:
                              _creditOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCredit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _navigateToAddAccount('cash'),
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Remarks Field
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter Remarks',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),

              Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text('Save'),
                    ),
                  ),
                  if (isEdit) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text("delete"),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Account added successfully')));
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _saveVoucher() async {
    if (_formKey.currentState!.validate()) {
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

        final debitSetupId = await getNextSetupId(_selectedDebit);
        final creditSetupId = await getNextSetupId(_selectedCredit);

        if (widget.voucher == null) {
          Map<String, dynamic> debitEntry = {
            'ACCOUNTS_VoucherType': 5,
            'ACCOUNTS_entryid': 0,
            'ACCOUNTS_date': dateString,
            'ACCOUNTS_setupid': debitSetupId,
            'ACCOUNTS_amount': _amountController.text,
            'ACCOUNTS_type':
                _selectedTransactionType == 'Deposit' ? 'credit' : 'debit',
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
                _selectedTransactionType == 'Deposit' ? 'debit' : 'credit',
            'ACCOUNTS_remarks':
                _remarksController.text.isEmpty
                    ? 'Bank ${_selectedTransactionType.toLowerCase()}'
                    : _remarksController.text,
            'ACCOUNTS_year': yearString,
            'ACCOUNTS_month': monthString,
            'ACCOUNTS_cashbanktype':
                _selectedCredit == 'Cash' ? '1' : '2', // Cash or Bank
            'ACCOUNTS_billId': '',
            'ACCOUNTS_billVoucherNumber': '',
          };

          await db.insert("TABLE_ACCOUNTS", creditEntry);

          // Update the debit entry with correct entry ID
          await db.update(
            "TABLE_ACCOUNTS",
            {"ACCOUNTS_entryid": debitId},
            where: "ACCOUNTS_id = ?",
            whereArgs: [debitId],
          );
        } else {
          // Update existing voucher entries
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
              _selectedTransactionType == 'Deposit' ? 'credit' : 'debit',
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
              _selectedTransactionType == 'Deposit' ? 'debit' : 'credit',
            ],
          );
        }

        Navigator.pop(context, true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bank voucher saved successfully')),
          );
        }
      } catch (e) {
        print('Error saving voucher: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving voucher: $e')));
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

        Navigator.pop(context, true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bank voucher deleted successfully')),
          );
        }
      } catch (e) {
        print('Error deleting voucher: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting voucher: $e')));
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
