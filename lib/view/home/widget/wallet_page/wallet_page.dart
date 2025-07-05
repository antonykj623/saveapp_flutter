import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/CashBank/Receipt_class/monthYearPicker.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/wallet_page/wallet_transation_class/wallet_transtion_class.dart';
import 'package:new_project_2025/view/home/widget/wallet_page/addmoney_wallet/add_money_wallet.dart';
import 'package:new_project_2025/view/home/widget/payment_page/add_payment/add_paymet.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<WalletTransaction> transactions = [];
  double openingBalance = 0.0;
  double closingBalance = 0.0;
  double total = 0;
  List<Payment> payments = [];
  bool hasWalletMoney = false;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      // Check if there's money in wallet first
      if (!hasWalletMoney) {
        setState(() {
          payments = [];
          total = 0;
        });
        return;
      }

      List<Map<String, dynamic>> paymentsList = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTSETTINGS");

      Map<String, String> setupIdToAccountName = {};
      for (var account in accountSettings) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String setupId = account['keyid'].toString();
          String accountName = accountData['Accountname'].toString();
          setupIdToAccountName[setupId] = accountName;
        } catch (e) {
          print('Error parsing account settings: $e');
        }
      }

      final uniqueDebitEntries = <String, Map<String, dynamic>>{};
      for (var mp in paymentsList) {
        if (mp['ACCOUNTS_VoucherType'] == 1 &&
            mp['ACCOUNTS_type'] == 'debit' &&
            DateFormat(
                  'yyyy-MM',
                ).format(DateFormat('dd/MM/yyyy').parse(mp['ACCOUNTS_date'])) ==
                selectedYearMonth) {
          uniqueDebitEntries[mp['ACCOUNTS_entryid'].toString()] = mp;
        }
      }

      setState(() {
        payments =
            uniqueDebitEntries.values.map((mp) {
              String debitSetupId = mp['ACCOUNTS_setupid'].toString();
              String accountName =
                  setupIdToAccountName[debitSetupId] ??
                  'Unknown Account (ID: $debitSetupId)';

              String paymentMode = 'Cash';
              try {
                var creditEntry = paymentsList.firstWhere(
                  (entry) =>
                      entry['ACCOUNTS_VoucherType'] == 1 &&
                      entry['ACCOUNTS_type'] == 'credit' &&
                      entry['ACCOUNTS_entryid'].toString() ==
                          mp['ACCOUNTS_entryid'].toString(),
                );
                String creditSetupId =
                    creditEntry['ACCOUNTS_setupid'].toString();
                paymentMode = setupIdToAccountName[creditSetupId] ?? 'Cash';
              } catch (e) {
                print(
                  'Could not find credit entry for payment ID ${mp['ACCOUNTS_entryid']}: $e',
                );
              }

              return Payment(
                id: int.parse(mp['ACCOUNTS_entryid']),
                date: mp['ACCOUNTS_date'],
                accountName: accountName,
                amount: double.parse(mp['ACCOUNTS_amount'].toString()),
                paymentMode: paymentMode,
                remarks: mp['ACCOUNTS_remarks'] ?? '',
              );
            }).toList();

        total = payments.fold(0, (sum, payment) => sum + payment.amount);
      });
    } catch (e) {
      print('Error loading payments: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading payments: $e')));
      }
      setState(() {
        payments = [];
        total = 0;
      });
    }
  }

  Future<void> _loadWalletData() async {
    try {
      var walletData = await DatabaseHelper().getWalletData();
      List<WalletTransaction> tempTransactions = [];

      final yearMonthParts = selectedYearMonth.split('-');
      final selectedYear = int.parse(yearMonthParts[0]);
      final selectedMonth = int.parse(yearMonthParts[1]);
      final startOfMonth = DateTime(selectedYear, selectedMonth, 1);
      final endOfMonth = DateTime(
        selectedYear,
        selectedMonth + 1,
        1,
      ).subtract(Duration(days: 1));

      var sortedData = walletData.toList();
      sortedData.sort((a, b) {
        Map<String, dynamic> dataA = jsonDecode(a['data']);
        Map<String, dynamic> dataB = jsonDecode(b['data']);
        return DateTime.parse(
          dataA['date'] ?? '1970-01-01',
        ).compareTo(DateTime.parse(dataB['date'] ?? '1970-01-01'));
      });

      // Check if there are any "Money Added To Wallet" transactions
      bool hasMoneyAddedTransactions = false;
      DateTime? firstWalletTransactionDate;

      for (var row in sortedData) {
        Map<String, dynamic> data = jsonDecode(row['data']);
        String description = data['description'] ?? '';
        double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;

        if (description == 'Money Added To Wallet' && amount > 0) {
          hasMoneyAddedTransactions = true;
          DateTime transactionDate = DateTime.parse(
            data['date'] ?? '1970-01-01',
          );
          if (firstWalletTransactionDate == null ||
              transactionDate.isBefore(firstWalletTransactionDate)) {
            firstWalletTransactionDate = transactionDate;
          }
        }
      }

      // Calculate opening balance - includes all transactions up to (and including) the start of selected month
      double calculatedOpeningBalance = 0.0;

      if (hasMoneyAddedTransactions && firstWalletTransactionDate != null) {
        for (var row in sortedData) {
          Map<String, dynamic> data = jsonDecode(row['data']);
          DateTime transactionDate = DateTime.parse(
            data['date'] ?? '1970-01-01',
          );
          double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
          String description = data['description'] ?? '';

          // Include all transactions before the selected month (including the first wallet transaction)
          if (transactionDate.isBefore(startOfMonth)) {
            if (description == 'Money Added To Wallet') {
              calculatedOpeningBalance += amount;
            } else if (amount < 0) {
              // Include payment deductions that happened before selected month
              calculatedOpeningBalance += amount;
            }
          }
        }

        // Special case: If the selected month contains the first wallet transaction,
        // the opening balance should include that first transaction
        if (firstWalletTransactionDate.isAfter(
              startOfMonth.subtract(Duration(days: 1)),
            ) &&
            firstWalletTransactionDate.isBefore(
              endOfMonth.add(Duration(days: 1)),
            )) {
          // Find the first wallet transaction amount
          for (var row in sortedData) {
            Map<String, dynamic> data = jsonDecode(row['data']);
            DateTime transactionDate = DateTime.parse(
              data['date'] ?? '1970-01-01',
            );
            double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
            String description = data['description'] ?? '';

            if (transactionDate.isAtSameMomentAs(firstWalletTransactionDate) &&
                description == 'Money Added To Wallet') {
              calculatedOpeningBalance =
                  amount; // Set opening balance to first wallet amount
              break;
            }
          }
        }
      }

      setState(() {
        hasWalletMoney = hasMoneyAddedTransactions;
        openingBalance = calculatedOpeningBalance;
      });

      // Filter transactions for selected month
      var selectedMonthData =
          sortedData.where((row) {
            Map<String, dynamic> data = jsonDecode(row['data']);
            return data['date']?.startsWith(selectedYearMonth) ?? false;
          }).toList();

      // Add transactions to display
      for (var row in selectedMonthData) {
        Map<String, dynamic> data = jsonDecode(row['data']);
        String date = data['date'] ?? '';
        double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
        String description = data['description'] ?? 'Money Added To Wallet';
        String type = amount >= 0 ? 'credit' : 'debit';
        String? paymentMethod = data['paymentMethod'];
        String? paymentEntryId = data['paymentEntryId'];

        if (description != 'Money Added To Wallet' && !hasWalletMoney) {
          continue;
        }

        tempTransactions.add(
          WalletTransaction(
            id: row['keyid'],
            date: date,
            amount: amount,
            description: description,
            type: type,
            paymentMethod: paymentMethod,
            paymentEntryId: paymentEntryId,
          ),
        );
      }

      // Calculate closing balance - all transactions from first wallet transaction to end of selected month
      double calculatedClosingBalance = 0.0;

      if (hasMoneyAddedTransactions && firstWalletTransactionDate != null) {
        for (var row in sortedData) {
          Map<String, dynamic> data = jsonDecode(row['data']);
          DateTime transactionDate = DateTime.parse(
            data['date'] ?? '1970-01-01',
          );
          double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
          String description = data['description'] ?? '';

          // Include all transactions from first wallet transaction to end of selected month
          if (!transactionDate.isAfter(endOfMonth) &&
              !transactionDate.isBefore(firstWalletTransactionDate)) {
            if (description == 'Money Added To Wallet') {
              calculatedClosingBalance += amount;
            } else if (amount < 0) {
              calculatedClosingBalance += amount;
            }
          }
        }
      }

      setState(() {
        transactions = tempTransactions;
        closingBalance = calculatedClosingBalance;
      });

      await _loadPayments();
    } catch (e) {
      print('Error loading wallet data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wallet data: $e')),
        );
      }
    }
  }

  Future<bool> _isPaymentTransaction(WalletTransaction transaction) async {
    try {
      if (transaction.description == 'Money Added To Wallet' ||
          transaction.paymentEntryId == null ||
          transaction.paymentEntryId!.isEmpty) {
        return false;
      }

      List<Map<String, dynamic>> paymentsList = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");

      for (var payment in paymentsList) {
        if (payment['ACCOUNTS_VoucherType'] == 1 &&
            payment['ACCOUNTS_entryid'].toString() ==
                transaction.paymentEntryId &&
            payment['ACCOUNTS_type'] == 'debit') {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking payment transaction: $e');
      return false;
    }
  }

  Future<Payment?> _getPaymentData(WalletTransaction transaction) async {
    try {
      if (transaction.paymentEntryId == null ||
          transaction.paymentEntryId!.isEmpty) {
        return null;
      }

      List<Map<String, dynamic>> paymentsList = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTSETTINGS");

      Map<String, String> setupIdToAccountName = {};
      for (var account in accountSettings) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String setupId = account['keyid'].toString();
          String accountName = accountData['Accountname'].toString();
          setupIdToAccountName[setupId] = accountName;
        } catch (e) {
          print('Error parsing account settings: $e');
        }
      }

      Map<String, dynamic>? debitEntry = paymentsList.firstWhere(
        (payment) =>
            payment['ACCOUNTS_VoucherType'] == 1 &&
            payment['ACCOUNTS_entryid'].toString() ==
                transaction.paymentEntryId &&
            payment['ACCOUNTS_type'] == 'debit',
        orElse: () => {},
      );

      if (debitEntry.isNotEmpty) {
        String debitSetupId = debitEntry['ACCOUNTS_setupid'].toString();
        String accountName =
            setupIdToAccountName[debitSetupId] ?? 'Unknown Account';

        String paymentMode = transaction.paymentMethod ?? 'Wallet';
        try {
          var creditEntry = paymentsList.firstWhere(
            (entry) =>
                entry['ACCOUNTS_VoucherType'] == 1 &&
                entry['ACCOUNTS_type'] == 'credit' &&
                entry['ACCOUNTS_entryid'].toString() ==
                    transaction.paymentEntryId,
            orElse: () => {},
          );
          if (creditEntry.isNotEmpty) {
            String creditSetupId = creditEntry['ACCOUNTS_setupid'].toString();
            paymentMode =
                setupIdToAccountName[creditSetupId] ??
                transaction.paymentMethod ??
                'Wallet';
          }
        } catch (e) {
          print('Error finding credit entry: $e');
        }

        return Payment(
          id: int.parse(debitEntry['ACCOUNTS_entryid']),
          date: debitEntry['ACCOUNTS_date'],
          accountName: accountName,
          amount: double.parse(debitEntry['ACCOUNTS_amount'].toString()),
          paymentMode: paymentMode,
          remarks: debitEntry['ACCOUNTS_remarks'] ?? '',
        );
      }

      return null;
    } catch (e) {
      print('Error getting payment data: $e');
      return null;
    }
  }

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

  void _deletePayment(int id) async {
    try {
      final db = await DatabaseHelper().database;

      await db.delete(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
        whereArgs: [1, id.toString()],
      );

      await db.delete(
        "TABLE_WALLET",
        where: "data LIKE ?",
        whereArgs: ['%\"paymentEntryId\":\"$id\"%'],
      );

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) {
        throw Exception('Double-entry accounting is unbalanced after deletion');
      }

      _loadWalletData();
      _loadPayments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting payment: $e')));
      }
    }
  }

  void _showEditDeleteDialog(WalletTransaction transaction) async {
    bool isPayment = await _isPaymentTransaction(transaction);

    if (isPayment) {
      Payment? paymentData = await _getPaymentData(transaction);
      if (paymentData != null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Choose Action'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit'),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToEditPayment(paymentData);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDeletePayment(paymentData.id!);
                      },
                    ),
                  ],
                ),
              ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading payment data')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Choose Action'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddMoneyToWalletPage(
                                transaction: transaction,
                              ),
                        ),
                      );
                      if (result == true) {
                        _loadWalletData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction updated successfully'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteWalletTransaction(transaction.id!);
                    },
                  ),
                ],
              ),
            ),
      );
    }
  }

  void _navigateToEditPayment(Payment payment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentVoucherPage(payment: payment),
      ),
    );

    if (result == true) {
      _loadPayments();
      _loadWalletData();
    }
  }

  void _confirmDeletePayment(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this payment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePayment(id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteWalletTransaction(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await DatabaseHelper().deleteData('TABLE_WALLET', id);
                    _loadWalletData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting transaction: $e'),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
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
          // Show wallet status message
          if (!hasWalletMoney)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),

              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No wallet money found. Add money to wallet to see payment transactions.',
                      style: TextStyle(color: Colors.black87),
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
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    hasWalletMoney
                                        ? 'No transactions for this month'
                                        : 'Add money to wallet first to see transactions',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
}
