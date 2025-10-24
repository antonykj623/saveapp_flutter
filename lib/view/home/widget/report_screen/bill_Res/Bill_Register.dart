import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class BillRegisterPage extends StatefulWidget {
  const BillRegisterPage({super.key});

  @override
  State<BillRegisterPage> createState() => _BillRegisterPageState();
}

class _BillRegisterPageState extends State<BillRegisterPage> {
  List<Map<String, dynamic>> billsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillsFromDB();
  }

  Future<void> _loadBillsFromDB() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get all accounts data
      final accountsData = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');
      print("Loading bills: ${accountsData.length} records found");

      // Get account settings to map setup IDs to names
      final accountSettings = await DatabaseHelper().getAllData(
        'TABLE_ACCOUNTSETTINGS',
      );
      Map<String, String> setupIdToName = {};

      for (var setting in accountSettings) {
        try {
          Map<String, dynamic> settingData = jsonDecode(setting["data"]);
          String setupId = setting['keyid'].toString();
          String accountName = settingData['Accountname']?.toString() ?? '';
          setupIdToName[setupId] = accountName;
        } catch (e) {
          print("Error parsing account setting: $e");
        }
      }

      // Process bills - group by bill number
      Map<String, Map<String, dynamic>> billsMap = {};

      for (var item in accountsData) {
        try {
          // Check if VoucherType is 3 (Bill)
          String voucherType = item['ACCOUNTS_VoucherType']?.toString() ?? '0';
          if (voucherType == '3') {
            String billNumber =
                item['ACCOUNTS_billVoucherNumber']?.toString() ?? '';
            String type = item['ACCOUNTS_type']?.toString() ?? '';
            String setupId = item['ACCOUNTS_setupid']?.toString() ?? '';
            String amount = item['ACCOUNTS_amount']?.toString() ?? '0';
            String date = item['ACCOUNTS_date']?.toString() ?? '';

            if (billNumber.isNotEmpty) {
              if (!billsMap.containsKey(billNumber)) {
                billsMap[billNumber] = {
                  'billNo': billNumber,
                  'date': date,
                  'customer': '',
                  'amount': amount,
                };
              }

              // If this is a credit entry, it's the customer account
              if (type.toLowerCase() == 'credit') {
                String customerName = setupIdToName[setupId] ?? 'Unknown';
                billsMap[billNumber]!['customer'] = customerName;
              }
            }
          }
        } catch (e) {
          print("Error parsing bill data: $e");
        }
      }

      setState(() {
        billsList = billsMap.values.toList();
        // Sort by date (newest first)
        billsList.sort((a, b) {
          try {
            DateTime dateA = DateTime.parse(a['date']);
            DateTime dateB = DateTime.parse(b['date']);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });
        isLoading = false;
      });

      print("Bills loaded: ${billsList.length}");
    } catch (e) {
      print("Error loading bills: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatBillNumber(String billNo) {
    // Format bill number as Save_Bill_0001
    int? number = int.tryParse(billNo);
    if (number != null) {
      return 'Save_Bill_${number.toString().padLeft(4, '0')}';
    }
    return billNo;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive dimensions
    final dateWidth = screenWidth * 0.22;
    final billNoWidth = screenWidth * 0.30;
    final customerWidth = screenWidth * 0.25;
    final amountWidth = screenWidth * 0.23;
    final columnSpacing = screenWidth * 0.03;
    final rowHeight = screenHeight * 0.08;
    final headerHeight = screenHeight * 0.07;
    final fontSize = screenWidth * 0.038;
    final headerFontSize = screenWidth * 0.042;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Bill register',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBillsFromDB,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('Loading bills...'),
                  ],
                ),
              )
              : billsList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No bills found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your first bill to see it here',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Container(
                width: screenWidth,
                height: screenHeight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.teal.shade50,
                        ),
                        border: TableBorder.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        columnSpacing: columnSpacing,
                        horizontalMargin: screenWidth * 0.04,
                        dataRowHeight: rowHeight,
                        headingRowHeight: headerHeight,
                        columns: [
                          DataColumn(
                            label: Container(
                              width: dateWidth,
                              alignment: Alignment.center,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: headerFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: billNoWidth,
                              alignment: Alignment.center,
                              child: Text(
                                'Bill No.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: headerFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: customerWidth,
                              alignment: Alignment.center,
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: headerFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: amountWidth,
                              alignment: Alignment.center,
                              child: Text(
                                'Amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: headerFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            numeric: true,
                          ),
                        ],
                        rows:
                            billsList.map((bill) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Container(
                                      width: dateWidth,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _formatDate(bill['date'] ?? ''),
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: billNoWidth,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _formatBillNumber(bill['billNo'] ?? ''),
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: customerWidth,
                                      alignment: Alignment.center,
                                      child: Text(
                                        bill['customer'] ?? '',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: amountWidth,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '₹ ${bill['amount'] ?? '0'}',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
