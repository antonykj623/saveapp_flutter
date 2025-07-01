import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/model/receipt.dart';
import 'package:new_project_2025/view/home/widget/Receipt/add_receipt_voucher_screen/add_receipt_vocher_screen.dart';
import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<Receipt> receipts = [];
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
      List<Map<String, dynamic>> receiptsList = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTSETTINGS");

      // Create a map of setup ID to account name

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
      // setupIdToAccountName['0'] = 'Cash'; // Fallback for Cash account

      // Filter unique debit entries for the selected year-month
      final uniqueDebitEntries = <String, Map<String, dynamic>>{};
      for (var mp in receiptsList) {
        if (mp['ACCOUNTS_VoucherType'] == 2 &&
            mp['ACCOUNTS_type'] == 'debit' &&
            DateFormat(
                  'yyyy-MM',
                ).format(DateFormat('dd/MM/yyyy').parse(mp['ACCOUNTS_date'])) ==
                selectedYearMonth) {
          uniqueDebitEntries[mp['ACCOUNTS_entryid'].toString()] = mp;
        }
      }

      setState(() {
        receipts =
            uniqueDebitEntries.values.map((mp) {
              String debitSetupId = mp['ACCOUNTS_setupid'].toString();
              String accountName =
                  setupIdToAccountName[debitSetupId] ?? 'Unknown Account';

              String paymentMode = 'Cash';
              try {
                var creditEntry = receiptsList.firstWhere(
                  (entry) =>
                      entry['ACCOUNTS_VoucherType'] == 2 &&
                      entry['ACCOUNTS_type'] == 'credit' &&
                      entry['ACCOUNTS_entryid'].toString() ==
                          mp['ACCOUNTS_entryid'].toString(),
                );
                String creditSetupId =
                    creditEntry['ACCOUNTS_setupid'].toString();
              } catch (e) {
                print('Could not find credit entry: $e');
              }

              return Receipt(
                id: int.parse(mp['ACCOUNTS_entryid']),
                date: mp['ACCOUNTS_date'],
                accountName: accountName,
                amount: double.parse(mp['ACCOUNTS_amount'].toString()),
                paymentMode: paymentMode,
                remarks: mp['ACCOUNTS_remarks'] ?? '',
              );
            }).toList();

        total = receipts.fold(0, (sum, receipt) => sum + receipt.amount);
      });
    } catch (e) {
      print('Error loading receipts: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading receipts: $e')));
      }
      setState(() {
        receipts = [];
        total = 0;
      });
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
                  _loadReceipts();
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
    return '$monthName/$year';
  }

  void _navigateToEditReceipt(Receipt receipt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReceiptVoucherPage(receipt: receipt),
      ),
    );

    if (result == true) {
      _loadReceipts();
    }
  }

  void _deleteReceipt(int id) async {
    try {
      final db = await DatabaseHelper().database;

      await db.delete(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
        whereArgs: [2, id.toString()],
      );

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) {
        throw Exception('Double-entry accounting is unbalanced after deletion');
      }

      _loadReceipts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting receipt: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting receipt: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: _showMonthYearPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDisplayMonth(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
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
                        _buildHeaderCell('Date', flex: 1),
                        _buildHeaderCell('Account Name', flex: 2),
                        _buildHeaderCell('Amount', flex: 1),
                        _buildHeaderCell('Cash/Bank', flex: 1),
                        _buildHeaderCell('Action', flex: 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        receipts.isEmpty
                            ? const Center(
                              child: Text('No receipts for this month'),
                            )
                            : Scrollbar(
                              controller: _verticalScrollController,
                              child: ListView.builder(
                                controller: _verticalScrollController,
                                itemCount: receipts.length,
                                itemBuilder: (context, index) {
                                  final receipt = receipts[index];
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
                                        _buildDataCell(receipt.date, flex: 1),
                                        _buildDataCell(
                                          receipt.accountName,
                                          flex: 2,
                                        ),
                                        _buildDataCell(
                                          receipt.amount.toStringAsFixed(2),
                                          flex: 1,
                                        ),
                                        _buildDataCell(
                                          receipt.paymentMode,
                                          flex: 1,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: const Text(
                                                          'Choose Action',
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ListTile(
                                                              leading:
                                                                  const Icon(
                                                                    Icons.edit,
                                                                  ),
                                                              title: const Text(
                                                                'Edit',
                                                              ),
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                _navigateToEditReceipt(
                                                                  receipt,
                                                                );
                                                              },
                                                            ),
                                                            ListTile(
                                                              leading:
                                                                  const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                              title: const Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => AlertDialog(
                                                                        title: const Text(
                                                                          'Confirm Delete',
                                                                        ),
                                                                        content:
                                                                            const Text(
                                                                              'Are you sure you want to delete this receipt?',
                                                                            ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: const Text(
                                                                              'Cancel',
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                              _deleteReceipt(
                                                                                receipt.id!,
                                                                              );
                                                                            },
                                                                            style: TextButton.styleFrom(
                                                                              foregroundColor:
                                                                                  Colors.red,
                                                                            ),
                                                                            child: const Text(
                                                                              'Delete',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                );
                                              },
                                              child: const Text(
                                                'Edit/Delete',
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
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReceiptVoucherPage(),
            ),
          ).then((result) {
            if (result == true) {
              _loadReceipts();
            }
          });
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

  Widget _buildDataCell(String text, {required int flex}) {
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
        ),
      ),
    );
  }
}
