import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';
import 'add_payment/add_paymet.dart';
import 'databasehelper/data_base_helper.dart';
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
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _loadPayments() async {
    final paymentsList = await DatabaseHelper.instance.getPaymentsByMonth(
      selectedYearMonth,
    );
    setState(() {
      payments = paymentsList;
      total = payments.fold(0, (sum, payment) => sum + payment.amount);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
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
                    child:
                        payments.isEmpty
                            ? const Center(
                              child: Text('No payments for this month'),
                            )
                            : ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: payments.length,
                              itemBuilder: (context, index) {
                                final payment = payments[index];
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
                                        DateFormat('dd/MM/yyyy').format(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).parse(payment.date),
                                        ),
                                        flex: 1,
                                      ),
                                      _buildDataCell(
                                        payment.accountName,
                                        flex: 2,
                                      ),
                                      _buildDataCell(
                                        payment.amount.toString(),
                                        flex: 1,
                                      ),
                                      _buildDataCell(
                                        payment.paymentMode,
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
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            title: const Text(
                                                              'Edit',
                                                            ),
                                                            onTap: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => AddPaymentVoucherPage(
                                                                        payment:
                                                                            payment,
                                                                      ),
                                                                ),
                                                              ).then(
                                                                (_) =>
                                                                    _loadPayments(),
                                                              );
                                                            },
                                                          ),
                                                          ListTile(
                                                            title: const Text(
                                                              'Delete',
                                                            ),
                                                            onTap: () async {
                                                              await DatabaseHelper
                                                                  .instance
                                                                  .deletePayment(
                                                                    payment.id!,
                                                                  );
                                                              _loadPayments();
                                                              if (context
                                                                  .mounted)
                                                                Navigator.pop(
                                                                  context,
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
                                                color: Colors.red,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ${total.toStringAsFixed(1)}',
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
              builder: (context) => const AddPaymentVoucherPage(),
            ),
          ).then((_) => _loadPayments());
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
