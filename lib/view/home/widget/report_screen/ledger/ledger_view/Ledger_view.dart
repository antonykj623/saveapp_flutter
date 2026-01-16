import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../save_DB/Budegt_database_helper/Save_DB.dart';

class Ledgercash extends StatefulWidget {
  final String accountName;

  const Ledgercash({super.key, required this.accountName});

  @override
  State<Ledgercash> createState() => _LedgercashState();
}

class _LedgercashState extends State<Ledgercash>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late DateTime selected_startDate;
  late DateTime selected_endDate;
  List<Map<String, dynamic>> transactions = [];
  double openingBalance = 0;
  double closingBalance = 0;
  double totalDebits = 0;
  double totalCredits = 0;
  int totalTransactions = 0;
  int debitCount = 0;
  int creditCount = 0;
  String accountType = '';
  final ScrollController _verticalScrollController = ScrollController();
  bool _isLoading = false;
  bool _showScrollToTop = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _waveController;
  late AnimationController _searchButtonController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  List<Particle> _particles = [];
  Timer? _waveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    selected_endDate = DateTime.now();
    selected_startDate = DateTime(
      selected_endDate.year,
      selected_endDate.month,
      1,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _searchButtonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
        _searchButtonController.forward();
      }
    });

    _loadTransactions();

    _verticalScrollController.addListener(() {
      setState(() => _showScrollToTop = _verticalScrollController.offset > 400);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _waveController.dispose();
    _searchButtonController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _verticalScrollController.dispose();
    _waveTimer?.cancel();
    super.dispose();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e2) {
        try {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (e3) {
          return DateTime.now();
        }
      }
    }
  }

  bool _isDateInRange(String dateStr, DateTime start, DateTime end) {
    try {
      DateTime txDate = _parseDate(dateStr);
      DateTime startOfDay = DateTime(start.year, start.month, start.day);
      DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
      return txDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadTransactions() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;

      final accountResult = await db.query(
        'TABLE_ACCOUNTSETTINGS',
        where: "data LIKE ?",
        whereArgs: ['%\"Accountname\":\"${widget.accountName}\"%'],
      );

      if (accountResult.isEmpty) {
        setState(() {
          transactions.clear();
          totalTransactions = debitCount = creditCount = 0;
          totalDebits = totalCredits = closingBalance = 0;
          _isLoading = false;
        });
        return;
      }

      final account = accountResult.first;
      final setupId = account['keyid'].toString();
      final accountData = jsonDecode(account['data'] as String);
      accountType = (accountData['Type']?.toString() ?? 'debit').toLowerCase();
      openingBalance =
          double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0.0;

      final allTx = await db.query(
        'TABLE_ACCOUNTS',
        where: "ACCOUNTS_setupid = ?",
        whereArgs: [setupId],
        orderBy: "ACCOUNTS_date ASC, ACCOUNTS_id ASC",
      );

      List<Map<String, dynamic>> periodTx = [];
      for (var tx in allTx) {
        if (_isDateInRange(
          tx['ACCOUNTS_date'].toString(),
          selected_startDate,
          selected_endDate,
        )) {
          periodTx.add(tx);
        }
      }

      // Build contra account map
      final allAccounts = await db.query('TABLE_ACCOUNTSETTINGS');
      Map<String, String> idToName = {};
      for (var acc in allAccounts) {
        try {
          final data = jsonDecode(acc['data'] as String);
          idToName[acc['keyid'].toString()] = data['Accountname'] ?? 'Unknown';
        } catch (_) {}
      }

      List<Map<String, dynamic>> txList = [];
      double running = openingBalance;
      double debits = 0, credits = 0;
      int drCount = 0, crCount = 0;

      for (var tx in periodTx) {
        double amount = double.parse(tx['ACCOUNTS_amount'].toString());
        bool isDebit = tx['ACCOUNTS_type'].toString().toLowerCase() == 'debit';
        int voucherType =
            int.tryParse(tx['ACCOUNTS_VoucherType']?.toString() ?? '0') ?? 0;
        String entryId = tx['ACCOUNTS_entryid']?.toString() ?? '';

        if (isDebit) {
          debits += amount;
          drCount++;
        } else {
          credits += amount;
          crCount++;
        }

        // Find contra account
        String contraName = '';
        if (entryId.isNotEmpty) {
          final contra = await db.query(
            'TABLE_ACCOUNTS',
            where: "ACCOUNTS_entryid = ? AND ACCOUNTS_setupid != ?",
            whereArgs: [entryId, setupId],
            limit: 1,
          );
          if (contra.isNotEmpty) {
            contraName =
                idToName[contra.first['ACCOUNTS_setupid'].toString()] ??
                'Unknown';
          }
        }

        String desc =
            contraName.isNotEmpty
                ? (voucherType == 1
                    ? (isDebit
                        ? 'Payment To $contraName'
                        : 'Payment From $contraName')
                    : (isDebit
                        ? 'Receipt From $contraName'
                        : 'Receipt To $contraName'))
                : (tx['ACCOUNTS_remarks']?.toString() ?? 'Transaction');

        // Update running balance
        if (accountType == 'debit') {
          running = isDebit ? running + amount : running - amount;
        } else {
          running = isDebit ? running - amount : running + amount;
        }

        txList.add({
          'date': tx['ACCOUNTS_date'],
          'description': desc,
          'debit': isDebit ? amount : 0.0,
          'credit': isDebit ? 0.0 : amount,
          'balance': running,
          'raw': tx, // Keep raw data for future use if needed
        });
      }

      setState(() {
        transactions = txList;
        totalTransactions = txList.length;
        debitCount = drCount;
        creditCount = crCount;
        totalDebits = debits;
        totalCredits = credits;
        closingBalance = running;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Ledger Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ledger: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? selected_startDate : selected_endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.teal),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          selected_startDate = picked;
        else
          selected_endDate = picked;
      });
    }
  }

  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  Widget _header(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade500],
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, int flex, {Color? color}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: color ?? Colors.black87,
            fontWeight: color != null ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _viewButton() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction details coming soon!'),
                backgroundColor: Colors.teal,
              ),
            );
          },
          icon: const Icon(Icons.remove_red_eye, size: 16),
          label: const Text('View', style: TextStyle(fontSize: 10)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.blue.shade700],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          '${widget.accountName} Ledger',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Date Pickers
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _dateCard('From', _fmt(selected_startDate), true),
                ),
                const SizedBox(width: 12),
                Expanded(child: _dateCard('To', _fmt(selected_endDate), false)),
              ],
            ),
          ),

          // Search Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _loadTransactions,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.search),
            label: Text(_isLoading ? 'Loading...' : 'Search Ledger'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              padding: const EdgeInsets.all(16),
            ),
          ).paddingSymmetric(horizontal: 16, vertical: 12),
 
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summary(
                  'Transactions',
                  totalTransactions.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _summary(
                  'Debits',
                  debitCount.toString(),
                  Icons.arrow_downward,
                  Colors.orange,
                ),
                _summary(
                  'Credits',
                  creditCount.toString(),
                  Icons.arrow_upward,
                  Colors.purple,
                ),
                _summary(
                  'Closing',
                  '₹${closingBalance.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  closingBalance >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Table Header (Type column removed)
          Row(
            children: [
              _header('Date', 2),
              _header('Particulars', 4),
              _header('Debit', 2),
              _header('Credit', 2),
              _header('Balance', 2),
              _header('Action', 2),
            ],
          ),

          // Transaction Rows
          Expanded(
            child:
                transactions.isEmpty
                    ? const Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      controller: _verticalScrollController,
                      itemCount: transactions.length,
                      itemBuilder: (context, i) {
                        final tx = transactions[i];
                        final isEven = i % 2 == 0;
                        return Container(
                          color: isEven ? Colors.grey.shade50 : Colors.white,
                          child: Row(
                            children: [
                              _cell(
                                DateFormat(
                                  'dd/MM',
                                ).format(_parseDate(tx['date'])),
                                2,
                              ),
                              _cell(tx['description'], 4),
                              _cell(
                                tx['debit'] > 0
                                    ? tx['debit'].toStringAsFixed(2)
                                    : '-',
                                2,
                                color: Colors.orange.shade700,
                              ),
                              _cell(
                                tx['credit'] > 0
                                    ? tx['credit'].toStringAsFixed(2)
                                    : '-',
                                2,
                                color: Colors.purple.shade700,
                              ),
                              _cell(
                                tx['balance'].toStringAsFixed(2),
                                2,
                                color:
                                    tx['balance'] >= 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                              ),
                              _viewButton(),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      floatingActionButton:
          _showScrollToTop
              ? FloatingActionButton(
                backgroundColor: Colors.teal,
                child: const Icon(Icons.arrow_upward),
                onPressed:
                    () => _verticalScrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    ),
              )
              : null,
    );
  }

  Widget _dateCard(String label, String date, bool isStart) {
    return GestureDetector(
      onTap: () => selectDate(isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class Particle {
  double x, y, speedX, speedY, opacity = 1.0;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedX,
    required this.speedY,
  });
}
