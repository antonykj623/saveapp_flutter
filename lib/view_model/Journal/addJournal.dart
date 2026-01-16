import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/Journal/Journel_class_model_class.dart';

class AddJournal extends StatefulWidget {
  final JournalEntry? journalEntry;

  const AddJournal({super.key, this.journalEntry});

  @override
  State<AddJournal> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournal>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedDebitAccount;
  String? selectedCreditAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<String> allAccounts = [];
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAccounts();

    if (widget.journalEntry != null) {
      try {
        selectedDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(widget.journalEntry!.date);
      } catch (e) {
        selectedDate = DateTime.now();
      }
      selectedDebitAccount = widget.journalEntry!.debitAccount;
      selectedCreditAccount = widget.journalEntry!.creditAccount;
      _amountController.text = widget.journalEntry!.amount.toString();
      _remarksController.text = widget.journalEntry!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
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
        isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      print('Error loading accounts: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading accounts: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
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

  Future<void> _saveJournalEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDebitAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a debit account'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (selectedCreditAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a credit account'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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

      if (widget.journalEntry != null) {
        String entryId = widget.journalEntry!.entryId.toString();
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": debitSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [4, entryId, 'debit'],
        );

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": creditSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [4, entryId, 'credit'],
        );
      } else {
        Map<String, dynamic> debitEntry = {
          'ACCOUNTS_VoucherType': 4,
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

        Map<String, dynamic> creditEntry = {
          'ACCOUNTS_VoucherType': 4,
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

        await db.update(
          "TABLE_ACCOUNTS",
          {"ACCOUNTS_entryid": debitId},
          where: "ACCOUNTS_id = ?",
          whereArgs: [debitId],
        );
      }

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) throw Exception('Double-entry accounting is unbalanced');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Journal entry saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving journal entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient Header
          Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.teal[700]!,
                  Colors.teal[500]!,
                  Colors.cyan[400]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.journalEntry != null
                                ? 'Edit Entry'
                                : 'Add Entry',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Record journal transaction',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Picker
                            _buildFormLabel('Date'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey[50]!],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.purple[100]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd-MMM-yyyy',
                                      ).format(selectedDate),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal[800],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.teal[600],
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Debit Account
                            _buildFormLabel('Debit Account'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey[50]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.teal[100]!,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: const Text('Select Account'),
                                        value: selectedDebitAccount,
                                        isExpanded: true,
                                        validator:
                                            (value) =>
                                                value == null
                                                    ? 'Select debit account'
                                                    : null,
                                        onChanged:
                                            (String? newValue) => setState(
                                              () =>
                                                  selectedDebitAccount =
                                                      newValue,
                                            ),
                                        items:
                                            allAccounts.map<
                                              DropdownMenuItem<String>
                                            >((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.teal,
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const Addaccountsdet(),
                                      ),
                                    );
                                    if (result == true) {
                                      await _loadAccounts();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account added'),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Amount
                            _buildFormLabel('Amount'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.teal[100]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter amount',
                                  prefixIcon: Icon(
                                    Icons.currency_rupee,
                                    color: Colors.teal,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Enter amount';
                                  if (double.tryParse(value) == null)
                                    return 'Valid number required';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Credit Account
                            _buildFormLabel('Credit Account'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey[50]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.teal[100]!,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: const Text('Select Account'),
                                        value: selectedCreditAccount,
                                        isExpanded: true,
                                        validator:
                                            (value) =>
                                                value == null
                                                    ? 'Select credit account'
                                                    : null,
                                        onChanged:
                                            (String? newValue) => setState(
                                              () =>
                                                  selectedCreditAccount =
                                                      newValue,
                                            ),
                                        items:
                                            allAccounts.map<
                                              DropdownMenuItem<String>
                                            >((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.teal,
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const Addaccountsdet(),
                                      ),
                                    );
                                    if (result == true) {
                                      await _loadAccounts();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account added'),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Remarks
                            _buildFormLabel('Remarks'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.teal[100]!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _remarksController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter remarks',
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Save Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal[600]!,
                                    Colors.cyan[500]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: _saveJournalEntry,
                                child: const Text(
                                  'Save Entry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.teal[800],
      ),
    );
  }
}
