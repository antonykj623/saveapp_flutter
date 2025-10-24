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

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // Only process income and expense accounts
          if (accountType != 'income account' &&
              accountType != 'expense account')
            continue;

          print('\n--- Account: $accountName ---');

          // Get opening balance from account settings
          double openingBalance =
              double.tryParse(accountData['balance']?.toString() ?? '0') ?? 0;
          String accountNature = accountData['Type'].toString().toLowerCase();

          print('Account Type: $accountType');
          print('Account Nature: $accountNature');
          print('Opening Balance: $openingBalance');

          // Get all transactions for this account
          final transactions = await db.query(
            'TABLE_ACCOUNTS',
            where: "ACCOUNTS_setupid = ?",
            whereArgs: [account['keyid'].toString()],
          );

          print('Total transactions: ${transactions.length}');

          double totalDebits = 0;
          double totalCredits = 0;

          // Process each transaction
          for (var tx in transactions) {
            double amount = double.parse(tx['ACCOUNTS_amount'].toString());
            String transactionType =
                tx['ACCOUNTS_type'].toString().toLowerCase();

            print(
              'Transaction: ${tx['ACCOUNTS_date']} - Amount: $amount - Entry: $transactionType',
            );

            if (transactionType == 'debit') {
              totalDebits += amount;
              print('  -> Debit: $amount');
            } else if (transactionType == 'credit') {
              totalCredits += amount;
              print('  -> Credit: $amount');
            }
          }

          print('Total Debits: $totalDebits');
          print('Total Credits: $totalCredits');

          // Calculate current balance based on account nature
          double currentBalance;
          String categoryType;

          if (accountType == 'income account') {
            // INCOME ACCOUNT (Credit nature)
            // Balance = Opening + Credits - Debits
            currentBalance = openingBalance + totalCredits - totalDebits;
            categoryType = 'Income';
            print(
              'INCOME: $openingBalance + $totalCredits - $totalDebits = $currentBalance',
            );
          } else {
            // EXPENSE ACCOUNT (Debit nature)
            // Balance = Opening + Debits - Credits
            currentBalance = openingBalance + totalDebits - totalCredits;
            categoryType = 'Expenditure';
            print(
              'EXPENSE: $openingBalance + $totalDebits - $totalCredits = $currentBalance',
            );
          }

          balances.add({
            'accountName': accountName,
            'totalDebits': totalDebits,
            'totalCredits': totalCredits,
            'balance': currentBalance,
            'openingBalance': openingBalance,
            'type': accountNature,
            'accountType': accountType,
            'categoryType': categoryType,
          });
        }
      }

      // Calculate totals based on account balances
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

      print('\n=== Total Income: $totalIncome ===');
      print('=== Total Expenditure: $totalExpenditure ===');
      print('=== Net Profit/Loss: $netProfitLoss ===\n');
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
          _loadIncomeExpenditure();
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
        title: const Text(
          'Income and Expenditure Statement',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
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
          // Income Over Expenses Display
          Text(
            netProfitLoss >= 0
                ? 'Income Over Expenses : ${netProfitLoss.toStringAsFixed(1)}'
                : 'Expenses Over Income : ${netProfitLoss.abs().toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: netProfitLoss >= 0 ? Colors.red : Colors.red,
            ),
          ),
          const SizedBox(height: 15),
          // Expandable Total Income Section
          _buildExpandableSection(
            title: 'Total Income : ${totalIncome.toStringAsFixed(1)}',
            accounts:
                accountBalances
                    .where((acc) => acc['categoryType'] == 'Income')
                    .toList(),
          ),
          const SizedBox(height: 10),
          // Expandable Total Expense Section
          _buildExpandableSection(
            title: 'Total Expense : ${totalExpenditure.toStringAsFixed(1)}',
            accounts:
                accountBalances
                    .where((acc) => acc['categoryType'] == 'Expenditure')
                    .toList(),
          ),
          Spacer(),
        ],
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
                'No accounts found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Container(
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
                    child: Row(
                      children: [
                        _buildHeaderCell('Account\nName', flex: 3),
                        _buildHeaderCell('Debit', flex: 2),
                        _buildHeaderCell('Credit', flex: 2),
                        _buildHeaderCell('Action', flex: 2),
                      ],
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
                      child: Row(
                        children: [
                          _buildDataCell(account['accountName'], flex: 3),
                          _buildDataCell(
                            account['totalDebits'] > 0
                                ? account['totalDebits'].toStringAsFixed(0)
                                : '',
                            flex: 2,
                            textColor:
                                account['totalDebits'] > 0 ? Colors.red : null,
                          ),
                          _buildDataCell(
                            account['totalCredits'] > 0
                                ? account['totalCredits'].toStringAsFixed(0)
                                : '',
                            flex: 2,
                            textColor:
                                account['totalCredits'] > 0
                                    ? Colors.blue
                                    : null,
                          ),
                          _actionButton(
                            'View',
                            flex: 2,
                            accountName: account['accountName'],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
