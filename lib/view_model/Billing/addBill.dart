import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/billing_accout_setup/bill_account_setup.dart';

class AddBill extends StatefulWidget {
  final Payment? payment;

  const AddBill({super.key, this.payment});

  @override
  State<AddBill> createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> with TickerProviderStateMixin {
  int _counter = 0;
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate = DateTime.now();
  String? selectedAccount;
  String? selectedIncomeAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  List<String> accountNames = [];
  List<String> incomeAccountNames = [];
  bool _isSaving = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _incrementCounterAutomatically();
    _loadAccountsFromDB();

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _incrementCounterAutomatically() async {
    try {
      final accountsData = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');
      int maxBillNo = 0;

      for (var item in accountsData) {
        try {
          String voucherType = item['ACCOUNTS_VoucherType']?.toString() ?? '0';
          if (voucherType == '3') {
            String billNumber =
                item['ACCOUNTS_billVoucherNumber']?.toString() ?? '0';
            int billNo = int.tryParse(billNumber) ?? 0;
            if (billNo > maxBillNo) {
              maxBillNo = billNo;
            }
          }
        } catch (e) {
          print('Error parsing bill number: $e');
        }
      }

      setState(() {
        _counter = maxBillNo + 1;
      });

      print('Next bill number: $_counter');
    } catch (e) {
      print('Error getting next bill number: $e');
      setState(() {
        _counter = 1;
      });
    }
  }

  Future<void> _loadAccountsFromDB() async {
    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
      print("Loading accounts from DB: ${data.length} records found");

      setState(() {
        accountNames.clear();
        incomeAccountNames.clear();

        for (var item in data) {
          try {
            Map<String, dynamic> dat = jsonDecode(item["data"]);
            String accountType = dat['Accounttype']?.toString() ?? '';
            String accountName = dat['Accountname']?.toString() ?? '';

            if (accountType.toLowerCase().contains("customers")) {
              accountNames.add(accountName);
            } else if (accountType.toLowerCase().contains("income account")) {
              incomeAccountNames.add(accountName);
            }
          } catch (e) {
            print("Error parsing account data: $e");
          }
        }

        selectedAccount = accountNames.isNotEmpty ? accountNames[0] : null;
        selectedIncomeAccount =
            incomeAccountNames.isNotEmpty ? incomeAccountNames[0] : null;
      });
    } catch (e) {
      print("Error loading accounts: $e");
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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<String> getNextSetupId(String name) async {
    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
      for (var row in data) {
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

  Future<void> _navigateToAddAccount({bool isIncomeAccount = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Addaccountsdet1()),
    );

    if (result == true) {
      await _loadAccountsFromDB();
      if (mounted) {
        String message =
            isIncomeAccount
                ? 'Income Account added successfully'
                : 'Customer Account added successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(message),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade600, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Bill',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Bill #${_counter.toString().padLeft(4, '0')}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.note_add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            Expanded(
              child: FadeTransition(
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
                          _buildAnimatedCard(
                            delay: 100,
                            child: _buildDateSelector(),
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedCard(
                            delay: 200,
                            child: _buildCustomerAccountSection(),
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedCard(
                            delay: 300,
                            child: _buildAmountSection(),
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedCard(
                            delay: 400,
                            child: _buildIncomeAccountSection(),
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedCard(
                            delay: 500,
                            child: _buildRemarksSection(),
                          ),
                          SizedBox(height: 24),
                          if (accountNames.isEmpty ||
                              incomeAccountNames.isEmpty)
                            _buildWarningBox(),
                          SizedBox(height: 24),
                          _buildSaveButton(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Bill Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(selectedDate!),
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.teal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Customer Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedAccount,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        accountNames.map((String account) {
                          return DropdownMenuItem<String>(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAccount = newValue;
                      });
                    },
                    hint: const Text('Select Customer'),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToAddAccount(isIncomeAccount: false),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.currency_rupee,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0.00',
              prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
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
      ],
    );
  }

  Widget _buildIncomeAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.purple.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Income Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedIncomeAccount,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        incomeAccountNames.map((String account) {
                          return DropdownMenuItem<String>(
                            value: account,
                            child: Text(account),
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
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _navigateToAddAccount(isIncomeAccount: true),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notes, color: Colors.amber.shade700, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Remarks (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: TextFormField(
            controller: _remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Add any additional notes here...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please add at least one Customer Account and one Income Account before saving.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    bool isEnabled =
        accountNames.isNotEmpty &&
        incomeAccountNames.isNotEmpty &&
        selectedAccount != null &&
        selectedIncomeAccount != null &&
        !_isSaving;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient:
            isEnabled
                ? LinearGradient(
                  colors: [Colors.teal.shade500, Colors.teal.shade700],
                )
                : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400],
                ),
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isEnabled
                ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ]
                : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEnabled ? _saveBill : null,
          child: Center(
            child:
                _isSaving
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Save Bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final billno = _counter;
        final date = selectedDate;
        DateTime date1 = selectedDate!;
        int year = date1.year;
        int month = date1.month;
        final customersdata = selectedAccount;
        final amount = _amountController.text;
        final income = selectedIncomeAccount;
        final remarks = _remarksController.text;

        String setid = await getNextSetupId(customersdata.toString());
        String setupid = await getNextSetupId(income.toString());

        Map<String, dynamic> creditDatas = {
          "ACCOUNTS_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
          "ACCOUNTS_billVoucherNumber": billno.toString(),
          "ACCOUNTS_amount": amount,
          "ACCOUNTS_setupid": setid,
          "ACCOUNTS_VoucherType": 3,
          "ACCOUNTS_entryid": "0",
          "ACCOUNTS_type": "credit",
          "ACCOUNTS_remarks": remarks,
          "ACCOUNTS_year": year.toString(),
          "ACCOUNTS_month": month.toString(),
          "ACCOUNTS_cashbanktype": "0",
          "ACCOUNTS_billId": "0",
        };

        final id = await DatabaseHelper().insertData(
          "TABLE_ACCOUNTS",
          creditDatas,
        );

        if (id != null) {
          print("Credit data inserted...$id");

          Map<String, dynamic> debitDatas = {
            "ACCOUNTS_date": DateFormat('yyyy-MM-dd').format(selectedDate!),
            "ACCOUNTS_billVoucherNumber": billno.toString(),
            "ACCOUNTS_amount": amount,
            "ACCOUNTS_setupid": setupid,
            "ACCOUNTS_VoucherType": 3,
            "ACCOUNTS_entryid": id.toString(),
            "ACCOUNTS_type": "debit",
            "ACCOUNTS_remarks": remarks,
            "ACCOUNTS_year": year.toString(),
            "ACCOUNTS_month": month.toString(),
            "ACCOUNTS_cashbanktype": "0",
            "ACCOUNTS_billId": "0",
          };

          var debtdata = await DatabaseHelper().insertData(
            "TABLE_ACCOUNTS",
            debitDatas,
          );

          if (debtdata != null) {
            print("Debit data inserted...$debtdata");

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Bill saved successfully!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              Navigator.pop(context, true);
            }
          } else {
            throw Exception("Failed to insert debit data");
          }
        } else {
          throw Exception("Failed to insert credit data");
        }
      } catch (e) {
        print("Error saving bill: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Error saving bill: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
}
