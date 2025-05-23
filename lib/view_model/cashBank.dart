



import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/receipt.dart';
import '../services/dbhelper/DatabaseHelper.dart';
import '../services/dbhelper/dbhelper.dart';


import 'package:intl/intl.dart';


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
      home: const ReceiptPage(),
    );
  }
}

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptPage> {
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const AddReceiptVoucher(),
          //   ),
          // ).then((_) => _loadReceipts());
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
//
// class CashBank extends StatefulWidget {
//   const CashBank({super.key});
//
//   @override
//   State<CashBank> createState() => _SlidebleListState1();
// }
//
//
//
// String finalDate = '';
// var now = DateTime.now();
// var formatter = DateFormat('yyyy-MM-dd');
// String formattedDate = formatter.format(now);
//
//
//
// final dbhelper = DatabaseHelper.instance;
//
// class _SlidebleListState1 extends State<CashBank> {
//   TextEditingController txt1 = TextEditingController( );
//   TextEditingController txt2 = TextEditingController( );
//
//   String finalDate = '';
//   void getdate(){
//     var now = DateTime.now();
//     var formatter = DateFormat('dd-MM-yyyy');
//     String formattedDate = formatter.format(now);
//
//    print(formattedDate);
//     setState(() {
//       txt1.text = formattedDate;
//      // txt2.text = formattedDate;
//     });
//
//   }
//
//   @override
//   void initState() {
//
//     super.initState();
//     getdate();
//
//
//   }
//
//   // get dbhelper1 => null;
//
//   @override
//   Widget build(BuildContext context) {
//
//
//
//
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Add Account Setup')),
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//
//         leading: IconButton(onPressed: (){
//           Navigator.pop(context);
//
//         }, icon: Icon(Icons.arrow_back, color: Colors.white,
//         )),
//
//         title: Text('Cash/Bank',style: TextStyle(color: Colors.white)),
//
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//     children: [
//
//           Container(
//             width: 150,
//             child:
//
//
//             TextField(
//             //  controller:datePickerController;
//               controller: txt1,
//
//               readOnly: true,
//
//               decoration:
//
//               const InputDecoration(suffixIcon: Icon(Icons.calendar_month),   border: OutlineInputBorder() ),
//
//               onTap: () => onTapFunction(context: context),
//             ),
//           ),
//
//       Container(
//         width: 150,
//
//         child: TextField(
//          // controller:datePickerController;
//           controller: datePickerController,
//           readOnly: true,
//
//           decoration:
//
//           const InputDecoration(  suffixIcon: Icon(Icons.calendar_month),   border: OutlineInputBorder() ),
//
//           onTap: () => onTapFunction(context: context),
//
//         ),
//       ),
//
//
//
//
//
//
//
//
//     ]), ),
//
//
//
//
//
//   );
//
//
//   }
//
// }
// TextEditingController datePickerController = TextEditingController();
// onTapFunction({required BuildContext context}) async {
//   DateTime? pickedDate = await showDatePicker(
//     context: context,
//     lastDate: DateTime.now(),
//     firstDate: DateTime(2015),
//     initialDate: DateTime.now(),
//   );
//   if (pickedDate == null) return;
//
//   datePickerController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
//
//
//
//
// }
