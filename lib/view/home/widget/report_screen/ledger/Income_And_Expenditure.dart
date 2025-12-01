import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/report_screen/ledger/ledger_view/Ledger_view.dart';
import 'package:new_project_2025/view_model/CashBank/ledgerCashtable.dart';
import '../../save_DB/Budegt_database_helper/Save_DB.dart';

class IncomeExpenditure extends StatefulWidget {
  const IncomeExpenditure({super.key});

  @override
  State<IncomeExpenditure> createState() => _IncomeExpenditureState();
}

class _IncomeExpenditureState extends State<IncomeExpenditure> {
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();
  List<Map<String, dynamic>> accountBalances = [];
  double totalIncome = 0;
  double totalExpenditure = 0;
  double netProfitLoss = 0;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadIncomeExpenditure();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIncomeExpenditure() async {
    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      List<Map<String, dynamic>> balances = [];

      print('=== DEBUG: Income & Expenditure Calculation ===');
      print('Date Range: ${_getDisplayStartDate()} to ${_getDisplayEndDate()}');

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // Only process income and expense accounts
          if (accountType != 'income account' &&
              accountType != 'expense account') {
            continue;
          }

          print('\n--- Account: $accountName ---');
          print('Account Type: $accountType');

          // Get transactions within date range from TABLE_ACCOUNTS
          final transactions = await db.rawQuery(
            '''
            SELECT * FROM TABLE_ACCOUNTS 
            WHERE ACCOUNTS_setupid = ? 
            AND ACCOUNTS_VoucherType IN (1, 2)
          ''',
            [account['keyid'].toString()],
          );

          print('Total transactions found: ${transactions.length}');

          double totalDebits = 0;
          double totalCredits = 0;

          // Process each transaction and filter by date range
          for (var tx in transactions) {
            try {
              // Parse the date from TABLE_ACCOUNTS (format: dd/MM/yyyy)
              String dateStr = tx['ACCOUNTS_date'].toString();
              DateTime txDate = DateFormat('dd/MM/yyyy').parse(dateStr);

              // Check if transaction is within date range
              if (txDate.isAfter(selected_endDate) ||
                  txDate.isBefore(
                    selected_startDate.subtract(Duration(days: 1)),
                  )) {
                continue;
              }

              double amount = double.parse(tx['ACCOUNTS_amount'].toString());
              String transactionType =
                  tx['ACCOUNTS_type'].toString().toLowerCase();

              print(
                'Transaction: $dateStr - Amount: $amount - Type: $transactionType - VoucherType: ${tx['ACCOUNTS_VoucherType']}',
              );

              if (transactionType == 'debit') {
                totalDebits += amount;
              } else if (transactionType == 'credit') {
                totalCredits += amount;
              }
            } catch (e) {
              print('Error parsing transaction date: $e');
              continue;
            }
          }

          print('Total Debits in range: $totalDebits');
          print('Total Credits in range: $totalCredits');

          // Calculate balance based on account type
          double balance;
          String categoryType;

          if (accountType == 'income account') {
            // INCOME ACCOUNT (Credit nature)
            // Income = Credits - Debits (in the period)
            balance = totalCredits - totalDebits;
            categoryType = 'Income';
            print('INCOME: $totalCredits - $totalDebits = $balance');
          } else {
            // EXPENSE ACCOUNT (Debit nature)
            // Expense = Debits - Credits (in the period)
            balance = totalDebits - totalCredits;
            categoryType = 'Expenditure';
            print('EXPENSE: $totalDebits - $totalCredits = $balance');
          }

          // Only add accounts with transactions in the period
          if (totalDebits > 0 || totalCredits > 0) {
            balances.add({
              'accountName': accountName,
              'totalDebits': totalDebits,
              'totalCredits': totalCredits,
              'balance': balance,
              'accountType': accountType,
              'categoryType': categoryType,
            });
          }
        }
      }

      // Calculate totals
      double incomeTotal = 0;
      double expenditureTotal = 0;

      for (var account in balances) {
        if (account['categoryType'] == 'Income') {
          incomeTotal += account['balance'];
        } else {
          expenditureTotal += account['balance'];
        }
      }

      setState(() {
        accountBalances = balances;
        totalIncome = incomeTotal;
        totalExpenditure = expenditureTotal;
        netProfitLoss = totalIncome - totalExpenditure;
      });

      print('\n=== SUMMARY ===');
      print('Total Income: $totalIncome');
      print('Total Expenditure: $totalExpenditure');
      print('Net Profit/Loss: $netProfitLoss');
    } catch (e) {
      print('Error loading income/expenditure data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading income/expenditure data: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Income and Expenditure Statement',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        controller: _verticalScrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 180),
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
                              Flexible(
                                child: Text(
                                  _getDisplayStartDate(),
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 180),
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
                              Flexible(
                                child: Text(
                                  _getDisplayEndDate(),
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: _loadIncomeExpenditure,
              child: const Text("Search", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            // Net Profit/Loss Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                netProfitLoss >= 0
                    ? 'Income Over Expenses: ₹${netProfitLoss.toStringAsFixed(2)}'
                    : 'Expenses Over Income: ₹${netProfitLoss.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: netProfitLoss >= 0 ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            // Expandable Total Income Section
            _buildExpandableSection(
              title: 'Total Income: ₹${totalIncome.toStringAsFixed(2)}',
              accounts:
                  accountBalances
                      .where((acc) => acc['categoryType'] == 'Income')
                      .toList(),
            ),
            const SizedBox(height: 10),
            // Expandable Total Expense Section
            _buildExpandableSection(
              title: 'Total Expense: ₹${totalExpenditure.toStringAsFixed(2)}',
              accounts:
                  accountBalances
                      .where((acc) => acc['categoryType'] == 'Expenditure')
                      .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Map<String, dynamic>> accounts,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.keyboard_arrow_down),
        children: [
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No transactions found in the selected period',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                              width: 150,
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Account Name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 100,
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Debit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 100,
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Credit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 100,
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Amount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 80,
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: Text(
                                'Action',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Data rows
                    ...accounts.map((account) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 150,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  account['accountName'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  account['totalDebits'] > 0
                                      ? '₹${account['totalDebits'].toStringAsFixed(2)}'
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        account['totalDebits'] > 0
                                            ? Colors.red
                                            : Colors.black,
                                    fontWeight:
                                        account['totalDebits'] > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  account['totalCredits'] > 0
                                      ? '₹${account['totalCredits'].toStringAsFixed(2)}'
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        account['totalCredits'] > 0
                                            ? Colors.blue
                                            : Colors.black,
                                    fontWeight:
                                        account['totalCredits'] > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '₹${account['balance'].toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        account['balance'] >= 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => Ledgercash(
                                              accountName:
                                                  account['accountName'],
                                            ),
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
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
