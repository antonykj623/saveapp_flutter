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

class _EditBillState extends State<EditBill> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedAccount;
  String? selectedIncomeAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<Map<String, String>> accountNames = [];
  List<Map<String, String>> incomeAccountNames = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? creditAccountId;
  String? debitAccountId;

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

    _loadAccountsFromDB().then((_) {
      _loadBillData();
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
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

        for (var entry in billEntries) {
          if (entry['ACCOUNTS_type'] == 'credit') {
            creditEntry = entry;
          } else if (entry['ACCOUNTS_type'] == 'debit') {
            debitEntry = entry;
          }
        }

        if (creditEntry != null && debitEntry != null) {
          String dateStr = creditEntry['ACCOUNTS_date']?.toString() ?? '';
          try {
            if (dateStr.contains('-')) {
              List<String> parts = dateStr.split('-');
              if (parts.length == 3) {
                if (parts[0].length == 4) {
                  selectedDate = DateTime.parse(dateStr);
                } else {
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

          _amountController.text =
              creditEntry['ACCOUNTS_amount']?.toString() ?? '';
          _remarksController.text =
              creditEntry['ACCOUNTS_remarks']?.toString() ?? '';

          creditAccountId = creditEntry['ACCOUNTS_setupid']?.toString();
          debitAccountId = debitEntry['ACCOUNTS_setupid']?.toString();

          if (creditAccountId != null) {
            final customerName = await _getAccountName(creditAccountId!);
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
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Bill not found'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error loading bill: $e')),
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select a date'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (selectedAccount == null || selectedIncomeAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please select both customer and income account'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final year = selectedDate!.year.toString();
      final month = selectedDate!.month.toString();

      final customerAccountId = await getAccountId(selectedAccount!, false);
      final incomeAccountId = await getAccountId(selectedIncomeAccount!, true);

      if (customerAccountId == '0' || incomeAccountId == '0') {
        throw Exception('Invalid account selection');
      }

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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Bill updated successfully'),
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
    } catch (e) {
      print("Error updating bill: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error updating bill: $e')),
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
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteBill() async {
    setState(() {
      _isSaving = true;
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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Bill deleted successfully'),
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
    } catch (e) {
      print("Error deleting bill: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error deleting bill: $e')),
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
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning, color: Colors.red, size: 24),
                ),
                SizedBox(width: 12),
                Text('Confirm Delete'),
              ],
            ),
            content: Text(
              'Are you sure you want to delete this bill? This action cannot be undone.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteBill();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
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
                            'Edit Bill',
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
                              'Bill #${widget.billNumber.padLeft(4, '0')}',
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
                        Icons.edit_note,
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
              child:
                  _isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.teal),
                            SizedBox(height: 16),
                            Text(
                              'Loading bill details...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : FadeTransition(
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
                                  _buildActionButtons(),
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
                  selectedDate != null
                      ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                      : 'Select Date',
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
                        accountNames.map((Map<String, String> account) {
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
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than 0';
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
                        incomeAccountNames.map((Map<String, String> account) {
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

  Widget _buildActionButtons() {
    bool isEnabled =
        selectedAccount != null && selectedIncomeAccount != null && !_isSaving;

    return Column(
      children: [
        // Update Button
        Container(
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
                              'Update Bill',
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
        ),
        SizedBox(height: 16),
        // Delete Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isSaving ? null : _showDeleteConfirmation,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Delete Bill',
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
        ),
      ],
    );
  }
}
