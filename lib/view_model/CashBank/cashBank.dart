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

class _CashbankState extends State<Cashbank> {
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();
  List<Map<String, dynamic>> accountBalances = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReceipts() async {
    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      List<Map<String, dynamic>> balances = [];

      print('=== DEBUG: Cash/Bank Balance Calculation ===');

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // Only process cash and bank accounts
          if (accountType != 'cash' && accountType != 'bank') continue;

          print('\n--- Account: $accountName ---');

          // Get opening balance from account settings
          double openingBalance =
              double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0;
          String accountNature = accountData['Type'].toString().toLowerCase();

          print('Account Type: $accountNature');
          print('Opening Balance: $openingBalance');

          // Get all transactions for this account
          final transactions = await db.query(
            'TABLE_ACCOUNTS',
            where: "ACCOUNTS_setupid = ?",
            whereArgs: [account['keyid'].toString()],
          );

          print('Total transactions: ${transactions.length}');

          double totalPayments = 0; // Money going OUT (reduces balance)
          double totalReceipts = 0; // Money coming IN (increases balance)

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

            // VoucherType: 1 = Payment, 2 = Receipt
            if (voucherType == 1) {
              // Payment Voucher - Money going OUT
              if (transactionType == 'credit') {
                // This is the cash/bank account being credited (money out)
                totalPayments += amount;
                print('  -> Payment OUT: $amount');
              }
            } else if (voucherType == 2) {
              // Receipt Voucher - Money coming IN
              if (transactionType == 'debit') {
                // This is the cash/bank account being debited (money in)
                totalReceipts += amount;
                print('  -> Receipt IN: $amount');
              }
            }
          }

          print('Total Payments (OUT): $totalPayments');
          print('Total Receipts (IN): $totalReceipts');

          // Calculate current balance based on account nature
          double currentBalance;

          if (accountNature == 'debit') {
            // DEBIT ACCOUNT: Opening + Receipts - Payments
            currentBalance = openingBalance + totalReceipts - totalPayments;
            print(
              'DEBIT: $openingBalance + $totalReceipts - $totalPayments = $currentBalance',
            );
          } else {
            // CREDIT ACCOUNT: Opening - Receipts + Payments
            currentBalance = openingBalance - totalReceipts + totalPayments;
            print(
              'CREDIT: $openingBalance - $totalReceipts + $totalPayments = $currentBalance',
            );
          }

          balances.add({
            'accountName': accountName,
            'totalPayments': totalPayments,
            'totalReceipts': totalReceipts,
            'balance': currentBalance,
            'openingBalance': openingBalance,
            'type': accountNature,
            'accountType': accountType,
          });
        }
      }

      setState(() {
        accountBalances = balances;
        total = balances.fold(0.0, (sum, acc) => sum + acc['balance']);
      });

      print('\n=== Total Balance: $total ===\n');
    } catch (e) {
      print('Error loading cash/bank data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cash/bank data: $e')),
        );
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
          _loadReceipts();
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
        title: const Text('Cash/Bank', style: TextStyle(color: Colors.white)),
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
            onPressed: _loadReceipts,
            child: const Text("Search"),
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
                              child: Text(
                                'No cash/bank accounts found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                                        account['totalPayments']
                                            .toStringAsFixed(2),
                                        flex: 2,
                                        textColor: Colors.red,
                                      ),
                                      _buildDataCell(
                                        account['totalReceipts']
                                            .toStringAsFixed(2),
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
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Current Balance:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getBalanceColor(total),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
