import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/report_screen/ledger/ledger_view/Ledger_view.dart';
import 'package:new_project_2025/view_model/CashBank/ledgerCashtable.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Cashbank extends StatefulWidget {
  const Cashbank({super.key});

  @override
  State<Cashbank> createState() => _CashbankState();
}

class _CashbankState extends State<Cashbank>
    with SingleTickerProviderStateMixin {
  late DateTime selected_startDate;
  late DateTime selected_endDate;
  List<Map<String, dynamic>> accountBalances = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selected_endDate = DateTime.now();
    selected_startDate = DateTime(
      selected_endDate.year,
      selected_endDate.month,
      1,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadReceipts();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parseStrict(dateStr);
      } catch (e2) {
        try {
          return DateFormat('dd-MM-yyyy').parseStrict(dateStr);
        } catch (e3) {
          print('Date parse error: $dateStr');
          return DateTime.now();
        }
      }
    }
  }

  Future<void> _loadReceipts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      List<Map<String, dynamic>> balances = [];

      DateTime periodStartInclusive = selected_startDate;
      DateTime periodEndInclusive = DateTime(
        selected_endDate.year,
        selected_endDate.month,
        selected_endDate.day,
        23,
        59,
        59,
      );
      DateTime openingBalanceCutoff = selected_startDate;

      for (var account in accounts) {
        final data = account['data'];
        if (data is! String) continue;

        Map<String, dynamic> accountData = jsonDecode(data);
        String accountType =
            (accountData['Accounttype']?.toString() ?? '').toLowerCase();
        if (accountType != 'cash' && accountType != 'bank') continue;

        String accountName =
            accountData['Accountname']?.toString() ?? 'Unknown';
        String accountNature =
            (accountData['Type']?.toString() ?? 'debit').toLowerCase();
        double initialBalance =
            double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0.0;
        String setupId = account['keyid'].toString();

        final allTxRaw = await db.query(
          'TABLE_ACCOUNTS',
          where: "ACCOUNTS_setupid = ?",
          whereArgs: [setupId],
        );

        List<Map<String, dynamic>> allTransactions =
            allTxRaw.map((e) => Map<String, dynamic>.from(e)).toList();

        allTransactions.sort((a, b) {
          DateTime da = _parseDate(a['ACCOUNTS_date'].toString());
          DateTime db = _parseDate(b['ACCOUNTS_date'].toString());
          return da.compareTo(db);
        });

        double runningBalance = initialBalance;

        // Opening Balance
        for (var tx in allTransactions) {
          DateTime txDate = _parseDate(tx['ACCOUNTS_date'].toString());
          if (txDate.isBefore(openingBalanceCutoff)) {
            double amount = double.parse(tx['ACCOUNTS_amount'].toString());
            bool isDebit =
                (tx['ACCOUNTS_type']?.toString() ?? '').toLowerCase() ==
                'debit';

            if (accountNature == 'debit') {
              runningBalance += isDebit ? amount : -amount;
            } else {
              runningBalance += isDebit ? -amount : amount;
            }
          }
        }

        double periodOpeningBalance = runningBalance;
        double totalReceipts = 0.0;
        double totalPayments = 0.0;

        // Period transactions
        for (var tx in allTransactions) {
          DateTime txDate = _parseDate(tx['ACCOUNTS_date'].toString());
          bool isInPeriod =
              !txDate.isBefore(periodStartInclusive) &&
              !txDate.isAfter(periodEndInclusive);

          if (isInPeriod) {
            double amount = double.parse(tx['ACCOUNTS_amount'].toString());
            int voucherType =
                int.tryParse(tx['ACCOUNTS_VoucherType']?.toString() ?? '0') ??
                0;

            if (voucherType == 1) {
              totalPayments += amount;
            } else if (voucherType == 2) {
              totalReceipts += amount;
            }
          }
        }

        double closingBalance =
            accountNature == 'debit'
                ? periodOpeningBalance + totalReceipts - totalPayments
                : periodOpeningBalance - totalReceipts + totalPayments;

        balances.add({
          'accountName': accountName,
          'accountType': accountType,
          // 'type' field removed intentionally
          'openingBalance': periodOpeningBalance,
          'totalReceipts': totalReceipts,
          'totalPayments': totalPayments,
          'balance': closingBalance,
        });
      }

      setState(() {
        accountBalances = balances;
        total = balances.fold(0.0, (sum, e) => sum + (e['balance'] as double));
        _isLoading = false;
      });

      _animationController.forward(from: 0.0);
    } catch (e, stack) {
      print('Error in _loadReceipts: $e\n$stack');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? selected_startDate : selected_endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          selected_startDate = picked;
        } else {
          selected_endDate = picked;
        }
      });
    }
  }

  String _getDisplayStartDate() =>
      DateFormat('dd/MM/yyyy').format(selected_startDate);
  String _getDisplayEndDate() =>
      DateFormat('dd/MM/yyyy').format(selected_endDate);

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade500],
          ),
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, Color? textColor}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textColor ?? Colors.black87,
            fontWeight: textColor != null ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _actionButton({required String accountName, required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Ledgercash(accountName: accountName),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            "View",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Color _getBalanceColor(double balance) =>
      balance > 0
          ? Colors.green.shade700
          : balance < 0
          ? Colors.red.shade700
          : Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Cash & Bank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date Picker Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => selectDate(true),
                        child: _dateBox('From', _getDisplayStartDate()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => selectDate(false),
                        child: _dateBox('To', _getDisplayEndDate()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadReceipts,
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
                    label: Text(_isLoading ? 'Loading...' : 'Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header (Type column removed)
                  Row(
                    children: [
                      _buildHeaderCell('Account\nName', flex: 3),
                      _buildHeaderCell('Opening', flex: 2),
                      _buildHeaderCell('Payments', flex: 2),
                      _buildHeaderCell('Receipts', flex: 2),
                      _buildHeaderCell('Balance', flex: 2),
                      _buildHeaderCell('Action', flex: 2),
                    ],
                  ),

                  // Body
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.teal,
                              ),
                            )
                            : accountBalances.isEmpty
                            ? const Center(
                              child: Text(
                                'No cash/bank accounts found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : FadeTransition(
                              opacity: _fadeAnimation,
                              child: ListView.builder(
                                itemCount: accountBalances.length,
                                itemBuilder: (context, i) {
                                  var acc = accountBalances[i];
                                  return Container(
                                    color:
                                        i.isEven
                                            ? Colors.grey.shade50
                                            : Colors.white,
                                    child: Row(
                                      children: [
                                        _buildDataCell(
                                          acc['accountName'],
                                          flex: 3,
                                        ),
                                        _buildDataCell(
                                          '₹${acc['openingBalance'].toStringAsFixed(2)}',
                                          flex: 2,
                                          textColor: _getBalanceColor(
                                            acc['openingBalance'],
                                          ),
                                        ),
                                        _buildDataCell(
                                          '₹${acc['totalPayments'].toStringAsFixed(2)}',
                                          flex: 2,
                                          textColor: Colors.red.shade700,
                                        ),
                                        _buildDataCell(
                                          '₹${acc['totalReceipts'].toStringAsFixed(2)}',
                                          flex: 2,
                                          textColor: Colors.blue.shade700,
                                        ),
                                        _buildDataCell(
                                          '₹${acc['balance'].toStringAsFixed(2)}',
                                          flex: 2,
                                          textColor: _getBalanceColor(
                                            acc['balance'],
                                          ),
                                        ),
                                        _actionButton(
                                          accountName: acc['accountName'],
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),

          // Total Footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Total Current Balance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getBalanceColor(total),
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

  Widget _dateBox(String label, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.teal.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.teal.shade700, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.calendar_today, color: Colors.teal.shade700),
        ],
      ),
    );
  }
}
