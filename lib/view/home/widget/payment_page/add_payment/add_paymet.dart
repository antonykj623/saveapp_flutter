import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Main_budget_screen.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/Accountfiles/CashAccount.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/budget_class/budget_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Edit_budget_screen/Edit_budget_screen.dart';

class AddPaymentVoucherPage extends StatefulWidget {
  final Payment? payment;
  const AddPaymentVoucherPage({super.key, this.payment});

  @override
  State<AddPaymentVoucherPage> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddPaymentVoucherPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();

  List<String> cashOptions = [];
  List<String> bankOptions = [];
  List<String> allBankCashOptions = [];

  late AnimationController _pageAnimationController;
  late AnimationController _modeAnimationController;
  late AnimationController _dropdownAnimationController;
  late AnimationController _saveButtonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadBankCashOptions();
    fixDefaultAccounts();

    if (widget.payment != null) {
      selectedDate = _parseDate(widget.payment!.date);
      selectedAccount = widget.payment!.accountName;
      _amountController.text =
          widget.payment!.amount.toString(); // From payment only
      paymentMode = widget.payment!.paymentMode;
      selectedCashOption = widget.payment!.paymentMode;
      _remarksController.text = widget.payment!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
      // DO NOT auto-fill amount from budget
    }
  }

  DateTime _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd').parse(date);
      } catch (_) {
        try {
          return DateFormat('dd-MM-yyyy').parse(date);
        } catch (_) {
          return DateTime.now();
        }
      }
    }
  }

  Future<void> fixDefaultAccounts() async {
    await CashAccountHelper.ensureDefaultAccountsExist();
  }

  void _setupAnimations() {
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _modeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dropdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _saveButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageAnimationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _modeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _saveButtonController, curve: Curves.easeInOut),
    );

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _pageAnimationController.dispose();
    _modeAnimationController.dispose();
    _dropdownAnimationController.dispose();
    _saveButtonController.dispose();
    super.dispose();
  }

  // ========================================
  // 1. LOAD BANK & CASH OPTIONS
  // ========================================
  Future<void> _loadBankCashOptions() async {
    try {
      final accounts = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      final List<String> banks = [];
      final List<String> cash = [];

      for (final acc in accounts) {
        if (acc["data"] == null || acc["data"].toString().isEmpty) continue;
        final data = jsonDecode(acc["data"]);
        final type =
            (data['Accounttype'] ?? '').toString().toLowerCase().trim();
        final name = (data['Accountname'] ?? '').toString().trim();

        if (type.isEmpty || name.isEmpty) continue;
        if (type == 'customers' || type == 'customer') continue;

        if (type == 'bank' && !banks.contains(name))
          banks.add(name);
        else if (type == 'cash' && !cash.contains(name))
          cash.add(name);
      }

      if (cash.isEmpty) cash.add('Cash');
      if (banks.isEmpty) banks.add('Bank');

      setState(() {
        cashOptions = cash;
        bankOptions = banks;
        allBankCashOptions = [...cashOptions, ...bankOptions];

        if (widget.payment == null) {
          selectedCashOption =
              paymentMode == 'Cash'
                  ? (cashOptions.isNotEmpty ? cashOptions.first : null)
                  : (bankOptions.isNotEmpty ? bankOptions.first : null);
        } else {
          selectedCashOption =
              (paymentMode == 'Cash' &&
                      cashOptions.contains(selectedCashOption))
                  ? selectedCashOption
                  : (paymentMode == 'Bank' &&
                      bankOptions.contains(selectedCashOption))
                  ? selectedCashOption
                  : (paymentMode == 'Cash'
                      ? cashOptions.first
                      : bankOptions.first);
        }
      });
    } catch (e) {
      setState(() {
        cashOptions = ['Cash'];
        bankOptions = ['Bank'];
        allBankCashOptions = ['Cash', 'Bank'];
        selectedCashOption = paymentMode == 'Cash' ? 'Cash' : 'Bank';
      });
    }
  }

  // ========================================
  // 2. DATE PICKER
  // ========================================
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder:
          (c, child) => Theme(
            data: Theme.of(c).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != selectedDate)
      setState(() => selectedDate = picked);
  }

  // ========================================
  // 3. ACCOUNT SEARCH DIALOG
  // ========================================
  void _showSearchableAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => SearchableAccountDialog(
            onAccountSelected: (name) {
              setState(() => selectedAccount = name);
              _dropdownAnimationController.forward().then(
                (_) => _dropdownAnimationController.reverse(),
              );
            },
          ),
    );
  }

  // ========================================
  // 4. SETUP ID LOOKUP
  // ========================================
  Future<String> getNextSetupId(String name) async {
    try {
      final db = await DatabaseHelper().database;
      final rows = await db.query('TABLE_ACCOUNTSETTINGS');
      for (final row in rows) {
        if (row["data"] == null) continue;
        final data = jsonDecode(row["data"].toString());
        final accName = (data['Accountname'] ?? '').toString().trim();
        if (accName.toLowerCase() == name.toLowerCase().trim()) {
          return row['keyid'].toString();
        }
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // ========================================
  // 5. BUDGET CHECK – ONLY VALIDATION (NO MODIFICATION)
  // ========================================
  Future<bool> _checkBudgetExceeded() async {
    if (selectedAccount == null) return false;

    try {
      final db = await DatabaseHelper().database;
      final monthStr = _getMonthName(selectedDate.month);
      final yearStr = selectedDate.year.toString();

      // Get budget (only for comparison)
      final budgetRows = await db.query(
        'TABLE_BUDGET',
        where: 'account_name = ? AND month = ? AND year = ?',
        whereArgs: [selectedAccount, monthStr, yearStr],
      );

      if (budgetRows.isEmpty) return false;

      final budgetAmount = (budgetRows.first['amount'] as num).toDouble();
      final setupId = await getNextSetupId(selectedAccount!);
      if (setupId == '0') return false;

      // Total spent so far (only actual payments)
      final paymentRows = await db.rawQuery(
        '''
        SELECT SUM(CAST(ACCOUNTS_amount AS REAL)) as total
        FROM TABLE_ACCOUNTS
        WHERE ACCOUNTS_setupid = ?
          AND ACCOUNTS_month = ?
          AND ACCOUNTS_year = ?
          AND ACCOUNTS_type = 'debit'
          AND ACCOUNTS_VoucherType = 1
      ''',
        [setupId, monthStr, yearStr],
      );

      double totalSpent = 0.0;
      if (paymentRows.isNotEmpty && paymentRows.first['total'] != null) {
        totalSpent = (paymentRows.first['total'] as num).toDouble();
      }

      // Subtract current payment if editing
      if (widget.payment != null) {
        totalSpent -= widget.payment!.amount;
      }

      // USER-ENTERED AMOUNT ONLY
      final userInput = _amountController.text.replaceAll(',', '').trim();
      final userAmount = double.tryParse(userInput) ?? 0.0;

      final willExceed = (totalSpent + userAmount) > budgetAmount;

      print(
        'Budget Check: Budget=$budgetAmount, Spent=$totalSpent, UserAmount=$userAmount, Exceeds=$willExceed',
      );

      return willExceed;
    } catch (e) {
      print('Budget check error: $e');
      return false;
    }
  }

  // ========================================
  // 6. SAVE – ONLY USER AMOUNT IS SAVED
  // ========================================
  Future<void> _saveDoubleEntryAccounts() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAccount == null || selectedAccount!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedCashOption == null || selectedCashOption!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a ${paymentMode == 'Bank' ? 'bank' : 'cash'} account',
          ),
        ),
      );
      return;
    }

    // Budget warning only
    final budgetExceeded = await _checkBudgetExceeded();
    if (budgetExceeded) {
      final proceed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Budget Exceeded')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount Exceeds Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The payment for "$selectedAccount" will exceed your budget for ${_getMonthName(selectedDate.month).toUpperCase()} ${selectedDate.year}.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Do you want to proceed anyway?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Proceed Anyway',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
      if (proceed != true) return;
    }

    setState(() => _isSaving = true);
    _saveButtonController.forward();

    try {
      final db = await DatabaseHelper().database;
      final dateStr =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      final monthStr = _getMonthName(selectedDate.month);
      final yearStr = selectedDate.year.toString();

      final firstId = await getNextSetupId(selectedAccount!);
      final contraId = await getNextSetupId(selectedCashOption!);

      if (firstId == '0')
        throw Exception('Account not found: $selectedAccount');
      if (contraId == '0')
        throw Exception('$paymentMode account not found: $selectedCashOption');

      // ONLY USER AMOUNT
      final cleanAmt = _amountController.text.replaceAll(',', '').trim();
      final amount = double.parse(cleanAmt);
      if (amount <= 0) throw Exception('Amount must be > 0');

      final walletData = {
        "date": DateFormat('yyyy-MM-dd').format(selectedDate),
        "month_selected": selectedDate.month,
        "yearselected": selectedDate.year,
        "edtAmount": (-amount).toString(),
        "description": "Payment to $selectedAccount via $selectedCashOption",
        "paymentMethod": selectedCashOption,
        "paymentEntryId": widget.payment?.id?.toString() ?? '',
      };

      if (widget.payment != null) {
        final entryId = widget.payment!.id.toString();

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateStr,
            "ACCOUNTS_setupid": firstId,
            "ACCOUNTS_amount": cleanAmt,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearStr,
            "ACCOUNTS_month": monthStr,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [1, entryId, 'debit'],
        );

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateStr,
            "ACCOUNTS_setupid": contraId,
            "ACCOUNTS_amount": cleanAmt,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearStr,
            "ACCOUNTS_month": monthStr,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [1, entryId, 'credit'],
        );

        final walletRows = await db.query(
          'TABLE_WALLET',
          where: "data LIKE ?",
          whereArgs: ['%"paymentEntryId":"$entryId"%'],
        );
        if (walletRows.isNotEmpty) {
          await db.update(
            'TABLE_WALLET',
            {"data": jsonEncode(walletData)},
            where: "keyid = ?",
            whereArgs: [walletRows.first['keyid']],
          );
        } else {
          await DatabaseHelper().addData(
            'TABLE_WALLET',
            jsonEncode(walletData),
          );
        }
      } else {
        final debitEntry = {
          'ACCOUNTS_VoucherType': 1,
          'ACCOUNTS_entryid': 0,
          'ACCOUNTS_date': dateStr,
          'ACCOUNTS_setupid': firstId,
          'ACCOUNTS_amount': cleanAmt,
          'ACCOUNTS_type': 'debit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearStr,
          'ACCOUNTS_month': monthStr,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };
        final debitId = await db.insert("TABLE_ACCOUNTS", debitEntry);

        final creditEntry = {
          'ACCOUNTS_VoucherType': 1,
          'ACCOUNTS_entryid': debitId.toString(),
          'ACCOUNTS_date': dateStr,
          'ACCOUNTS_setupid': contraId,
          'ACCOUNTS_amount': cleanAmt,
          'ACCOUNTS_type': 'credit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearStr,
          'ACCOUNTS_month': monthStr,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
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

        walletData['paymentEntryId'] = debitId.toString();
        await DatabaseHelper().addData('TABLE_WALLET', jsonEncode(walletData));
      }

      final balanced = await DatabaseHelper().validateDoubleEntry();
      if (!balanced) throw Exception('Accounting validation failed');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.payment != null ? 'Payment updated' : 'Payment saved',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        _saveButtonController.reverse();
      }
    }
  }

  // ========================================
  // UI BUILD
  // ========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Text(
          widget.payment != null
              ? 'Edit Payment Voucher'
              : 'Add Payment Voucher',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedCard(child: _buildDateField()),
                  const SizedBox(height: 16),

                  _buildAnimatedCard(
                    child: Row(
                      children: [
                        Expanded(child: _buildAccountField()),
                        const SizedBox(width: 12),
                        _buildAddButton(() async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Addaccountsdet()),
                          );
                          if (res == true) await _loadBankCashOptions();
                        }),
                      ],
                    ),
                  ),

                  // SET BUDGET BUTTON
                  if (selectedAccount != null) ...[
                    const SizedBox(height: 12),
                    _buildAnimatedCard(
                      child: InkWell(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BudgetScreen()),
                            ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade50,
                                Colors.purple.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.purple.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Set Budget',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  _buildAnimatedCard(child: _buildAmountField()),
                  const SizedBox(height: 24),
                  _buildAnimatedCard(child: _buildPaymentModeField()),
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAnimatedCard(child: _buildCashBankField()),
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedCard(child: _buildRemarksField()),
                  const SizedBox(height: 32),

                  Center(
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: _buildSaveButton(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // HELPER WIDGETS
  // ========================================
  Widget _buildDateField() => InkWell(
    onTap: () => _selectDate(context),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('dd-MM-yyyy').format(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.blue),
        ],
      ),
    ),
  );

  Widget _buildAccountField() => InkWell(
    onTap: () => _showSearchableAccountDialog(context),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedAccount ?? 'Select an Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          selectedAccount != null
                              ? Colors.black87
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.blue),
        ],
      ),
    ),
  );

  Widget _buildAmountField() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.currency_rupee,
            color: Colors.green,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Amount',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter amount';
              final clean = v.replaceAll(',', '').trim();
              final n = double.tryParse(clean);
              if (n == null) return 'Invalid number';
              if (n <= 0) return 'Amount must be > 0';
              if (n > 999999999999) return 'Amount too large';
              return null;
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildPaymentModeField() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentModeOption(
                'Bank',
                Icons.account_balance,
                paymentMode == 'Bank',
                () {
                  setState(() => paymentMode = 'Bank');
                  if (!bankOptions.contains(selectedCashOption))
                    selectedCashOption =
                        bankOptions.isNotEmpty ? bankOptions.first : null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentModeOption(
                'Cash',
                Icons.money,
                paymentMode == 'Cash',
                () {
                  setState(() => paymentMode = 'Cash');
                  if (!cashOptions.contains(selectedCashOption))
                    selectedCashOption =
                        cashOptions.isNotEmpty ? cashOptions.first : null;
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildCashBankField() => Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      paymentMode == 'Bank'
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  paymentMode == 'Bank' ? Icons.account_balance : Icons.money,
                  color: paymentMode == 'Bank' ? Colors.blue : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: InputBorder.none),
                    value:
                        paymentMode == 'Cash'
                            ? (cashOptions.contains(selectedCashOption)
                                ? selectedCashOption
                                : null)
                            : (bankOptions.contains(selectedCashOption)
                                ? selectedCashOption
                                : null),
                    isExpanded: true,
                    hint: Text(
                      'Select ${paymentMode == 'Bank' ? 'Bank' : 'Cash'} Account',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onChanged: (v) => setState(() => selectedCashOption = v!),
                    items:
                        (paymentMode == 'Cash' ? cashOptions : bankOptions)
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 12),
      _buildAddButton(() async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Addaccountsdet()),
        );
        if (res == true) await _loadBankCashOptions();
      }),
    ],
  );

  Widget _buildRemarksField() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notes, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Remarks',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _remarksController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter remarks...',
          ),
        ),
      ],
    ),
  );

  Widget _buildSaveButton() => Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade600],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _isSaving ? null : _saveDoubleEntryAccounts,
      child:
          _isSaving
              ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
              : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Save Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
    ),
  );

  Widget _buildPaymentModeOption(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient:
            selected
                ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                )
                : null,
        color: selected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? Colors.blue.shade600 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : Colors.grey.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAddButton(VoidCallback onPressed) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade600],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    ),
  );

  Widget _buildAnimatedCard({required Widget child}) =>
      TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder:
            (_, v, c) => Transform.scale(
              scale: 0.95 + 0.05 * v,
              child: Opacity(opacity: v, child: c),
            ),
        child: child,
      );
}

