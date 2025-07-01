import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/CashBank/Receipt_class/monthYearPicker.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/wallet_page/wallet_transation_class/wallet_transtion_class.dart';
import 'package:new_project_2025/view/home/widget/wallet_page/addmoney_wallet/add_money_wallet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<WalletTransaction> transactions = [];
  double openingBalance = 0.0; // Will be set from the first transaction
  double closingBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      var walletData = await DatabaseHelper().getWalletData();
      List<WalletTransaction> tempTransactions = [];
      double totalAmount = 0.0;

      var sortedData = walletData.toList();
      sortedData.sort((a, b) {
        Map<String, dynamic> dataA = jsonDecode(a['data']);
        Map<String, dynamic> dataB = jsonDecode(b['data']);
        return DateTime.parse(
          dataA['date'] ?? '1970-01-01',
        ).compareTo(DateTime.parse(dataB['date'] ?? '1970-01-01'));
      });

      double firstCreditAmount = 0.0;
      for (var row in sortedData) {
        Map<String, dynamic> data = jsonDecode(row['data']);
        double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
        if (amount > 0) {
          firstCreditAmount = amount;
          break; 
        }
      }

      var selectedMonthData =
          sortedData.where((row) {
            Map<String, dynamic> data = jsonDecode(row['data']);
            return data['date']?.startsWith(selectedYearMonth) ?? false;
          }).toList();

      for (var row in selectedMonthData) {
        Map<String, dynamic> data = jsonDecode(row['data']);
        String date = data['date'] ?? '';
        double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
        String description =
            data.containsKey('description')
                ? data['description']
                : 'Money Added To Wallet';
        String type = amount >= 0 ? 'credit' : 'debit';

        tempTransactions.add(
          WalletTransaction(
            id: row['keyid'],
            date: date,
            amount: amount,
            description: description,
            type: type,
          ),
        );
        totalAmount += amount;
      }

      setState(() {
        transactions = tempTransactions;
        openingBalance =
            firstCreditAmount; // Set to the first positive transaction's amount
        closingBalance = openingBalance + totalAmount;
      });
    } catch (e) {
      print('Error loading wallet data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wallet data: $e')),
        );
      }
    }
  }

  // Future<void> _loadWalletData() async {
  //   try {
  //     var walletData = await DatabaseHelper().getWalletData();
  //     List<WalletTransaction> tempTransactions = [];
  //     double totalAmount = 0.0;
  //     double priorBalance = 0.0;

  //     // Parse selected year and month
  //     final yearMonthParts = selectedYearMonth.split('-');
  //     final selectedYear = int.parse(yearMonthParts[0]);
  //     final selectedMonth = int.parse(yearMonthParts[1]);
  //     final startOfMonth = DateTime(selectedYear, selectedMonth, 1);

  //     // Sort all data by date
  //     var sortedData = walletData.toList();
  //     sortedData.sort((a, b) {
  //       Map<String, dynamic> dataA = jsonDecode(a['data']);
  //       Map<String, dynamic> dataB = jsonDecode(b['data']);
  //       return DateTime.parse(
  //         dataA['date'] ?? '1970-01-01',
  //       ).compareTo(DateTime.parse(dataB['data'] ?? '1970-01-01'));
  //     });

  //     for (var row in sortedData) {
  //       Map<String, dynamic> data = jsonDecode(row['data']);
  //       String date = data['date'] ?? '';
  //       DateTime transactionDate = DateTime.parse(date);
  //       double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
  //       String description =
  //           data.containsKey('description')
  //               ? data['description']
  //               : 'Money Added To Wallet';
  //       String type = amount >= 0 ? 'credit' : 'debit';

  //       // Calculate opening balance from transactions before the selected month
  //       if (transactionDate.isBefore(startOfMonth)) {
  //         priorBalance += amount;
  //       }

  //       // Include transactions for the selected month
  //       if (data['date']?.startsWith(selectedYearMonth) ?? false) {
  //         tempTransactions.add(
  //           WalletTransaction(
  //             id: row['keyid'],
  //             date: date,
  //             amount: amount,
  //             description: description,
  //             type: type,
  //           ),
  //         );
  //         totalAmount += amount;
  //       }
  //     }

  //     setState(() {
  //       transactions = tempTransactions;
  //       openingBalance =
  //           priorBalance; // Set opening balance as sum of prior transactions
  //       closingBalance = openingBalance + totalAmount;
  //     });
  //   } catch (e) {
  //     print('Error loading wallet data: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error loading wallet data: $e')),
  //       );
  //     }
  //   }
  // }

  void _showMonthYearPicker() {
    final yearMonthParts = selectedYearMonth.split('-');
    final initialYear = int.parse(yearMonthParts[0]);
    final initialMonth = int.parse(yearMonthParts[1]);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: MonthYearPicker(
              initialMonth: initialMonth,
              initialYear: initialYear,
              onDateSelected: (int month, int year) {
                setState(() {
                  selectedYearMonth =
                      '$year-${month.toString().padLeft(2, '0')}';
                  _loadWalletData();
                });
                Navigator.pop(context);
              },
            ),
          ),
    );
  }

  String _getDisplayMonth() {
    final parts = selectedYearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat('MMMM').format(DateTime(2022, month));
    return '$monthName/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: _showMonthYearPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDisplayMonth(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Opening Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  ': ${openingBalance.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black!),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border(bottom: BorderSide(color: Colors.black!)),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('Date', flex: 2),
                        _buildHeaderCell('Account\nName', flex: 3),
                        _buildHeaderCell('Amount', flex: 2),
                        _buildHeaderCell('Action', flex: 2),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        transactions.isEmpty
                            ? const Center(
                              child: Text(
                                'No transactions for this month',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(
                                        DateFormat('dd/M/yyyy').format(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).parse(transaction.date),
                                        ),
                                        flex: 2,
                                      ),
                                      _buildDataCell(
                                        transaction.description,
                                        flex: 3,
                                      ),
                                      _buildDataCell(
                                        transaction.amount >= 0
                                            ? '+ ${transaction.amount.toStringAsFixed(0)}'
                                            : '- ${(-transaction.amount).toStringAsFixed(0)}',
                                        flex: 2,
                                        textColor:
                                            transaction.amount >= 0
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              _showEditDeleteDialog(
                                                transaction,
                                              );
                                            },
                                            child: const Text(
                                              'Edit/\nDelete',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
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
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Closing balance : ${closingBalance.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMoneyToWalletPage(),
            ),
          ).then((_) => _loadWalletData());
        },
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
          border: Border(right: BorderSide(color: Colors.grey[300]!)),
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
        height: 70,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textColor ?? Colors.black, fontSize: 12),
        ),
      ),
    );
  }

  void _showEditDeleteDialog(WalletTransaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AddMoneyToWalletPage(transaction: transaction),
                      ),
                    ).then((_) => _loadWalletData());
                  },
                ),
                ListTile(
                  title: const Text('Delete'),
                  onTap: () async {
                    await DatabaseHelper().deleteData(
                      'TABLE_WALLET',
                      transaction.id!,
                    );
                    _loadWalletData();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
