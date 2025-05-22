import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';
import 'package:new_project_2025/view/home/widget/Receipt/add_receipt_voucher_screen/add_receipt_vocher_screen.dart';
import 'package:new_project_2025/view/home/widget/Receipt/receipt_database/receipt_database.dart';
import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.pink,
        ),
      ),
      home: const ReceiptsPage(),
    );
  }
}

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

  void _loadReceipts() async {
    final receiptsList = await DatabaseHelper1.instance.getReceiptsByMonth(
      selectedYearMonth,
    );
    setState(() {
      receipts = receiptsList;
      total = receipts.fold(0, (sum, receipt) => sum + receipt.amount);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
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
                            : ListView.builder(
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
                                      _buildDataCell(
                                        DateFormat('dd/M/yyyy').format(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).parse(receipt.date),
                                        ),
                                        flex: 1,
                                      ),
                                      _buildDataCell(
                                        receipt.accountName,
                                        flex: 2,
                                      ),
                                      _buildDataCell(
                                        receipt.amount.toString(),
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
                                                                      ) => AddReceiptVoucherPage(
                                                                        receipt:
                                                                            receipt,
                                                                      ),
                                                                ),
                                                              ).then(
                                                                (_) =>
                                                                    _loadReceipts(),
                                                              );
                                                            },
                                                          ),
                                                          ListTile(
                                                            title: const Text(
                                                              'Delete',
                                                            ),
                                                            onTap: () async {
                                                              await DatabaseHelper1
                                                                  .instance
                                                                  .deleteReceipt(
                                                                    receipt.id!,
                                                                  );
                                                              _loadReceipts();
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
              builder: (context) => const AddReceiptVoucherPage(),
            ),
          ).then((_) => _loadReceipts());
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
