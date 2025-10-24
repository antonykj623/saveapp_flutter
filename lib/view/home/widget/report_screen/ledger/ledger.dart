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

  Future<void> _loadTransactions() async {
    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      List<Map<String, dynamic>> balances = [];

      print('=== DEBUG: Payment/Receipt Calculation (Excluding Cash/Bank) ===');

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
          );

          print('Total transactions: ${transactions.length}');

          // SKIP accounts with no transactions
          if (transactions.isEmpty) {
            print('No transactions found - SKIPPING this account');
            continue;
          }

          // Get opening balance from account settings
          double openingBalance =
              double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0;
          String accountNature = accountData['Type'].toString().toLowerCase();

          print('Account Type: $accountNature');
          print('Account Category: $accountType');
          print('Opening Balance: $openingBalance');

          double accountPayments = 0; // VoucherType = 1
          double accountReceipts = 0; // VoucherType = 2

          // Process each transaction
          for (var tx in transactions) {
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

          // SKIP accounts that have no payment or receipt vouchers
          if (accountPayments == 0 && accountReceipts == 0) {
            print('No Payment/Receipt vouchers found - SKIPPING this account');
            continue;
          }

          print('Account Payments (Voucher Type 1): $accountPayments');
          print('Account Receipts (Voucher Type 2): $accountReceipts');

          // Calculate current balance based on account nature
          double currentBalance;

          if (accountNature == 'debit') {
            // DEBIT ACCOUNT: Opening + Receipts - Payments
            currentBalance = openingBalance + accountReceipts - accountPayments;

            print(
              'DEBIT: $openingBalance + $accountReceipts - $accountPayments = $currentBalance',
            );
          } else {
            // CREDIT ACCOUNT: Opening - Receipts + Payments
            currentBalance = openingBalance - accountReceipts + accountPayments;
            print(
              'CREDIT: $openingBalance - $accountReceipts + $accountPayments = $currentBalance',
            );
          }

          grandTotalPayments += accountPayments;
          grandTotalReceipts += accountReceipts;

          balances.add({
            'accountName': accountName,
            'payments': accountPayments,
            'receipts': accountReceipts,
            'balance': currentBalance,
            'openingBalance': openingBalance,
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

      print('\n=== Accounts with transactions: ${balances.length} ===');
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
          } else {
            selected_endDate = pickedDate;
          }
          _loadTransactions();
        });
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 60,
                  child: InkWell(
                    onTap: () => selectDate(true),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayStartDate(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 60,
                  child: InkWell(
                    onTap: () => selectDate(false),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayEndDate(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: _loadTransactions,
            child: const Text("Search"),
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
                                      'No Payment/Receipt Transactions Found',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Only accounts with payment or receipt vouchers will appear here.\nCash/Bank accounts are excluded.',
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
