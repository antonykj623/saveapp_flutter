import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../save_DB/Budegt_database_helper/Save_DB.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime selectedStartDate = DateTime.now().subtract(Duration(days: 30));
  DateTime selectedEndDate = DateTime.now();
  List<Map<String, dynamic>> allTransactions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = await DatabaseHelper().database;

      // Get all account settings
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');
      
      // Map to store account names
      Map<String, String> accountNames = {};
      for (var acc in accounts) {
        try {
          final data = acc['data'];
          if (data is String) {
            Map<String, dynamic> accData = jsonDecode(data);
            accountNames[acc['keyid'].toString()] = accData['Accountname'].toString();
          }
        } catch (e) {
          print('Error parsing account: $e');
        }
      }

      // Get all transactions
      final transactions = await db.query(
        'TABLE_ACCOUNTS',
        orderBy: 'ACCOUNTS_date DESC, ACCOUNTS_id DESC',
      );

      List<Map<String, dynamic>> txList = [];

      for (var tx in transactions) {
        String setupId = tx['ACCOUNTS_setupid'].toString();
        String accountName = accountNames[setupId] ?? 'Unknown Account';
        String dateStr = tx['ACCOUNTS_date'].toString();
        double amount = double.parse(tx['ACCOUNTS_amount'].toString());
        bool isDebit = tx['ACCOUNTS_type'].toString().toLowerCase() == 'debit';

        // Check if transaction is in date range
        if (_isDateInRange(dateStr, selectedStartDate, selectedEndDate)) {
          txList.add({
            'date': dateStr,
            'account': accountName,
            'debit': isDebit ? amount.abs() : 0,
            'credit': isDebit ? 0 : amount.abs(),
            'type': isDebit ? 'Dr' : 'Cr',
            'remarks': tx['ACCOUNTS_remarks']?.toString() ?? '',
          });
        }
      }

      setState(() {
        allTransactions = txList;
        isLoading = false;
      });

      print('Loaded ${txList.length} transactions');
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e2) {
        try {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (e3) {
          return DateTime.now();
        }
      }
    }
  }

  bool _isDateInRange(String dateStr, DateTime start, DateTime end) {
    try {
      DateTime txDate = _parseDate(dateStr);
      DateTime startOfDay = DateTime(start.year, start.month, start.day);
      DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
      return txDate.isAfter(startOfDay.subtract(Duration(seconds: 1))) &&
          txDate.isBefore(endOfDay.add(Duration(seconds: 1)));
    } catch (e) {
      return false;
    }
  }

  void _selectDate(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          if (isStart) {
            selectedStartDate = pickedDate;
          } else {
            selectedEndDate = pickedDate;
          }
        });
      }
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('d-M-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Date Selection Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Start Date
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(selectedStartDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.calendar_today, 
                            size: 20, 
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // End Date
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(selectedEndDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.calendar_today, 
                            size: 20, 
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadAllTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transactions Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            _buildHeaderCell('Date'),
                            _buildHeaderCell('Account'),
                            _buildHeaderCell('Debit'),
                            _buildHeaderCell('Credit'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Table Body
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          )
                        : allTransactions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'for the selected date range',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: allTransactions.length,
                                itemBuilder: (context, index) {
                                  final tx = allTransactions[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.pink.shade50
                                          : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2.5),
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(2),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            _buildDataCell(tx['date']),
                                            _buildDataCell(tx['account']),
                                            _buildDataCell(
                                              tx['debit'] > 0
                                                  ? tx['debit']
                                                      .toStringAsFixed(0)
                                                  : '',
                                              color: Colors.black,
                                            ),
                                            _buildDataCell(
                                              tx['credit'] > 0
                                                  ? tx['credit']
                                                      .toStringAsFixed(0)
                                                  : '',
                                              color: Colors.black,
                                            ),
                                          ],
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

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}