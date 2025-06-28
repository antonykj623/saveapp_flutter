import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view_model/billing_accout_setup/bill_account_setup.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class EditBill extends StatefulWidget {
  final String billNumber;

  const EditBill({super.key, required this.billNumber});

  @override
  State<EditBill> createState() => _EditBillState();
}

class _EditBillState extends State<EditBill> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedAccount;
  String? selectedIncomeAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<Map<String, String>> accountNames =
      []; // Changed to store both name and id
  List<Map<String, String>> incomeAccountNames =
      []; // Changed to store both name and id
  bool _isLoading = false;
  String? creditAccountId;
  String? debitAccountId;

  @override
  void initState() {
    super.initState();
    _loadAccountsFromDB().then((_) {
      _loadBillData(); // Load bill data after accounts are loaded
    });
  }

  Future<void> _loadBillData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');
      final billEntries =
          data
              .where(
                (item) =>
                    item['ACCOUNTS_billVoucherNumber']?.toString() ==
                        widget.billNumber &&
                    item['ACCOUNTS_VoucherType']?.toString() == '3',
              )
              .toList();

      if (billEntries.isNotEmpty) {
        Map<String, dynamic>? creditEntry;
        Map<String, dynamic>? debitEntry;

        // Find credit and debit entries
        for (var entry in billEntries) {
          if (entry['ACCOUNTS_type'] == 'credit') {
            creditEntry = entry;
          } else if (entry['ACCOUNTS_type'] == 'debit') {
            debitEntry = entry;
          }
        }

        if (creditEntry != null && debitEntry != null) {
          // Parse date
          String dateStr = creditEntry['ACCOUNTS_date']?.toString() ?? '';
          try {
            if (dateStr.contains('-')) {
              List<String> parts = dateStr.split('-');
              if (parts.length == 3) {
                if (parts[0].length == 4) {
                  // yyyy-MM-dd format
                  selectedDate = DateTime.parse(dateStr);
                } else {
                  // dd-MM-yyyy format
                  selectedDate = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              }
            }
          } catch (e) {
            print("Error parsing date $dateStr: $e");
            selectedDate = DateTime.now();
          }

          // Set form data
          _amountController.text =
              creditEntry['ACCOUNTS_amount']?.toString() ?? '';
          _remarksController.text =
              creditEntry['ACCOUNTS_remarks']?.toString() ?? '';

          // Store the account IDs
          creditAccountId = creditEntry['ACCOUNTS_setupid']?.toString();
          debitAccountId = debitEntry['ACCOUNTS_setupid']?.toString();

          // Get account names and set dropdown values
          if (creditAccountId != null) {
            final customerName = await _getAccountName(creditAccountId!);
            // Find the account in the list and set it
            for (var account in accountNames) {
              if (account['id'] == creditAccountId) {
                selectedAccount = account['name'];
                break;
              }
            }
            if (selectedAccount == null) {
              selectedAccount = customerName;
            }
          }

          if (debitAccountId != null) {
            final incomeName = await _getAccountName(debitAccountId!);
            // Find the account in the list and set it
            for (var account in incomeAccountNames) {
              if (account['id'] == debitAccountId) {
                selectedIncomeAccount = account['name'];
                break;
              }
            }
            if (selectedIncomeAccount == null) {
              selectedIncomeAccount = incomeName;
            }
          }

          setState(() {});
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill not found'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error loading bill data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bill: $e'),
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

  Future<String> _getAccountName(String id) async {
    try {
      List<Map<String, dynamic>> allRows = await DatabaseHelper().queryallacc();
      for (var row in allRows) {
        if (row['keyid']?.toString() == id) {
          Map<String, dynamic> dat = jsonDecode(row["data"]);
          return dat['Accountname']?.toString() ?? 'Unknown Account';
        }
      }
      return 'Unknown Account';
    } catch (e) {
      print("Error getting account name for ID $id: $e");
      return 'Unknown Account';
    }
  }

  Future<void> _loadAccountsFromDB() async {
    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
      List<Map<String, String>> tempAccountNames = [];
      List<Map<String, String>> tempIncomeAccountNames = [];

      for (var item in data) {
        try {
          Map<String, dynamic> dat = jsonDecode(item["data"]);
          String accountType = dat['Accounttype']?.toString() ?? '';
          String accountName = dat['Accountname']?.toString() ?? '';
          String keyId = item['keyid']?.toString() ?? '';

          if (accountType.toLowerCase().contains("customers")) {
            tempAccountNames.add({'name': accountName, 'id': keyId});
          } else if (accountType.toLowerCase().contains("income")) {
            tempIncomeAccountNames.add({'name': accountName, 'id': keyId});
          }
        } catch (e) {
          print("Error parsing account data: $e");
        }
      }

      setState(() {
        accountNames = tempAccountNames;
        incomeAccountNames = tempIncomeAccountNames;
      });
    } catch (e) {
      print("Error loading accounts: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _navigateToAddAccount({bool isIncomeAccount = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Addaccountsdet1()),
    );
    if (result == true) {
      await _loadAccountsFromDB();
      if (mounted) {
        String message =
            isIncomeAccount
                ? 'Income Account added successfully'
                : 'Customer Account added successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<String> getAccountId(String accountName, bool isIncomeAccount) async {
    try {
      final accountList = isIncomeAccount ? incomeAccountNames : accountNames;
      for (var account in accountList) {
        if (account['name']?.toLowerCase() == accountName.toLowerCase()) {
          return account['id'] ?? '0';
        }
      }
      return '0';
    } catch (e) {
      print('Error getting account ID: $e');
      return '0';
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedAccount == null || selectedIncomeAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both customer and income account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final year = selectedDate!.year.toString();
      final month = selectedDate!.month.toString();

      // Get account IDs
      final customerAccountId = await getAccountId(selectedAccount!, false);
      final incomeAccountId = await getAccountId(selectedIncomeAccount!, true);

      if (customerAccountId == '0' || incomeAccountId == '0') {
        throw Exception('Invalid account selection');
      }

      // Update credit entry (customer account)
      final creditUpdateResult = await db.update(
        'TABLE_ACCOUNTS',
        {
          'ACCOUNTS_date': dateStr,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': year,
          'ACCOUNTS_month': month,
          'ACCOUNTS_setupid': customerAccountId,
        },
        where:
            'ACCOUNTS_billVoucherNumber = ? AND ACCOUNTS_VoucherType = ? AND ACCOUNTS_type = ?',
        whereArgs: [widget.billNumber, 3, 'credit'],
      );

      // Update debit entry (income account)
      final debitUpdateResult = await db.update(
        'TABLE_ACCOUNTS',
        {
          'ACCOUNTS_date': dateStr,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': year,
          'ACCOUNTS_month': month,
          'ACCOUNTS_setupid': incomeAccountId,
        },
        where:
            'ACCOUNTS_billVoucherNumber = ? AND ACCOUNTS_VoucherType = ? AND ACCOUNTS_type = ?',
        whereArgs: [widget.billNumber, 3, 'debit'],
      );

      print('Credit update result: $creditUpdateResult');
      print('Debit update result: $debitUpdateResult');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error updating bill: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bill: $e'),
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

  Future<void> _deleteBill() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final deleteResult = await db.delete(
        'TABLE_ACCOUNTS',
        where: 'ACCOUNTS_billVoucherNumber = ? AND ACCOUNTS_VoucherType = ?',
        whereArgs: [widget.billNumber, 3],
      );

      print('Delete result: $deleteResult');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error deleting bill: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting bill: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Edit Bill', style: TextStyle(color: Colors.white)),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bill no: ${widget.billNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Selection
                      const Text(
                        'Date:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate != null
                                    ? DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(selectedDate!)
                                    : 'Select Date',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Customer Account
                      const Text(
                        'Customer Account:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                      accountNames.map((
                                        Map<String, String> account,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: account['name'],
                                          child: Text(account['name'] ?? ''),
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
                            heroTag: "edit_customer_account_btn",
                            backgroundColor: Colors.red,
                            tooltip: 'Add Customer Account',
                            shape: const CircleBorder(),
                            onPressed:
                                () => _navigateToAddAccount(
                                  isIncomeAccount: false,
                                ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      const Text(
                        'Amount:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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
                            if (double.parse(value) <= 0) {
                              return 'Amount must be greater than 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Income Account
                      const Text(
                        'Income Account:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
                                      incomeAccountNames.map((
                                        Map<String, String> account,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: account['name'],
                                          child: Text(account['name'] ?? ''),
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
                            heroTag: "edit_income_account_btn",
                            backgroundColor: Colors.red,
                            tooltip: 'Add Income Account',
                            shape: const CircleBorder(),
                            onPressed:
                                () => _navigateToAddAccount(
                                  isIncomeAccount: true,
                                ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Remarks
                      const Text(
                        'Remarks:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveBill,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Save Bill',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Confirm Delete',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete this bill?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteBill();
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Delete Bill',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
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
