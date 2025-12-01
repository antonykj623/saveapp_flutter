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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
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
    }
  }

  Future<void> _loadWalletData() async {
    try {
      setState(() => _isLoading = true);

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

      double calculatedOpeningBalance = 0.0;

      if (hasMoneyAddedTransactions && firstWalletTransactionDate != null) {
        for (var row in sortedData) {
          Map<String, dynamic> data = jsonDecode(row['data']);
          DateTime transactionDate = DateTime.parse(
            data['date'] ?? '1970-01-01',
          );
          double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
          String description = data['description'] ?? '';

          if (transactionDate.isBefore(startOfMonth)) {
            if (description == 'Money Added To Wallet') {
              calculatedOpeningBalance += amount;
            } else if (amount < 0) {
              calculatedOpeningBalance += amount;
            }
          }
        }
        if (firstWalletTransactionDate.isAfter(
              startOfMonth.subtract(Duration(days: 1)),
            ) &&
            firstWalletTransactionDate.isBefore(
              endOfMonth.add(Duration(days: 1)),
            )) {
          for (var row in sortedData) {
            Map<String, dynamic> data = jsonDecode(row['data']);
            DateTime transactionDate = DateTime.parse(
              data['date'] ?? '1970-01-01',
            );
            double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
            String description = data['description'] ?? '';

            if (transactionDate.isAtSameMomentAs(firstWalletTransactionDate) &&
                description == 'Money Added To Wallet') {
              calculatedOpeningBalance = amount;
              break;
            }
          }
        }
      }

      setState(() {
        hasWalletMoney = hasMoneyAddedTransactions;
        openingBalance = calculatedOpeningBalance;
      });

      var selectedMonthData =
          sortedData.where((row) {
            Map<String, dynamic> data = jsonDecode(row['data']);
            return data['date']?.startsWith(selectedYearMonth) ?? false;
          }).toList();

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

      double calculatedClosingBalance = 0.0;

      if (hasMoneyAddedTransactions && firstWalletTransactionDate != null) {
        for (var row in sortedData) {
          Map<String, dynamic> data = jsonDecode(row['data']);
          DateTime transactionDate = DateTime.parse(
            data['date'] ?? '1970-01-01',
          );
          double amount = double.tryParse(data['edtAmount'] ?? '0') ?? 0.0;
          String description = data['description'] ?? '';

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
        _isLoading = false;
      });

      await _loadPayments();
    } catch (e) {
      print('Error loading wallet data: $e');
      setState(() => _isLoading = false);
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
    return '$monthName $year';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D7377),
        title: const Text(
          'My Wallet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.teal.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading wallet data...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadWalletData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Month Picker Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: InkWell(
                          onTap: _showMonthYearPicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select Period',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getDisplayMonth(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Balance Cards
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildBalanceCard(
                                'Opening Balance',
                                openingBalance,
                                Colors.blue,
                                Icons.arrow_downward,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBalanceCard(
                                'Closing Balance',
                                closingBalance,
                                Colors.green,
                                Icons.arrow_upward,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Warning Banner
                      if (!hasWalletMoney)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber[700],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add money to wallet to see payment transactions',
                                  style: TextStyle(
                                    color: Colors.amber[900],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Transactions Section Header
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transactions.length} transaction${transactions.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transactions Table
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              transactions.isEmpty
                                  ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 56,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          hasWalletMoney
                                              ? 'No transactions for this month'
                                              : 'No wallet data available',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          hasWalletMoney
                                              ? 'Try selecting a different month'
                                              : 'Add money to get started',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      // TABLE HEADER
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D7377),
                                        ),
                                        child: Row(
                                          children: [
                                            _buildTableHeaderCell('Date', 0.20),
                                            _buildTableHeaderCell(
                                              'Account Name',
                                              0.35,
                                            ),
                                            _buildTableHeaderCell(
                                              'Amount',
                                              0.22,
                                            ),
                                            _buildTableHeaderCell(
                                              'Action',
                                              0.23,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // TABLE ROWS
                                      SizedBox(
                                        height: transactions.length * 70.0,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: transactions.length,
                                          itemBuilder: (context, index) {
                                            final transaction =
                                                transactions[index];
                                            final isCredit =
                                                transaction.amount >= 0;
                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1,
                                                  ),
                                                ),
                                                color:
                                                    index.isEven
                                                        ? Colors.grey.shade50
                                                        : Colors.white,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 20,
                                                    child: _buildTableDataCell(
                                                      DateFormat(
                                                        'dd/MM/yyyy',
                                                      ).format(
                                                        DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).parse(
                                                          transaction.date,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 35,
                                                    child: _buildTableDataCell(
                                                      transaction.description,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 22,
                                                    child: _buildTableDataCell(
                                                      '${isCredit ? '+' : '-'} ₹${(isCredit ? transaction.amount : -transaction.amount).toStringAsFixed(0)}',
                                                      textColor:
                                                          isCredit
                                                              ? Colors.green
                                                              : Colors.red,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 23,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                            horizontal: 4,
                                                          ),
                                                      child: InkWell(
                                                        onTap: () {
                                                          _showEditDeleteDialog(
                                                            transaction,
                                                          );
                                                        },
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Edit/Delete',
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .red
                                                                      .shade600,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
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
                      const SizedBox(height: 20),

                      // Closing Balance Summary
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[400]!, Colors.green[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Final Balance',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹ ${closingBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D7377),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMoneyToWalletPage(),
            ),
          ).then((_) => _loadWalletData());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBalanceCard(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransaction transaction, bool isCredit) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isCredit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateFormat('yyyy-MM-dd').parse(transaction.date)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ₹ ${(isCredit ? transaction.amount : -transaction.amount).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showEditDeleteDialog(transaction),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.teal[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, double flex) {
    return Expanded(
      flex: flex.toInt(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTableDataCell(
    String text, {
    Color? textColor,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 11,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
