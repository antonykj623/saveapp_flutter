// //Displays bills grouped by month/year.
// //
// // Allows editing and deleting individual bills.
// //
// // Calculates and displays total billing amount.
// //
// // Provides filtering via a date picker.
// //
// // Includes a floating action button to add a new bill.

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_project_2025/view_model/Billing/addBill.dart';
// import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'EditDeleteBill.dart';
// import 'addBill.dart';

// class Billing extends StatefulWidget {
//   const Billing({super.key});

//   @override
//   State<Billing> createState() => _BillingPageState();
// }

// class _BillingPageState extends State<Billing> {
//   List<Map<String, dynamic>> billData = [];
//   String selectedYearMonth = DateFormat('MM-yyyy').format(DateTime.now());
//   DateTime selectedStartDate = DateTime.now();
//   DateTime selectedEndDate = DateTime.now();
//   final ScrollController _verticalScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _loadBillData();
//   }

//   @override
//   void dispose() {
//     _verticalScrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBillData() async {
//     try {
//       final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');

//       // Filter data based on selected date range
//       List<Map<String, dynamic>> filteredData =
//       data.where((item) {
//         String dateStr = item['ACCOUNTS_date'] ?? '';
//         if (dateStr.isEmpty) return false;

//         try {
//           DateTime itemDate;
//           // Handle both date formats
//           if (dateStr.contains('-') && dateStr
//               .split('-')
//               .length == 3) {
//             if (dateStr.split('-')[0].length == 4) {
//               // yyyy-MM-dd format
//               itemDate = DateTime.parse(dateStr);
//             } else {
//               // dd-MM-yyyy format
//               List<String> parts = dateStr.split('-');
//               itemDate = DateTime(
//                 int.parse(parts[2]),
//                 int.parse(parts[1]),
//                 int.parse(parts[0]),
//               );
//             }
//           } else {
//             return false;
//           }

//           // Filter by month and year
//           return itemDate.year == selectedStartDate.year &&
//               itemDate.month == selectedStartDate.month;
//         } catch (e) {
//           print("Date parsing error: $e");
//           return false;
//         }
//       }).toList();

//       // Group credit and debit entries by bill number
//       Map<String, Map<String, dynamic>> billGroups = {};
//       for (var item in filteredData) {
//         String billNumber =
//             item['ACCOUNTS_billVoucherNumber']?.toString() ?? '';
//         String type = item['ACCOUNTS_type'] ?? '';

//         if (billNumber.isNotEmpty) {
//           if (!billGroups.containsKey(billNumber)) {
//             billGroups[billNumber] = {
//               'billNumber': billNumber,
//               'date': item['ACCOUNTS_date'],
//               'amount': item['ACCOUNTS_amount'],
//               'remarks': item['ACCOUNTS_remarks'],
//               'credit': null,
//               'debit': null,
//             };
//           }
//           if (type == 'credit') {
//             billGroups[billNumber]!['credit'] = item;
//           } else if (type == 'debit') {
//             billGroups[billNumber]!['debit'] = item;
//           }
//         }
//       }

//       // Convert to list and get account names
//       List<Map<String, dynamic>> processedBills = [];
//       for (var bill in billGroups.values) {
//         String customerName = await _getAccountName(
//           bill['credit']?['ACCOUNTS_setupid'] ?? '0',
//         );
//         String incomeName = await _getAccountName(
//           bill['debit']?['ACCOUNTS_setupid'] ?? '0',
//         );

//         // Format date for display
//         String displayDate = bill['date'];
//         try {
//           DateTime dateTime;
//           if (displayDate.split('-')[0].length == 4) {
//             // yyyy-MM-dd format
//             dateTime = DateTime.parse(displayDate);
//           } else {
//             // dd-MM-yyyy format
//             List<String> parts = displayDate.split('-');
//             dateTime = DateTime(
//               int.parse(parts[2]),
//               int.parse(parts[1]),
//               int.parse(parts[0]),
//             );
//           }
//           displayDate = DateFormat('dd-MM-yyyy').format(dateTime);
//         } catch (e) {
//           // Keep original format if parsing fails
//         }

//         processedBills.add({
//           'date': displayDate,
//           'partyName': customerName,
//           'amount': bill['amount'],
//           'creditAccount': incomeName,
//           'billNumber': bill['billNumber'],
//         });
//       }

//       setState(() {
//         billData = processedBills;
//       });
//     } catch (e) {
//       print("Error loading bill data: $e");
//     }
//   }
//   //Finds the account name corresponding to a setup ID by reading and decoding data from the database.
//   //
//   // Used for showing partyName and creditAccount in the table.