// ========================================
// SEARCHABLE ACCOUNT DIALOG (UNCHANGED)
// ========================================
class SearchableAccountDialog extends StatefulWidget {
  final Function(String) onAccountSelected;
  const SearchableAccountDialog({super.key, required this.onAccountSelected});

  @override
  State<SearchableAccountDialog> createState() =>
      _SearchableAccountDialogState();
}

class _SearchableAccountDialogState extends State<SearchableAccountDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  String query = '';
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _search.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            height: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Select Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      hintText: 'Search by Account Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper().getAllData(
                      "TABLE_ACCOUNTSETTINGS",
                    ),
                    builder: (c, snap) {
                      if (snap.connectionState == ConnectionState.waiting)
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        );
                      if (snap.hasError)
                        return Center(
                          child: Text(
                            'Error: ${snap.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );

                      final all = snap.data ?? [];
                      final filtered =
                          all.where((row) {
                            if (row["data"] == null) return false;
                            final data = jsonDecode(row["data"]);
                            final type =
                                (data['Accounttype'] ?? '')
                                    .toString()
                                    .toLowerCase();
                            final name = (data['Accountname'] ?? '').toString();
                            if (type == 'customers') return false;
                            return query.isEmpty ||
                                name.toLowerCase().contains(
                                  query.toLowerCase(),
                                );
                          }).toList();

                      if (filtered.isEmpty)
                        return const Center(child: Text('No accounts found'));

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final row = filtered[i];
                          final data = jsonDecode(row["data"]);
                          final name = data['Accountname'].toString();
                          final type =
                              data['Accounttype'].toString().toUpperCase();

                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300 + i * 50),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder:
                                (_, v, child) => Transform.translate(
                                  offset: Offset(0, 20 * (1 - v)),
                                  child: Opacity(opacity: v, child: child),
                                ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    type.toLowerCase() == 'bank'
                                        ? Icons.account_balance
                                        : Icons.account_balance_wallet,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  type,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                onTap: () {
                                  widget.onAccountSelected(name);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
