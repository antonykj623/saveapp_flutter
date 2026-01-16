// FILE: lib/view/home/widget/Bank/bank_page/BankVoucherListScreen.dart
// UPDATED with Modern Attractive Design + Premium Check + Table Layout

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Edit_voucher_bank/Edit_bank_voucherh.dart';

class BankVoucherListScreen extends StatefulWidget {
  @override
  _BankVoucherListScreenState createState() => _BankVoucherListScreenState();
}

class _BankVoucherListScreenState extends State<BankVoucherListScreen>
    with TickerProviderStateMixin {
  List<BankVoucher> _vouchers = [];
  List<BankVoucher> _filteredVouchers = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMonth = DateFormat('MMM/yyyy').format(DateTime.now());
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  final _premiumService = PremiumService();
  PremiumStatus? _premiumStatus;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadVouchers();
    _checkPremiumStatus();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _checkPremiumStatus() async {
    final status = await _premiumService.checkPremiumStatus(forceRefresh: true);
    setState(() => _premiumStatus = status);
  }

  Future<void> _loadVouchers() async {
    try {
      setState(() => _isLoading = true);

      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> voucherMaps = await db.query(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ?",
        whereArgs: [5],
      );

      Map<String, List<Map<String, dynamic>>> groupedVouchers = {};

      for (var map in voucherMaps) {
        String entryId = map['ACCOUNTS_entryid'].toString();
        if (!groupedVouchers.containsKey(entryId)) {
          groupedVouchers[entryId] = [];
        }
        groupedVouchers[entryId]!.add(map);
      }

      List<BankVoucher> vouchers = [];

      for (var entry in groupedVouchers.entries) {
        if (entry.value.length >= 2) {
          var bankEntry = entry.value.firstWhere(
            (e) => e['ACCOUNTS_cashbanktype'] == '2',
            orElse: () => entry.value.first,
          );
          var cashEntry = entry.value.firstWhere(
            (e) => e['ACCOUNTS_cashbanktype'] != '2',
            orElse: () => entry.value.last,
          );

          String bankAccountName = await _getAccountName(
            bankEntry['ACCOUNTS_setupid'].toString(),
          );
          String cashAccountName = await _getAccountName(
            cashEntry['ACCOUNTS_setupid'].toString(),
          );

          String transactionType;
          String debitAccount;
          String creditAccount;

          if (bankEntry['ACCOUNTS_type'] == 'debit') {
            transactionType = 'Deposit';
            debitAccount = bankAccountName;
            creditAccount = cashAccountName;
          } else {
            transactionType = 'Withdrawal';
            debitAccount = cashAccountName;
            creditAccount = bankAccountName;
          }

          vouchers.add(
            BankVoucher(
              id: int.parse(entry.key),
              date: _formatDateForParsing(bankEntry['ACCOUNTS_date']),
              debit: debitAccount,
              credit: creditAccount,
              amount: double.parse(bankEntry['ACCOUNTS_amount'].toString()),
              remarks: bankEntry['ACCOUNTS_remarks']?.toString() ?? '',
              transactionType: transactionType,
            ),
          );
        }
      }

      setState(() {
        _vouchers = vouchers;
        _isLoading = false;
        _filterVouchersByMonth();
      });

      _fadeController.forward();
    } catch (e) {
      print('Error loading vouchers: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDateForParsing(String dateString) {
    try {
      if (dateString.contains('/')) {
        List<String> parts = dateString.split('/');
        if (parts.length == 3) {
          String day = parts[0].padLeft(2, '0');
          String month = parts[1].padLeft(2, '0');
          String year = parts[2];
          return '$year-$month-$day';
        }
      } else if (dateString.contains('-')) {
        return dateString;
      }
      return DateTime.now().toIso8601String().split('T')[0];
    } catch (e) {
      return DateTime.now().toIso8601String().split('T')[0];
    }
  }

  Future<String> _getAccountName(String setupId) async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> accounts = await db.query(
        "TABLE_ACCOUNTSETTINGS",
        where: "keyid = ?",
        whereArgs: [setupId],
      );

      if (accounts.isNotEmpty) {
        Map<String, dynamic> accountData = jsonDecode(accounts.first["data"]);
        return accountData['Accountname']?.toString() ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _filterVouchersByMonth() {
    _filteredVouchers =
        _vouchers.where((v) {
          try {
            DateTime vDate = DateTime.parse(v.date);
            return vDate.year == _selectedDate.year &&
                vDate.month == _selectedDate.month;
          } catch (e) {
            return false;
          }
        }).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: size.height * 0.35,
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
                      Column(
                        children: [
                          const Text(
                            'Bank Vouchers',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Manage transactions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _slideController.reset();
                          _fadeController.reset();
                          _loadVouchers();
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseController.value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Month Selector
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: GestureDetector(
                      onTap: _showMonthYearPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.teal[100]!,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Period',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedMonth,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.teal[800],
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal[400]!,
                                    Colors.teal[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Vouchers List/Table
                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _fadeController,
                      curve: Curves.easeInOut,
                    ),
                    child:
                        _isLoading
                            ? _buildLoadingState()
                            : _filteredVouchers.isEmpty
                            ? _buildEmptyState()
                            : _buildVouchersTable(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.teal[600]),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Vouchers...',
            style: TextStyle(
              color: Colors.teal[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[100]!, Colors.cyan[100]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 50,
              color: Colors.teal[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Vouchers Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.teal[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first bank voucher\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVouchersTable() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      ),
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth * 0.92),
          child: Column(
            children: [
              // Table Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[600]!, Colors.teal[500]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(screenWidth * 0.20),
                    1: FixedColumnWidth(screenWidth * 0.18),
                    2: FixedColumnWidth(screenWidth * 0.18),
                    3: FixedColumnWidth(screenWidth * 0.18),
                    4: FixedColumnWidth(screenWidth * 0.18),
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildTableHeaderCell('Date'),
                        _buildTableHeaderCell('Debit'),
                        _buildTableHeaderCell('Amount'),
                        _buildTableHeaderCell('Credit'),
                        _buildTableHeaderCell('Action'),
                      ],
                    ),
                  ],
                ),
              ),

              // Table Data Rows
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(screenWidth * 0.20),
                    1: FixedColumnWidth(screenWidth * 0.18),
                    2: FixedColumnWidth(screenWidth * 0.18),
                    3: FixedColumnWidth(screenWidth * 0.18),
                    4: FixedColumnWidth(screenWidth * 0.18),
                  },
                  children:
                      _filteredVouchers.asMap().entries.map((entry) {
                        int index = entry.key;
                        BankVoucher voucher = entry.value;
                        bool isDeposit =
                            (voucher.transactionType ?? 'Deposit') == 'Deposit';

                        return TableRow(
                          decoration: BoxDecoration(
                            color:
                                index % 2 == 0 ? Colors.white : Colors.teal[50],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.teal[100]!,
                                width: 1,
                              ),
                            ),
                          ),
                          children: [
                            _buildTableDataCell(
                              _formatDisplayDate(voucher.date),
                              isBold: true,
                            ),
                            _buildTableDataCell(voucher.debit),
                            _buildTableDataCellAmount(
                              '₹${NumberFormat('#,##,##0').format(voucher.amount)}',
                              isDeposit,
                            ),
                            _buildTableDataCell(voucher.credit),
                            _buildTableActionCell(voucher),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDisplayDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d/M/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableDataCell(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTableDataCellAmount(String text, bool isDeposit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDeposit
                    ? [Colors.green[400]!, Colors.green[600]!]
                    : [Colors.orange[400]!, Colors.orange[600]!],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTableActionCell(BankVoucher voucher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _navigateToEditScreen(voucher),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _confirmDelete(voucher),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_pulseController.value * 0.1),
          child: FloatingActionButton(
            onPressed: () async {
              print('========== BANK VOUCHER ADD BUTTON CLICKED ==========');

              final canAdd = await _premiumService.canAddData(
                forceRefresh: true,
              );

              print('Premium/Trial Check: $canAdd');

              if (!canAdd) {
                print('❌ Premium expired - showing dialog');
                if (mounted) {
                  PremiumService.showPremiumExpiredDialog(context);
                }
                return;
              }

              print('✅ Can add - navigating to add screen');
              _navigateToAddScreen();
            },
            backgroundColor: Colors.transparent,
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[600]!, Colors.cyan[500]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMonthYearPicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedMonth = DateFormat('MMM/yyyy').format(pickedDate);
        _filterVouchersByMonth();
      });
    }
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => AddEditVoucherScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
    if (result == true) _loadVouchers();
  }

  void _navigateToEditScreen(BankVoucher voucher) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AddEditVoucherScreen(voucher: voucher),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
    if (result == true) _loadVouchers();
  }

  void _confirmDelete(BankVoucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Voucher',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this voucher?\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVoucher(voucher);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVoucher(BankVoucher voucher) async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
        whereArgs: [5, voucher.id.toString()],
      );
      _loadVouchers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Voucher deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
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
}
