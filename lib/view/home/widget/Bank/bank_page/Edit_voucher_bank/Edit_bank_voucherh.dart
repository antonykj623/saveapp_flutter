// FILE: lib/view/home/widget/Bank/bank_page/Edit_voucher_bank/AddEditVoucherScreen.dart
// UPDATED with Modern Attractive Design + Premium Check

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';

class AddEditVoucherScreen extends StatefulWidget {
  final BankVoucher? voucher;
  AddEditVoucherScreen({this.voucher});

  @override
  _AddEditVoucherScreenState createState() => _AddEditVoucherScreenState();
}

class _AddEditVoucherScreenState extends State<AddEditVoucherScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _fadeController;
  late AnimationController _slideController;

  final _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

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

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
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

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.voucher != null;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient Background
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Text(
                          isEdit ? 'Edit Voucher' : 'Add Voucher',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(width: 48, height: 48),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Form Container
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Date Field
                          _buildFormField(
                            label: 'Date',
                            icon: Icons.calendar_today_rounded,
                            controller: _dateController,
                            readOnly: true,
                            onTap: () => _selectDate(),
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Debit Account Field
                          _buildLabel('Debit Account'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            icon: Icons.account_balance_rounded,
                            value: _selectedDebit,
                            items: _debitOptions,
                            hint: 'Select Bank Account',
                            onChanged:
                                (value) =>
                                    setState(() => _selectedDebit = value),
                            onAddPressed: () => _navigateToAddAccount('bank'),
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Amount Field
                          _buildFormField(
                            label: 'Amount',
                            icon: Icons.currency_rupee_rounded,
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter amount';
                              if (double.tryParse(value) == null)
                                return 'Please enter a valid number';
                              return null;
                            },
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Transaction Type
                          _buildLabel('Transaction Type'),
                          const SizedBox(height: 8),
                          _buildTransactionTypeSelector(),

                          SizedBox(height: size.height * 0.02),

                          // Credit Account Field
                          _buildLabel('Credit Account'),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            icon: Icons.account_balance_wallet_rounded,
                            value: _selectedCredit,
                            items: _creditOptions,
                            hint: 'Select Credit Account',
                            onChanged:
                                (value) =>
                                    setState(() => _selectedCredit = value),
                            onAddPressed: () => _navigateToAddAccount('cash'),
                          ),

                          SizedBox(height: size.height * 0.02),

                          // Remarks Field
                          _buildLabel('Remarks (Optional)'),
                          const SizedBox(height: 8),
                          _buildRemarksField(),

                          SizedBox(height: size.height * 0.04),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    print(
                                      '========== BANK VOUCHER SAVE BUTTON ==========',
                                    );

                                    // Check premium before saving
                                    final canAdd = await _premiumService
                                        .canAddData(forceRefresh: true);

                                    if (!canAdd) {
                                      print('❌ Premium expired');
                                      if (mounted) {
                                        PremiumService.showPremiumExpiredDialog(
                                          context,
                                        );
                                      }
                                      return;
                                    }

                                    print('✅ Can save - proceeding');
                                    _saveVoucher();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            _canSave()
                                                ? [
                                                  Colors.teal[600]!,
                                                  Colors.teal[800]!,
                                                ]
                                                : [
                                                  Colors.grey[400]!,
                                                  Colors.grey[600]!,
                                                ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.teal.withOpacity(
                                            _canSave() ? 0.3 : 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (isEdit) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _deleteVoucher,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red[600]!,
                                            Colors.red[800]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.delete_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: size.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.teal[800],
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal[100]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.teal[600], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    required VoidCallback onAddPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.teal[100]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              items:
                  items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.teal[600], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              dropdownColor: Colors.white,
              icon: Icon(Icons.expand_more_rounded, color: Colors.teal[600]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onAddPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[500]!, Colors.teal[700]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal[100]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children:
            _transactionTypes.map((type) {
              bool isSelected = _selectedTransactionType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTransactionType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal[50] : Colors.transparent,
                      borderRadius:
                          type == 'Deposit'
                              ? const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              )
                              : const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type == 'Deposit'
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color:
                              isSelected ? Colors.teal[700] : Colors.grey[400],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected
                                    ? Colors.teal[800]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRemarksField() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal[100]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _remarksController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.note_rounded,
            color: Colors.teal[600],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: 'Enter remarks (optional)',
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  bool _canSave() => _selectedDebit != null && _selectedCredit != null;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
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
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(
        () => _dateController.text = DateFormat('dd-MM-yyyy').format(picked),
      );
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
              content: const Text('✓ Bank voucher saved successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              behavior: SnackBarBehavior.floating,
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
              content: const Text('✓ Bank voucher deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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

  void _navigateToAddAccount(String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Addaccountsdet1(defaultAccountType: type),
      ),
    );
    if (result == true) {
      await _loadAccountsFromDB();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Account added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
