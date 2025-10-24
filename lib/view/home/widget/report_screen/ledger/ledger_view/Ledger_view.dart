import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../save_DB/Budegt_database_helper/Save_DB.dart';

class Ledgercash extends StatefulWidget {
  final String accountName;

  const Ledgercash({super.key, required this.accountName});

  @override
  State<Ledgercash> createState() => _LedgercashState();
}

class _LedgercashState extends State<Ledgercash> {
  DateTime selected_startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime selected_endDate = DateTime.now();
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  void selectDate(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: isStart ? selected_startDate : selected_endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          if (isStart) {
            selected_startDate = pickedDate;
          } else {
            selected_endDate = pickedDate;
          }
          _loadTransactions();
        });
      }
    });
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
          print('Error parsing date: $dateStr');
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
      return txDate.isAfter(startOfDay.subtract(Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay.add(Duration(seconds: 1)));
    } catch (e) {
      print('Error checking date range: $e');
      return false;
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final db = await DatabaseHelper().database;

      print('\n=== Loading Transactions for ${widget.accountName} ===');
      print(
        'Date Range: ${DateFormat('dd/MM/yyyy').format(selected_startDate)} to ${DateFormat('dd/MM/yyyy').format(selected_endDate)}',
      );

      // Find the account setup ID
      final account = await db.query(
        'TABLE_ACCOUNTSETTINGS',
        where: "data LIKE ?",
        whereArgs: ['%\"Accountname\":\"${widget.accountName}\"%'],
      );

      if (account.isEmpty) {
        throw Exception('Account ${widget.accountName} not found');
      }

      final setupId = account.first['keyid'].toString();
      final data = account.first['data'];

      print('Account Setup ID: $setupId');

      if (data is String) {
        Map<String, dynamic> accountData = jsonDecode(data);
        accountType = accountData['Type'].toString().toLowerCase();
        openingBalance =
            double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0;

        print('Account Type: $accountType');
        print('Opening Balance: $openingBalance');

        // Get ALL transactions for this account (no date filter in SQL)
        final allTransactions = await db.query(
          'TABLE_ACCOUNTS',
          where: "ACCOUNTS_setupid = ?",
          whereArgs: [setupId],
          orderBy: "ACCOUNTS_id ASC",
        );

        print('Total transactions found in DB: ${allTransactions.length}');

        // Filter transactions by date range in Dart
        List<Map<String, dynamic>> transactionsResult = [];
        for (var tx in allTransactions) {
          String txDateStr = tx['ACCOUNTS_date'].toString();
          if (_isDateInRange(txDateStr, selected_startDate, selected_endDate)) {
            transactionsResult.add(tx);
          }
        }

        print(
          'Transactions in selected date range: ${transactionsResult.length}',
        );

        List<Map<String, dynamic>> txList = [];
        double runningBalance = openingBalance;
        double debitsTotal = 0;
        double creditsTotal = 0;
        int drCount = 0;
        int crCount = 0;

        // Get account setup information for contra entries
        List<Map<String, dynamic>> allAccounts = await db.query(
          'TABLE_ACCOUNTSETTINGS',
        );
        Map<String, String> setupIdToAccountName = {};

        for (var acc in allAccounts) {
          try {
            Map<String, dynamic> accData = jsonDecode(acc["data"]);
            String accSetupId = acc['keyid'].toString();
            String accName = accData['Accountname'].toString();
            setupIdToAccountName[accSetupId] = accName;
          } catch (e) {
            print('Error parsing account: $e');
          }
        }

        for (var tx in transactionsResult) {
          double amount = double.parse(tx['ACCOUNTS_amount'].toString());
          bool isDebit =
              tx['ACCOUNTS_type'].toString().toLowerCase() == 'debit';
          int voucherType =
              int.tryParse(tx['ACCOUNTS_VoucherType']?.toString() ?? '0') ?? 0;
          String entryId = tx['ACCOUNTS_entryid']?.toString() ?? '';

          print('\nTransaction ID: ${tx['ACCOUNTS_id']}');
          print('  Date: ${tx['ACCOUNTS_date']}');
          print('  Amount: $amount');
          print('  Type: ${isDebit ? "Debit" : "Credit"}');
          print('  Voucher Type: $voucherType (1=Payment, 2=Receipt)');

          // Count debits and credits - use absolute values
          if (isDebit) {
            debitsTotal += amount.abs();
            drCount++;
          } else {
            creditsTotal += amount.abs();
            crCount++;
          }

          // Find contra entry
          String contraAccount = '';
          String transactionDescription = '';

          try {
            var contraEntry = await db.query(
              'TABLE_ACCOUNTS',
              where:
                  "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_setupid != ?",
              whereArgs: [voucherType, entryId, setupId],
              limit: 1,
            );

            if (contraEntry.isNotEmpty) {
              String contraSetupId =
                  contraEntry.first['ACCOUNTS_setupid'].toString();
              contraAccount =
                  setupIdToAccountName[contraSetupId] ?? 'Unknown Account';
              print('  Contra Account: $contraAccount');
            }
          } catch (e) {
            print('  Error finding contra entry: $e');
          }

          // Determine transaction type
          String txType = '';
          if (voucherType == 1) {
            // Payment voucher
            txType = isDebit ? 'Payment To' : 'Payment From';
          } else if (voucherType == 2) {
            // Receipt voucher
            txType = isDebit ? 'Receipt From' : 'Receipt To';
          } else {
            txType = 'Transaction';
          }

          transactionDescription =
              contraAccount.isNotEmpty
                  ? '$txType $contraAccount'
                  : tx['ACCOUNTS_remarks']?.toString() ?? 'Transaction';

          // Calculate running balance based on account type
          if (accountType == 'debit') {
            // For debit accounts: Debit increases, Credit decreases
            runningBalance =
                isDebit ? runningBalance + amount : runningBalance - amount;
          } else {
            // For credit accounts: Credit increases, Debit decreases
            runningBalance =
                isDebit ? runningBalance - amount : runningBalance + amount;
          }

          print('  Description: $transactionDescription');
          print('  Running Balance: $runningBalance');

          txList.add({
            'date': tx['ACCOUNTS_date'],
            'description': transactionDescription,
            'contraAccount': contraAccount,
            'debitAmount': isDebit ? amount.abs() : 0,
            'creditAmount': isDebit ? 0 : amount.abs(),
            'balance': runningBalance,
            'remarks': tx['ACCOUNTS_remarks'] ?? '',
            'voucherType': voucherType,
            'entryType': isDebit ? 'Dr' : 'Cr',
          });
        }

        print('\n=== Summary ===');
        print('Total Transactions: ${txList.length}');
        print('Debit Count: $drCount');
        print('Credit Count: $crCount');
        print('Total Debits: $debitsTotal');
        print('Total Credits: $creditsTotal');
        print('Closing Balance: $runningBalance');

        setState(() {
          transactions = txList;
          closingBalance = runningBalance;
          totalDebits = debitsTotal;
          totalCredits = creditsTotal;
          totalTransactions = txList.length;
          debitCount = drCount;
          creditCount = crCount;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  String _getDisplayStartDate() {
    return DateFormat('dd/MM/yyyy').format(selected_startDate);
  }

  String _getDisplayEndDate() {
    return DateFormat('dd/MM/yyyy').format(selected_endDate);
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade400)),
          color: Colors.grey.shade200,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, Color? textColor}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: textColor ?? Colors.black,
            fontWeight: textColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0) return Colors.green;
    if (balance < 0) return Colors.red;
    return Colors.black;
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
        title: Text(
          '${widget.accountName} Ledger',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Date selection
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => selectDate(true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayStartDate(),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => selectDate(false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayEndDate(),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transaction Summary Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade50, Colors.teal.shade100],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade300),
            ),
            child: Column(
              children: [
                Text(
                  'Transaction Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Total\nTransactions',
                      totalTransactions.toString(),
                      Colors.blue,
                    ),
                    _buildSummaryItem(
                      'Debit\nEntries',
                      debitCount.toString(),
                      Colors.orange,
                    ),
                    _buildSummaryItem(
                      'Credit\nEntries',
                      creditCount.toString(),
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Balance Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceItem(
                  'Opening',
                  openingBalance,
                  _getBalanceColor(openingBalance),
                ),
                _buildBalanceItem('Total Dr', totalDebits, Colors.orange),
                _buildBalanceItem('Total Cr', totalCredits, Colors.purple),
                _buildBalanceItem(
                  'Closing',
                  closingBalance,
                  _getBalanceColor(closingBalance),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transactions table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black)),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('Date', flex: 2),
                        _buildHeaderCell('Description', flex: 3),
                        _buildHeaderCell('Type', flex: 1),
                        _buildHeaderCell('Debit', flex: 2),
                        _buildHeaderCell('Credit', flex: 2),
                        _buildHeaderCell('Balance', flex: 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        transactions.isEmpty
                            ? const Center(
                              child: Text(
                                'No transactions found for the selected period',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color:
                                        index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey.shade50,
                                    border: const Border(
                                      bottom: BorderSide(color: Colors.black12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(tx['date'], flex: 2),
                                      _buildDataCell(
                                        tx['description'],
                                        flex: 3,
                                      ),
                                      _buildDataCell(
                                        tx['entryType'],
                                        flex: 1,
                                        textColor:
                                            tx['entryType'] == 'Dr'
                                                ? Colors.orange
                                                : Colors.purple,
                                      ),
                                      _buildDataCell(
                                        tx['debitAmount'] > 0
                                            ? tx['debitAmount'].toStringAsFixed(
                                              2,
                                            )
                                            : '-',
                                        flex: 2,
                                        textColor:
                                            tx['debitAmount'] > 0
                                                ? Colors.orange
                                                : Colors.grey,
                                      ),
                                      _buildDataCell(
                                        tx['creditAmount'] > 0
                                            ? tx['creditAmount']
                                                .toStringAsFixed(2)
                                            : '-',
                                        flex: 2,
                                        textColor:
                                            tx['creditAmount'] > 0
                                                ? Colors.purple
                                                : Colors.grey,
                                      ),
                                      _buildDataCell(
                                        tx['balance'].toStringAsFixed(2),
                                        flex: 2,
                                        textColor: _getBalanceColor(
                                          tx['balance'],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value.abs().toStringAsFixed(2),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
