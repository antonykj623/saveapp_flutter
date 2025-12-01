import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/model/receipt.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class AddReceiptVoucherPage extends StatefulWidget {
  final Receipt? receipt;

  const AddReceiptVoucherPage({super.key, this.receipt});

  @override
  State<AddReceiptVoucherPage> createState() => _AddReceiptVoucherPageState();
}

class _AddReceiptVoucherPageState extends State<AddReceiptVoucherPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();

  List<String> cashOptions = ['Cash'];
  List<String> bankOptions = [];
  List<String> accountOptions = [];

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
    _loadAccountsFromDB();

    if (widget.receipt != null) {
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(widget.receipt!.date);
      } catch (e) {
        try {
          selectedDate = DateFormat('yyyy-MM-dd').parse(widget.receipt!.date);
        } catch (e2) {
          try {
            selectedDate = DateFormat('dd-MM-yyyy').parse(widget.receipt!.date);
          } catch (e3) {
            selectedDate = DateTime.now();
          }
        }
      }
      selectedAccount = widget.receipt!.accountName;
      _amountController.text = widget.receipt!.amount.toString();
      paymentMode = widget.receipt!.paymentMode;
      selectedCashOption = widget.receipt!.paymentMode;
      _remarksController.text = widget.receipt!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
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

  Future<void> _loadAccountsFromDB() async {
    try {
      List<Map<String, dynamic>> accounts = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      List<String> banks = ['Bank'];
      List<String> cashAccounts = [];
      List<String> allAccounts = [];

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          if (accountType == 'customers') continue;

          allAccounts.add(accountName);
          if (accountType == 'bank') {
            if (accountName.toLowerCase() != 'bank') {
              banks.add(accountName);
            }
          } else if (accountType == 'cash' &&
              accountName.toLowerCase() != 'cash') {
            cashAccounts.add(accountName);
          }
        } catch (e) {}
      }

      setState(() {
        cashOptions = ['Cash', ...cashAccounts];
        bankOptions = banks;
        accountOptions = allAccounts;
        if (paymentMode == 'Cash') {
          if (selectedCashOption == null ||
              !cashOptions.contains(selectedCashOption))
            selectedCashOption = null;
        } else {
          if (selectedCashOption == null ||
              !bankOptions.contains(selectedCashOption))
            selectedCashOption =
                bankOptions.isNotEmpty ? bankOptions.first : null;
        }
      });
    } catch (e) {}
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

  void _showSearchableAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchableAccountDialog(
          onAccountSelected: (String accountName) {
            setState(() => selectedAccount = accountName);
            _dropdownAnimationController.forward().then(
              (_) => _dropdownAnimationController.reverse(),
            );
          },
          accountOptions: accountOptions,
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
        if (dat['Accountname'].toString().toLowerCase() == name.toLowerCase())
          return row['keyid'].toString();
      }
      return '0';
    } catch (e) {
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

    setState(() => _isSaving = true);
    _saveButtonController.forward();

    try {
      final db = await DatabaseHelper().database;
      final currentDate = selectedDate;
      final dateString =
          "${currentDate.day}/${currentDate.month}/${currentDate.year}";
      final monthString = _getMonthName(currentDate.month);
      final yearString = currentDate.year.toString();

      final accountSetupId = await getNextSetupId(selectedAccount!);
      final cashBankSetupId = await getNextSetupId(selectedCashOption!);

      if (accountSetupId == '0' || cashBankSetupId == '0')
        throw Exception('Invalid account selected');

      if (widget.receipt != null) {
        String entryId = widget.receipt!.id.toString();
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": cashBankSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [2, entryId, 'debit'],
        );

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": accountSetupId,
            "ACCOUNTS_amount": _amountController.text,
            "ACCOUNTS_remarks": _remarksController.text,
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [2, entryId, 'credit'],
        );
      } else {
        Map<String, dynamic> debitEntry = {
          'ACCOUNTS_VoucherType': 2,
          'ACCOUNTS_entryid': 0,
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': cashBankSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'debit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        final debitId = await db.insert("TABLE_ACCOUNTS", debitEntry);

        Map<String, dynamic> creditEntry = {
          'ACCOUNTS_VoucherType': 2,
          'ACCOUNTS_entryid': debitId.toString(),
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': accountSetupId,
          'ACCOUNTS_amount': _amountController.text,
          'ACCOUNTS_type': 'credit',
          'ACCOUNTS_remarks': _remarksController.text,
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
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
      }

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) throw Exception('Double-entry accounting is unbalanced');

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Receipt saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        _saveButtonController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          widget.receipt != null
              ? 'Edit Receipt Voucher'
              : 'Add Receipt Voucher',
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
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- DATE ----------
                  _buildAnimatedCard(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
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
                            Icon(Icons.arrow_drop_down, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- ACCOUNT ----------
                  _buildAnimatedCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _showSearchableAccountDialog(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            selectedAccount ??
                                                'Select an Account',
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
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildAddButton(() async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Addaccountsdet(),
                            ),
                          );
                          if (result == true) {
                            await _loadAccountsFromDB();
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text('Account added successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- AMOUNT ----------
                  _buildAnimatedCard(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
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
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.attach_money,
                              color: Colors.teal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Amount',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter an amount';
                                if (double.tryParse(value) == null)
                                  return 'Please enter a valid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- PAYMENT MODE ----------
                  _buildAnimatedCard(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
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
                                    setState(() {
                                      paymentMode = 'Bank';
                                      if (bankOptions.isNotEmpty)
                                        selectedCashOption = bankOptions.first;
                                    });
                                    _modeAnimationController.forward().then(
                                      (_) => _modeAnimationController.reverse(),
                                    );
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
                                    setState(() {
                                      paymentMode = 'Cash';
                                      selectedCashOption = null;
                                    });
                                    _modeAnimationController.forward().then(
                                      (_) => _modeAnimationController.reverse(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- CASH / BANK DROPDOWN ----------
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAnimatedCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
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
                                              ? Colors.green.shade50
                                              : Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      paymentMode == 'Bank'
                                          ? Icons.account_balance
                                          : Icons.money,
                                      color:
                                          paymentMode == 'Bank'
                                              ? Colors.green
                                              : Colors.teal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        value:
                                            paymentMode == 'Cash'
                                                ? (cashOptions.contains(
                                                      selectedCashOption,
                                                    )
                                                    ? selectedCashOption
                                                    : null)
                                                : (bankOptions.contains(
                                                      selectedCashOption,
                                                    )
                                                    ? selectedCashOption
                                                    : (bankOptions.isNotEmpty
                                                        ? bankOptions.first
                                                        : null)),
                                        isExpanded: true,
                                        hint: Text(
                                          'Select ${paymentMode == 'Bank' ? 'Bank' : 'Cash'} Account',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCashOption = newValue!;
                                            paymentMode =
                                                bankOptions.contains(newValue)
                                                    ? 'Bank'
                                                    : 'Cash';
                                          });
                                          _dropdownAnimationController
                                              .forward()
                                              .then(
                                                (_) =>
                                                    _dropdownAnimationController
                                                        .reverse(),
                                              );
                                        },
                                        items:
                                            paymentMode == 'Cash'
                                                ? cashOptions
                                                    .map<
                                                      DropdownMenuItem<String>
                                                    >(
                                                      (
                                                        String v,
                                                      ) => DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: v,
                                                        child: Text(
                                                          v,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList()
                                                : bankOptions
                                                    .map<
                                                      DropdownMenuItem<String>
                                                    >(
                                                      (
                                                        String v,
                                                      ) => DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: v,
                                                        child: Text(
                                                          v,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Addaccountsdet(),
                              ),
                            );
                            if (result == true) await _loadAccountsFromDB();
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- REMARKS ----------
                  _buildAnimatedCard(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
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
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.notes,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
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
                              hintText: 'Enter remarks or notes...',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ---------- SAVE BUTTON ----------
                  Center(
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              _isSaving ? null : _saveDoubleEntryAccounts,
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
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Save Receipt',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
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

  // -----------------------------------------------------------------
  // Helper widgets
  // -----------------------------------------------------------------
  Widget _buildAnimatedCard({required Widget child}) =>
      TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder:
            (context, value, child) => Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Opacity(opacity: value, child: child),
            ),
        child: child,
      );

  Widget _buildPaymentModeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                )
                : null,
        color: isSelected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
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
            color: isSelected ? Colors.white : Colors.grey.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
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
        colors: [Colors.green.shade400, Colors.green.shade600],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
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
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    ),
  );
}

// ================================================================
// Searchable Account Dialog (green theme)
// ================================================================
class SearchableAccountDialog extends StatefulWidget {
  final Function(String) onAccountSelected;
  final List<String> accountOptions;

  const SearchableAccountDialog({
    super.key,
    required this.onAccountSelected,
    required this.accountOptions,
  });

  @override
  State<SearchableAccountDialog> createState() =>
      _SearchableAccountDialogState();
}

class _SearchableAccountDialogState extends State<SearchableAccountDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  late AnimationController _dialogAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _dialogAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
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
                colors: [Colors.white, Colors.green.shade50],
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
                        color: Colors.green,
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
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      hintText: 'Search by Account Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filteredAccounts =
                          widget.accountOptions
                              .where(
                                (account) =>
                                    searchQuery.isEmpty ||
                                    account.toLowerCase().contains(
                                      searchQuery.toLowerCase(),
                                    ),
                              )
                              .toList();

                      if (filteredAccounts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                color: Colors.grey[400],
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No accounts found'
                                    : 'No matching accounts',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredAccounts.length,
                        itemBuilder: (context, index) {
                          final accountName = filteredAccounts[index];
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder:
                                (context, value, child) => Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  accountName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  widget.onAccountSelected(accountName);
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