//   Future<String> _getAccountName(String id) async {
//     try {
//       List<Map<String, dynamic>> allRows = await DatabaseHelper().queryallacc();
//       for (var row in allRows) {
//         if (row['keyid'].toString() == id) {
//           Map<String, dynamic> dat = jsonDecode(row["data"]);
//           return dat['Accountname'].toString();
//         }
//       }
//       return 'Unknown Account';
//     } catch (e) {
//       print("Error getting account name: $e");
//       return 'Error';
//     }
//   }


//   String _getDisplayStartDate() {
//     return DateFormat('MM/yyyy').format(selectedStartDate);
//   }

//   String _getDisplayEndDate() {
//     return DateFormat('dd/MM/yyyy').format(selectedEndDate);
//   }

//   void selectDate(bool isStart) {
//     showDatePicker(
//       context: context,
//       initialDate: isStart ? selectedStartDate : selectedEndDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     ).then((pickedDate) {
//       if (pickedDate != null) {
//         setState(() {
//           selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
//           if (isStart) {
//             selectedStartDate = pickedDate;
//           } else {
//             selectedEndDate = pickedDate;
//           }
//           _loadBillData(); 
//         });
//       }
//     });
//   }

//   String _calculateTotal() {
//     double total = 0;
//     for (var item in billData) {
//       total += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
//     }
//     return total.toStringAsFixed(2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: const Text('Billing', style: TextStyle(color: Colors.white)),
//       ),
//       body: Column(
//         children: [
//           // Date Picker Section
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () => selectDate(true),
//                     child: Container(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _getDisplayStartDate(),
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           const Icon(Icons.calendar_today, color: Colors.teal),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.black),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   // Table Header
//                   Container(
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.teal.shade50,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(8),
//                         topRight: Radius.circular(8),
//                       ),
//                       border: const Border(
//                         bottom: BorderSide(color: Colors.black, width: 2),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         _buildHeaderCell('Date', flex: 4),
//                         _buildHeaderCell('Name of Party', flex: 3),
//                         _buildHeaderCell('Amount', flex: 2),
//                         _buildHeaderCell('Credit Account', flex: 3),
//                         _buildHeaderCell('Actions', flex: 3),
//                       ],
//                     ),
//                   ),
//                   // Table Body
//                   Expanded(
//                     child: ListView.builder(
//                       controller: _verticalScrollController,
//                       itemCount: billData.length,
//                       itemBuilder: (context, index) {
//                         final item = billData[index];
//                         return Container(
//                           decoration: BoxDecoration(
//                             border: Border(
//                               bottom: BorderSide(color: Colors.black, width: 1),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               _buildDataCell(item['date'], flex: 4),
//                               _buildDataCell(item['partyName'], flex: 3),
//                               _buildDataCell(item['amount'], flex: 2),
//                               _buildDataCell(item['creditAccount'], flex: 3),
//                               _buildActionCell(
//                                 index,
//                                 item['billNumber'],
//                                 flex: 3,
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Total Section
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.teal.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.teal.shade200),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total Amount:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '₹${_calculateTotal()}',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal.shade700,
//                   ),
//                 ),
//                 FloatingActionButton(
//                   backgroundColor: Colors.red,
//                   tooltip: 'Add Bill',
//                   shape: const CircleBorder(),
//                   onPressed: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const AddBill()),
//                     );
//                     if (result == true) {
//                       _loadBillData(); // Refresh data after adding a new bill
//                     }
//                   },
//                   child: const Icon(Icons.add, color: Colors.white, size: 25),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderCell(String text, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Container(
//         height: 60,
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           border: Border(right: BorderSide(color: Colors.black)),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildDataCell(String text, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Container(
//         constraints: const BoxConstraints(minHeight: 120),
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//         decoration: BoxDecoration(
//           border: Border(right: BorderSide(color: Colors.black)),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 13),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCell(int index, String billNumber, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Container(
//         constraints: const BoxConstraints(minHeight: 80),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => EditBill(billNumber: billNumber),
//                     ),
//                   ).then((value) {
//                     if (value == true) {
//                       _loadBillData(); // Refresh data after editing/deleting
//                     }
//                   });
//                 },
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                 ),
//                 child: const Text(
//                   'Edit / Delete',
//                   style: TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ),
//             ),
//             Container(
//               height: 1,
//               width: double.infinity,
//               color: Colors.black,
//               margin: const EdgeInsets.symmetric(vertical: 4),
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => _handleGetReceipt(index),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                 ),
//                 child: const Text(
//                   'Get Receipt',
//                   style: TextStyle(color: Colors.green, fontSize: 12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleGetReceipt(int index) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Getting receipt for ${billData[index]['partyName']}'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }

