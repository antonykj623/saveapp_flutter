import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../model/receipt.dart';
import '../../../../../services/dbhelper/DatabaseHelper.dart';
import '../../../../../services/dbhelper/dbhelper.dart';
import '../../../../../view_model/CashBank/cashBank.dart';

import 'monthYearPicker.dart';
// import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';
// import 'package:new_project_2025/view/home/widget/Receipt/add_receipt_voucher_screen/add_receipt_vocher_screen.dart';
// import 'package:new_project_2025/view/home/widget/Receipt/receipt_database/receipt_database.dart';
// import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';


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
      home: const CashBank(),
    );
  }
}

class CashBank extends StatefulWidget {
  const CashBank({super.key});

  @override
  State<CashBank> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<CashBank> {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();

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
    // final receiptsList = await DatabaseHelper1.instance.getReceiptsByMonth(
    //   DateFormat('yyyy-MM-dd').format(selectedDate),
    // );
    // setState(() {
    //   receipts = receiptsList;
    //   total = receipts.fold(0, (sum, receipt) => sum + receipt.amount);
    // });
  }

  void showMonthYearPicker(bool isStart) {
    showDatePicker(
      context: context,

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

          // _loadReceipts();
        });
      }
    });
  }

  selectDate(bool isStart) {
    showDatePicker(
      context: context,

      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          // selectedDate = pickedDate;
          selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
          if (isStart) {
            selected_startDate = pickedDate;
          } else {
            selected_endDate = pickedDate;
          }
          _loadReceipts();
        });
      }
    });
  }

  String _getDisplayMonth() {
    final parts = selectedYearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat(
      'MMMM',
    ).format(DateTime(int.parse(year), month));
    return '$monthName $year';
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Cash/Bank', style: TextStyle(color: Colors.white)),
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
                    onTap: () {
                      selectDate(true);
                    },
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
                    onTap:() {
                      selectDate(false);
                    },
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _loadReceipts(); // Reload receipts based on current selections
            },
            child: const Text("Search"),
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
                                                  // Navigator.pop(context);
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) => AddReceiptVoucher(
                                                  //       receipt: receipt,
                                                  //     ),
                                                  //   ),
                                                  // ).then((_) => _loadReceipts());
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
                                      'View',
                                      style: TextStyle(
                                        color: Colors.green,
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
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: DataTable(
          //   border: TableBorder(top: BorderSide(color: Colors.black, width: 2), bottom: BorderSide(color: Colors.black, width: 1),verticalInside: BorderSide(width: 2, color: Colors.black, style: BorderStyle.solid),),
          //
          //  //   border: TableBorder(verticalInside: BorderSide(width: 1, color: Colors.black, style: BorderStyle.solid),horizontalInside: BorderSide(width: 1, color: Colors.black, style: BorderStyle.solid)),
          //
          //     columns: [
          //       DataColumn(label: Text('Date')),
          //
          //       DataColumn(label: Text('Name')),
          //       DataColumn(label: Text('Credit')),
          //       DataColumn(label: Text('Debit')),
          //     ],
          //     rows: [
          //       DataRow(cells: [
          //
          //         DataCell(Text('1')),
          //         DataCell(Text( 'fffdgg')),
          //         DataCell(Text('dsffdsf'),
          //
          //         ),
          //
          //
          //         DataCell(Text('errr'),
          //         )
          //       ] ),
          //       DataRow(cells: [
          //         DataCell(Text('Total')),
          //   DataCell(Text( 'fffdgg')),
          //            DataCell(Text('dsffdsf')),
          //         DataCell(Text('dsffdeer34343sf'),
          //         )
          //       ]),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text(
          //     'Total: ${total.toStringAsFixed(1)}',
          //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //   ),
          // ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Theme.of(context).colorScheme.secondary,
      //   child: const Icon(Icons.add, color: Colors.white),
      //   onPressed: () {
      //     // Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (context) => const AddReceiptVoucher(),
      //     //   ),
      //     // ).then((_) => _loadReceipts());
      //   },
      // ),

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