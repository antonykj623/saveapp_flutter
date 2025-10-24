import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/report_screen/List_of_assets/List_of_assets.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';


class AssetLedgerPage extends StatefulWidget {
  final AssetAccount asset;

  const AssetLedgerPage({super.key, required this.asset});

  @override
  State<AssetLedgerPage> createState() => _AssetLedgerPageState();
}

class _AssetLedgerPageState extends State<AssetLedgerPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get all transactions for the specific asset account
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> accountTransactions = await db.query(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_setupid = ?",
        whereArgs: [widget.asset.setupId],
      );

      // Create a transaction entry for the opening balance
      List<Map<String, dynamic>> allTransactions = [
        if (widget.asset.openingBalance != 0)
          {
            'ACCOUNTS_date': '01/01/2025', // Fixed date for opening balance
            'ACCOUNTS_remarks': 'Initial Balance',
            'ACCOUNTS_type': 'debit', // Opening balance is typically a debit for assets
            'ACCOUNTS_amount': widget.asset.openingBalance.toString(),
            'ACCOUNTS_VoucherType': 0, // 0 for opening balance
          },
        ...accountTransactions,
      ];

      // Sort transactions by date (oldest first)
      allTransactions.sort((a, b) {
        try {
          final dateA = _parseDate(a['ACCOUNTS_date']);
          final dateB = _parseDate(b['ACCOUNTS_date']);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        transactions = allTransactions;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      print('Error parsing date: $dateStr, error: $e');
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate running balance
    double runningBalance = 0;
    List<Map<String, dynamic>> transactionsWithBalance = transactions.map((txn) {
      double amount = double.tryParse(txn['ACCOUNTS_amount'].toString()) ?? 0;
      String type = (txn['ACCOUNTS_type'] ?? '').toString().toLowerCase().trim();

      // For asset accounts: Debit increases balance, Credit decreases balance
      if (type == 'debit' || type == 'dr') {
        runningBalance += amount;
      } else if (type == 'credit' || type == 'cr') {
        runningBalance -= amount;
      }

      return {
        ...txn,
        'running_balance': runningBalance,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.asset.accountName} Ledger',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions found for this account.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Account Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Closing Balance:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹ ${widget.asset.closingBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.asset.closingBalance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Transaction Table
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: const Border(
                                  bottom: BorderSide(color: Colors.black),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildHeaderCell('Date', flex: 2),
                                  _buildHeaderCell('Description', flex: 3),
                                  _buildHeaderCell('Debit', flex: 2),
                                  _buildHeaderCell('Credit', flex: 2),
                                  _buildHeaderCell('Balance', flex: 2),
                                ],
                              ),
                            ),
                            // Table Data
                            Expanded(
                              child: ListView.builder(
                                itemCount: transactionsWithBalance.length,
                                itemBuilder: (context, index) {
                                  final txn = transactionsWithBalance[index];
                                  String date = txn['ACCOUNTS_date'];
                                  String remarks =
                                      txn['ACCOUNTS_remarks'] ?? '-';
                                  String type = (txn['ACCOUNTS_type'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .trim();
                                  double amount =
                                      double.tryParse(txn['ACCOUNTS_amount'].toString()) ??
                                          0;
                                  double balance = txn['running_balance'];

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildDataCell(date, flex: 2),
                                        _buildDataCell(remarks, flex: 3),
                                        _buildDataCell(
                                          type == 'debit' || type == 'dr'
                                              ? amount.toStringAsFixed(2)
                                              : '-',
                                          flex: 2,
                                          color: Colors.green,
                                        ),
                                        _buildDataCell(
                                          type == 'credit' || type == 'cr'
                                              ? amount.toStringAsFixed(2)
                                              : '-',
                                          flex: 2,
                                          color: Colors.red,
                                        ),
                                        _buildDataCell(
                                          balance.toStringAsFixed(2),
                                          flex: 2,
                                          color: balance >= 0
                                              ? Colors.green
                                              : Colors.red,
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

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade400)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, Color? color}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}