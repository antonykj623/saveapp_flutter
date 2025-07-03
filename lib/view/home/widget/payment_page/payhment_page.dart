import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'add_payment/add_paymet.dart';
import 'payment_class/payment_class.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<Payment> payments = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      List<Map<String, dynamic>> paymentsList = await DatabaseHelper().getAllData("TABLE_ACCOUNTS");
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS");

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
            DateFormat('yyyy-MM').format(DateFormat('dd/MM/yyyy').parse(mp['ACCOUNTS_date'])) == selectedYearMonth) {
          uniqueDebitEntries[mp['ACCOUNTS_entryid'].toString()] = mp;
        }
      }

      setState(() {
        payments = uniqueDebitEntries.values.map((mp) {
          String debitSetupId = mp['ACCOUNTS_setupid'].toString();
          String accountName = setupIdToAccountName[debitSetupId] ?? 'Unknown Account (ID: $debitSetupId)';

          String paymentMode = 'Cash';
          try {
            var creditEntry = paymentsList.firstWhere(
              (entry) =>
                  entry['ACCOUNTS_VoucherType'] == 1 &&
                  entry['ACCOUNTS_type'] == 'credit' &&
                  entry['ACCOUNTS_entryid'].toString() == mp['ACCOUNTS_entryid'].toString(),
            );
            String creditSetupId = creditEntry['ACCOUNTS_setupid'].toString();
            paymentMode = setupIdToAccountName[creditSetupId] ?? 'Cash';
          } catch (e) {
            print('Could not find credit entry for payment ID ${mp['ACCOUNTS_entryid']}: $e');
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading payments: $e')));
      }
      setState(() {
        payments = [];
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
      builder: (context) => AlertDialog(
        content: MonthYearPicker(
          initialMonth: initialMonth,
          initialYear: initialYear,
          onDateSelected: (int month, int year) {
            setState(() {
              selectedYearMonth = '$year-${month.toString().padLeft(2, '0')}';
              _loadPayments();
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

  void _navigateToEditPayment(Payment payment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentVoucherPage(payment: payment),
      ),
    );

    if (result == true) {
      _loadPayments();
    }
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

      _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting payment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
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
                    child: payments.isEmpty
                        ? const Center(
                            child: Text('No payments for this month'),
                          )
                        : Scrollbar(
                            controller: _verticalScrollController,
                            child: ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: payments.length,
                              itemBuilder: (context, index) {
                                final payment = payments[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(payment.date, flex: 1),
                                      _buildDataCell(payment.accountName, flex: 2),
                                      _buildDataCell(payment.amount.toStringAsFixed(2), flex: 1),
                                      _buildDataCell(payment.paymentMode, flex: 1),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Choose Action'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(Icons.edit),
                                                        title: const Text('Edit'),
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                          _navigateToEditPayment(payment);
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(Icons.delete, color: Colors.red),
                                                        title: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text('Confirm Delete'),
                                                              content: const Text('Are you sure you want to delete this payment?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context),
                                                                  child: const Text('Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                    _deletePayment(payment.id!);
                                                                  },
                                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                                  child: const Text('Delete'),
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
                                            child: const Text('Edit/Delete', style: TextStyle(color: Colors.blue)),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPaymentVoucherPage(),
            ),
          ).then((result) {
            if (result == true) {
              _loadPayments();
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
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