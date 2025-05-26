import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';

import 'addBill.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.pink,
        ),
      ),
      home: const Billing(),
    );
  }
}

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingPageState();
}

class _BillingPageState extends State<Billing> {
  String selectedYearMonth = DateFormat('MM-yyyy').format(DateTime.now());
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();
  String getCurrentMonthYear() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM/yyyy'); // e.g., May/2025
    return formatter.format(now);
  }
  List<Receipt> receipts = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  // Sample data for demonstration
  List<Map<String, dynamic>> sampleData = [
    {
      'date': '23/5/2025',
      'partyName': 'Viii',
      'amount': '255',
      'creditAccount': 'Agriculture\nIncome',
    },
    {
      'date': '24/5/2025',
      'partyName': 'John Doe',
      'amount': '500',
      'creditAccount': 'Sales\nRevenue',
    },
    {
      'date': '25/5/2025',
      'partyName': 'ABC Corp',
      'amount': '1000',
      'creditAccount': 'Service\nIncome',
    },
  ];

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
    // Implement your database loading logic here
    setState(() {
      // Update receipts and total as needed
    });
  }

  void selectDate(bool isStart) {
    showDatePicker(
      context: context,
      //initialDate: isStart ? selected_startDate : selected_endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
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
        title: const Text('Billing', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Date Picker Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => selectDate(true),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            ' ${ _getDisplayStartDate()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.teal),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

              ],
            ),
          ),

          // Table Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildHeaderCell('Date', flex:4),
                        _buildHeaderCell('Name of Party', flex: 3),
                        _buildHeaderCell('Amount', flex: 2),
                        _buildHeaderCell('Credit Account', flex: 3),
                        _buildHeaderCell('Actions', flex: 3),
                      ],
                    ),
                  ),

                  // Table Body
                  Expanded(
                    child: ListView.builder(
                      controller: _verticalScrollController,
                      itemCount: sampleData.length,
                      itemBuilder: (context, index) {
                        final item = sampleData[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildDataCell(item['date'], flex: 4),
                              _buildDataCell(item['partyName'], flex: 3),
                              _buildDataCell(item['amount'], flex: 2),
                              _buildDataCell(item['creditAccount'], flex: 3),
                              _buildActionCell(index, flex: 3),
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

          // Total Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_calculateTotal()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Container(


                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    tooltip: 'Increment',
                    shape:   const CircleBorder(),
                    onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder:(context)=>AddBill( )));


                    },
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
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
        height: 60,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCell(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        //padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _handleEdit(index),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text(
                  'Edit / Delete',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _handleGetReceipt(index),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text(
                  'Get Receipt',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEdit(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen
                _editItem(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteItem(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleGetReceipt(int index) {
    // Implement get receipt functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Getting receipt for ${sampleData[index]['partyName']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editItem(int index) {
    // Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${sampleData[index]['partyName']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${sampleData[index]['partyName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                sampleData.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    double total = 0;
    for (var item in sampleData) {
      total += double.tryParse(item['amount']) ?? 0;
    }
    return total.toStringAsFixed(2);
  }
}