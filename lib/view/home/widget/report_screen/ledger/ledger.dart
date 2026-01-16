import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/report_screen/ledger/ledger_view/Ledger_view.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/CashBank/ledgerCashtable.dart';

class PaymentReceiptLedger extends StatefulWidget {
  const PaymentReceiptLedger({super.key});

  @override
     
  State<PaymentReceiptLedger> createState() => _PaymentReceiptLedgerState();
}

class _PaymentReceiptLedgerState extends State<PaymentReceiptLedger> {
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();
  List<Map<String, dynamic>> accountBalances = [];
  double totalPayments = 0;
  double totalReceipts = 0;
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

  // Helper method to parse date from string (handles multiple formats)
  DateTime? _parseDate(String dateStr) {
    try {
      // Try common date formats
      final formats = [
        'yyyy-MM-dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'dd-MM-yyyy',
        'yyyy/MM/dd',
      ];

      for (var format in formats) {
        try {
          return DateFormat(format).parse(dateStr);
        } catch (e) {
          continue;
        }
      }

      // If none of the formats work, try DateTime.parse
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $dateStr - $e');
      return null;
    }
  }

  // Check if transaction date is within selected range
  bool _isDateInRange(String dateStr) {
    final txDate = _parseDate(dateStr);
    if (txDate == null) return false;

    // Normalize dates to compare only date parts (ignore time)
    final startDate = DateTime(
      selected_startDate.year,
      selected_startDate.month,
      selected_startDate.day,
    );
    final endDate = DateTime(
      selected_endDate.year,
      selected_endDate.month,
      selected_endDate.day,
      23,
      59,
      59,
    );
    final transactionDate = DateTime(txDate.year, txDate.month, txDate.day);

    return transactionDate.isAfter(startDate.subtract(Duration(days: 1))) &&
        transactionDate.isBefore(endDate.add(Duration(days: 1)));
  }

  // Check if date is before a given date
  bool _isDateBefore(String dateStr, DateTime compareDate) {
    final txDate = _parseDate(dateStr);
    if (txDate == null) return false;

    final startOfDay = DateTime(
      compareDate.year,
      compareDate.month,
      compareDate.day,
    );
    final transactionDate = DateTime(txDate.year, txDate.month, txDate.day);

    return transactionDate.isBefore(startOfDay);
  }

  Future<void> _loadTransactions() async {
    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      List<Map<String, dynamic>> balances = [];

      print(
        '=== DEBUG: Payment/Receipt Calculation (Date Range: ${_getDisplayStartDate()} to ${_getDisplayEndDate()}) ===',
      );

      double grandTotalPayments = 0;
      double grandTotalReceipts = 0;

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // EXCLUDE cash and bank accounts - only show other accounts
          if (accountType == 'cash' || accountType == 'bank') {
            print('Skipping Cash/Bank account: $accountName');
            continue;
          }
    
          print('\n--- Checking Account: $accountName ---');

          // Get all transactions for this account
          final transactions = await db.query(
            'TABLE_ACCOUNTS',
            where: "ACCOUNTS_setupid = ?",
            whereArgs: [account['keyid'].toString()],
            orderBy: "ACCOUNTS_date ASC, ACCOUNTS_id ASC",
          );

          print('Total transactions in DB: ${transactions.length}');

          // Get opening balance from account settings
          double initialOpeningBalance =
              double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0;
          String accountNature = accountData['Type'].toString().toLowerCase();

          print('Account Type: $accountNature');
          print('Account Category: $accountType');
          print('Initial Opening Balance: $initialOpeningBalance');

          // Calculate opening balance by processing transactions BEFORE start date
          double calculatedOpeningBalance = initialOpeningBalance;
          int beforeCount = 0;

          for (var tx in transactions) {
            if (_isDateBefore(
              tx['ACCOUNTS_date'].toString(),
              selected_startDate,
            )) {
              double amount = double.parse(tx['ACCOUNTS_amount'].toString());
              bool isDebit =
                  tx['ACCOUNTS_type'].toString().toLowerCase() == 'debit';

              if (accountNature == 'debit') {
                calculatedOpeningBalance =
                    isDebit
                        ? calculatedOpeningBalance + amount
                        : calculatedOpeningBalance - amount;
              } else {
                calculatedOpeningBalance =
                    isDebit
                        ? calculatedOpeningBalance - amount
                        : calculatedOpeningBalance + amount;
              }
              beforeCount++;
            }
          }

          print('Transactions before start date: $beforeCount');
          print('Calculated Opening Balance: $calculatedOpeningBalance');

          // Filter transactions by date range
          final filteredTransactions =
              transactions.where((tx) {
                String dateStr = tx['ACCOUNTS_date']?.toString() ?? '';
                return _isDateInRange(dateStr);
              }).toList();

          print('Transactions in date range: ${filteredTransactions.length}');

          // SKIP accounts with no transactions in date range
          if (filteredTransactions.isEmpty) {
            print('No transactions in date range - SKIPPING this account');
            continue;
          }

          double accountPayments = 0; // VoucherType = 1
          double accountReceipts = 0; // VoucherType = 2

          // Process each filtered transaction
          for (var tx in filteredTransactions) {
            double amount = double.parse(tx['ACCOUNTS_amount'].toString());
            String transactionType =
                tx['ACCOUNTS_type'].toString().toLowerCase();
            int voucherType =
                int.tryParse(tx['ACCOUNTS_VoucherType']?.toString() ?? '0') ??
                0;

            print(
              'Transaction: ${tx['ACCOUNTS_date']} - Amount: $amount - Entry: $transactionType - Voucher: $voucherType',
            );

            // VoucherType: 1 = Payment Voucher, 2 = Receipt Voucher
            if (voucherType == 1) {
              // Payment Voucher - this account is involved in payment
              accountPayments += amount;
              print('  -> Payment transaction: $amount');
            } else if (voucherType == 2) {
              // Receipt Voucher - this account is involved in receipt
              accountReceipts += amount;
              print('  -> Receipt transaction: $amount');
            }
          }

          // SKIP accounts that have no payment or receipt vouchers in date range
          if (accountPayments == 0 && accountReceipts == 0) {
            print(
              'No Payment/Receipt vouchers in date range - SKIPPING this account',
            );
            continue;
          }

          print('Account Payments (Voucher Type 1): $accountPayments');
          print('Account Receipts (Voucher Type 2): $accountReceipts');

          // Calculate current balance based on account nature
          double currentBalance;

          if (accountNature == 'debit') {
            // DEBIT ACCOUNT: Opening + Receipts - Payments
            currentBalance =
                calculatedOpeningBalance + accountReceipts - accountPayments;

            print(
              'DEBIT: $calculatedOpeningBalance + $accountReceipts - $accountPayments = $currentBalance',
            );
          } else {
            // CREDIT ACCOUNT: Opening - Receipts + Payments
            currentBalance =
                calculatedOpeningBalance - accountReceipts + accountPayments;
            print(
              'CREDIT: $calculatedOpeningBalance - $accountReceipts + $accountPayments = $currentBalance',
            );
          }

          grandTotalPayments += accountPayments;
          grandTotalReceipts += accountReceipts;

          balances.add({
            'accountName': accountName,
            'payments': accountPayments,
            'receipts': accountReceipts,
            'balance': currentBalance,
            'openingBalance': calculatedOpeningBalance,
            'type': accountNature,
            'accountType': accountType,
          });

          print('✓ Account ADDED to list');
        }
      }

      setState(() {
        accountBalances = balances;
        totalPayments = grandTotalPayments;
        totalReceipts = grandTotalReceipts;
      });

      print(
        '\n=== Accounts with transactions in date range: ${balances.length} ===',
      );
      print('=== Grand Total Payments: $grandTotalPayments ===');
      print('=== Grand Total Receipts: $grandTotalReceipts ===\n');
    } catch (e) {
      print('Error loading payment/receipt data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
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
            // If start date is after end date, adjust end date
            if (selected_startDate.isAfter(selected_endDate)) {
              selected_endDate = selected_startDate;
            }
          } else {
            selected_endDate = pickedDate;
            // If end date is before start date, adjust start date
            if (selected_endDate.isBefore(selected_startDate)) {
              selected_startDate = selected_endDate;
            }
          }
        });
        // Auto-search after date selection
        _loadTransactions();
      }
    });
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
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
          border: Border(right: BorderSide(color: Colors.grey.shade400)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: textColor ?? Colors.black,
            fontWeight: textColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String text, {
    required int flex,
    required String accountName,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade400)),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Ledgercash(accountName: accountName),
              ),
            );
          },
          child: const Text(
            "View",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 11,
            ),
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
        title: const Text('Ledger', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () => selectDate(true),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.teal.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getDisplayStartDate(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.teal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () => selectDate(false),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.teal.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'To Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getDisplayEndDate(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.teal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _loadTransactions,
                  icon: Icon(Icons.search),
                  label: const Text(
                    "Search Transactions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Summary Cards - Only show if there are accounts
          if (accountBalances.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Payments',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹${totalPayments.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 3,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Receipts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹${totalReceipts.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('Account\nName', flex: 3),
                        _buildHeaderCell('Type', flex: 2),
                        _buildHeaderCell('Opening', flex: 2),
                        _buildHeaderCell('Payments', flex: 2),
                        _buildHeaderCell('Receipts', flex: 2),
                        _buildHeaderCell('Balance', flex: 2),
                        _buildHeaderCell('Action', flex: 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        accountBalances.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No Transactions Found',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No payment or receipt transactions in selected date range.\nTry selecting a different date range.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: accountBalances.length,
                              itemBuilder: (context, index) {
                                final account = accountBalances[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: const Border(
                                      bottom: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(
                                        account['accountName'],
                                        flex: 3,
                                      ),
                                      _buildDataCell(
                                        account['type']
                                            .toString()
                                            .toUpperCase(),
                                        flex: 2,
                                        textColor:
                                            account['type'] == 'debit'
                                                ? Colors.orange
                                                : Colors.purple,
                                      ),
                                      _buildDataCell(
                                        account['openingBalance']
                                            .toStringAsFixed(2),
                                        flex: 2,
                                        textColor: _getBalanceColor(
                                          account['openingBalance'],
                                        ),
                                      ),
                                      _buildDataCell(
                                        account['payments'].toStringAsFixed(2),
                                        flex: 2,
                                        textColor: Colors.red,
                                      ),
                                      _buildDataCell(
                                        account['receipts'].toStringAsFixed(2),
                                        flex: 2,
                                        textColor: Colors.blue,
                                      ),
                                      _buildDataCell(
                                        account['balance'].toStringAsFixed(2),
                                        flex: 2,
                                        textColor: _getBalanceColor(
                                          account['balance'],
                                        ),
                                      ),
                                      _actionButton(
                                        'View',
                                        flex: 2,
                                        accountName: account['accountName'],
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
        ],
      ),
    );
  }
}
