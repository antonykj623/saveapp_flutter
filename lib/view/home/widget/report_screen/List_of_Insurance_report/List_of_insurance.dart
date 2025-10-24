import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class ListOfInsurancePage extends StatefulWidget {
  const ListOfInsurancePage({super.key});

  @override
  State<ListOfInsurancePage> createState() => _ListOfInsurancePageState();
}

class _ListOfInsurancePageState extends State<ListOfInsurancePage> {
  List<InsuranceAccount> insuranceAccounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsuranceAccounts();
  }

  Future<void> _loadInsuranceAccounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTSETTINGS");

      List<Map<String, dynamic>> transactions = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");

      List<InsuranceAccount> tempInsurance = [];

      for (var account in accountSettings) {
        try {
          final dataValue = account["data"];
          if (dataValue is String && dataValue.isNotEmpty) {
            Map<String, dynamic> accountData = jsonDecode(dataValue);
            String accountName = accountData['Accountname'] ?? 'Unknown';
            String accountType = accountData['Accounttype'] ?? '';

            if (accountType != 'Insurance') {
              continue;
            }

            String setupId = account['keyid'].toString();

            List<Map<String, dynamic>> accountTransactions =
                transactions
                    .where(
                      (txn) => txn['ACCOUNTS_setupid'].toString() == setupId,
                    )
                    .toList();

            accountTransactions.sort((a, b) {
              try {
                final dateA = _parseDate(a['ACCOUNTS_date']);
                final dateB = _parseDate(b['ACCOUNTS_date']);
                return dateA.compareTo(dateB);
              } catch (e) {
                return 0;
              }
            });

            double openingBalance = 0;
            bool hasOpeningBalance = false;

            if (accountTransactions.isNotEmpty) {
              var firstTxn = accountTransactions[0];
              String firstType =
                  (firstTxn['ACCOUNTS_type'] ?? '').toLowerCase();

              if (firstType == 'debit') {
                openingBalance =
                    double.tryParse(firstTxn['ACCOUNTS_amount'].toString()) ??
                    0;
                hasOpeningBalance = true;
              }
            }

            if (!hasOpeningBalance) {
              openingBalance =
                  double.tryParse(
                    accountData['balance']?.toString() ??
                        accountData['OpeningBalance']?.toString() ??
                        accountData['Amount']?.toString() ??
                        '0',
                  ) ??
                  0;
            }

            int transactionStartIndex = hasOpeningBalance ? 1 : 0;

            double totalDebit = 0;
            double totalCredit = 0;

            for (
              int i = transactionStartIndex;
              i < accountTransactions.length;
              i++
            ) {
              var txn = accountTransactions[i];
              double amount =
                  double.tryParse(txn['ACCOUNTS_amount'].toString()) ?? 0;
              String type = (txn['ACCOUNTS_type'] ?? '').toLowerCase();

              if (type == 'debit') {
                totalDebit += amount;
              } else if (type == 'credit') {
                totalCredit += amount;
              }
            }

            String lastTransactionType = '';
            double lastTransactionAmount = 0;

            if (accountTransactions.length > transactionStartIndex) {
              var lastTxn = accountTransactions[accountTransactions.length - 1];
              lastTransactionType =
                  (lastTxn['ACCOUNTS_type'] ?? '').toLowerCase();
              lastTransactionAmount =
                  double.tryParse(lastTxn['ACCOUNTS_amount'].toString()) ?? 0;
            }

            double pendingAmount = totalDebit - totalCredit;
            String pendingType = pendingAmount >= 0 ? 'Dr' : 'Cr';
            double pendingAbsolute = pendingAmount.abs();

            if (totalDebit == 0 && totalCredit == 0) {
              pendingAbsolute = 0;
            }

            double closingBalance = openingBalance + totalDebit - totalCredit;

            tempInsurance.add(
              InsuranceAccount(
                setupId: setupId,
                accountName: accountName,
                accountType: accountType,
                openingBalance: openingBalance,
                totalDebit: totalDebit,
                totalCredit: totalCredit,
                closingBalance: closingBalance,
                transactionCount:
                    accountTransactions.length - transactionStartIndex,
                lastTransactionType: lastTransactionType,
                lastTransactionAmount: lastTransactionAmount,
                pendingAmount: pendingAbsolute,
                pendingType: pendingType,
              ),
            );
          }
        } catch (e) {
          print('Error parsing account: $e');
        }
      }

      tempInsurance.sort((a, b) => a.accountName.compareTo(b.accountName));

      setState(() {
        insuranceAccounts = tempInsurance;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading insurance: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading insurance: $e')));
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
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  void _navigateToLedger(InsuranceAccount insurance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceLedgerPage(insurance: insurance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalInsurance = insuranceAccounts.fold(
      0,
      (sum, insurance) => sum + insurance.closingBalance,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'List Of My Insurance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : insuranceAccounts.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No insurance accounts found.\nAdd insurance from Account Setup.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
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
                                _buildHeaderCell('Account', flex: 2),
                                _buildHeaderCell('Last\nAmount', flex: 2),
                                _buildHeaderCell('Pending', flex: 2),
                                _buildHeaderCell('Balance', flex: 2),
                                _buildHeaderCell('Action', flex: 1),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: insuranceAccounts.length,
                              itemBuilder: (context, index) {
                                final insurance = insuranceAccounts[index];
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
                                      _buildDataCell(
                                        insurance.accountName,
                                        flex: 2,
                                      ),
                                      _buildDataCell(
                                        insurance.lastTransactionAmount > 0
                                            ? '${insurance.lastTransactionAmount.toStringAsFixed(0)} ${insurance.lastTransactionType == 'debit' ? 'Dr' : 'Cr'}'
                                            : '-',
                                        flex: 2,
                                        color:
                                            insurance.lastTransactionType ==
                                                    'debit'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      _buildDataCell(
                                        insurance.pendingAmount > 0
                                            ? '${insurance.pendingAmount.toStringAsFixed(0)} ${insurance.pendingType}'
                                            : '-',
                                        flex: 2,
                                        color:
                                            insurance.pendingType == 'Dr'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      _buildDataCell(
                                        insurance.closingBalance.toStringAsFixed(
                                          0,
                                        ),
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: TextButton(
                                            onPressed:
                                                () =>
                                                    _navigateToLedger(insurance),
                                            child: const Text(
                                              'View',
                                              style: TextStyle(
                                                color: Colors.blue,
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Insurance:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹ ${totalInsurance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
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

class InsuranceAccount {
  final String setupId;
  final String accountName;
  final String accountType;
  final double openingBalance;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;
  final int transactionCount;
  final String lastTransactionType;
  final double lastTransactionAmount;
  final double pendingAmount;
  final String pendingType;

  InsuranceAccount({
    required this.setupId,
    required this.accountName,
    required this.accountType,
    required this.openingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
    required this.transactionCount,
    required this.lastTransactionType,
    required this.lastTransactionAmount,
    required this.pendingAmount,
    required this.pendingType,
  });
}

class InsuranceLedgerPage extends StatefulWidget {
  final InsuranceAccount insurance;

  const InsuranceLedgerPage({super.key, required this.insurance});

  @override
  State<InsuranceLedgerPage> createState() => _InsuranceLedgerPageState();
}

class _InsuranceLedgerPageState extends State<InsuranceLedgerPage> {
  List<LedgerEntry> ledgerEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> transactions = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");

      List<LedgerEntry> tempEntries = [];

      List<Map<String, dynamic>> accountTransactions =
          transactions
              .where(
                (txn) =>
                    txn['ACCOUNTS_setupid'].toString() ==
                    widget.insurance.setupId,
              )
              .toList();

      accountTransactions.sort((a, b) {
        try {
          final dateA = _parseDate(a['ACCOUNTS_date']);
          final dateB = _parseDate(b['ACCOUNTS_date']);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      if (widget.insurance.openingBalance > 0) {
        tempEntries.add(
          LedgerEntry(
            date:
                accountTransactions.isNotEmpty
                    ? accountTransactions[0]['ACCOUNTS_date'] ?? '1/1/2025'
                    : '1/1/2025',
            name: 'Opening Balance',
            debit: widget.insurance.openingBalance,
            credit: 0,
            description: 'Initial Balance (Locked)',
            voucherType: 0,
          ),
        );
      }

      int startIndex =
          (accountTransactions.isNotEmpty &&
                  (accountTransactions[0]['ACCOUNTS_type'] ?? '')
                          .toLowerCase() ==
                      'debit')
              ? 1
              : 0;

      for (int i = startIndex; i < accountTransactions.length; i++) {
        var txn = accountTransactions[i];
        String date = txn['ACCOUNTS_date'] ?? '';
        String type = (txn['ACCOUNTS_type'] ?? '').toLowerCase();
        double amount = double.tryParse(txn['ACCOUNTS_amount'].toString()) ?? 0;
        String remarks = txn['ACCOUNTS_remarks'] ?? '';
        int voucherType = txn['ACCOUNTS_VoucherType'] ?? 0;

        String name = '';
        if (voucherType == 1) {
          name = 'Payment';
        } else if (voucherType == 2) {
          name = 'Receipt';
        } else if (voucherType == 3) {
          name = 'Journal';
        } else {
          name = 'Transaction';
        }

        double debit = 0;
        double credit = 0;

        if (type == 'debit') {
          debit = amount;
        } else if (type == 'credit') {
          credit = amount;
        }

        tempEntries.add(
          LedgerEntry(
            date: date,
            name: name,
            debit: debit,
            credit: credit,
            description: remarks,
            voucherType: voucherType,
          ),
        );
      }

      setState(() {
        ledgerEntries = tempEntries;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading ledger: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading ledger: $e')));
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
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    double totalDebit = ledgerEntries.fold(0, (sum, e) => sum + e.debit);
    double totalCredit = ledgerEntries.fold(0, (sum, e) => sum + e.credit);
    int transactionCount = ledgerEntries.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ledger: ${widget.insurance.accountName}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                      margin: const EdgeInsets.all(16),
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
                                _buildHeaderCell('Date', flex: 1),
                                _buildHeaderCell('Name', flex: 2),
                                _buildHeaderCell('Amount', flex: 2),
                                _buildHeaderCell('Description', flex: 2),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: ledgerEntries.length,
                              itemBuilder: (context, index) {
                                final entry = ledgerEntries[index];
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
                                      _buildDataCell(entry.date, flex: 1),
                                      _buildDataCell(entry.name, flex: 2),
                                      _buildDataCell(
                                        entry.debit > 0
                                            ? '${entry.debit.toStringAsFixed(2)} Dr'
                                            : '${entry.credit.toStringAsFixed(2)} Cr',
                                        flex: 2,
                                        color:
                                            entry.debit > 0
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      _buildDataCell(
                                        entry.description,
                                        flex: 2,
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
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade400)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Transactions:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '$transactionCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Debit (Dr):',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹ ${totalDebit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Credit (Cr):',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹ ${totalCredit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 2),
                Row(
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
                      '₹ ${widget.insurance.closingBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
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

class LedgerEntry {
  final String date;
  final String name;
  final double debit;
  final double credit;
  final String description;
  final int voucherType;

  LedgerEntry({
    required this.date,
    required this.name,
    required this.debit,
    required this.credit,
    required this.description,
    required this.voucherType,
  });
}