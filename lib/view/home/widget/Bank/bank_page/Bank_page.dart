import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Edit_voucher_bank/Edit_bank_voucherh.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'dart:convert';

class BankVoucherListScreen extends StatefulWidget {
  @override
  _BankVoucherListScreenState createState() => _BankVoucherListScreenState();
}

class _BankVoucherListScreenState extends State<BankVoucherListScreen> {
  List<BankVoucher> _vouchers = [];
  List<BankVoucher> _filteredVouchers = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMonth = DateFormat('MMM/yyyy').format(DateTime.now());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> voucherMaps = await db.query(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ?",
        whereArgs: [5], 
      );

      Map<String, List<Map<String, dynamic>>> groupedVouchers = {};

      for (var map in voucherMaps) {
        String entryId = map['ACCOUNTS_entryid'].toString();
        if (!groupedVouchers.containsKey(entryId)) {
          groupedVouchers[entryId] = [];
        }
        groupedVouchers[entryId]!.add(map);
      }

      List<BankVoucher> vouchers = [];

      for (var entry in groupedVouchers.entries) {
        if (entry.value.length >= 2) {
          var debitEntry = entry.value.firstWhere(
            (e) => e['ACCOUNTS_type'] == 'credit',
            orElse: () => entry.value.first,
          );
          var creditEntry = entry.value.firstWhere(
            (e) => e['ACCOUNTS_type'] == 'debit',
            orElse: () => entry.value.last,
          );

          String debitAccountName = await _getAccountName(
            debitEntry['ACCOUNTS_setupid'].toString(),
          );
          String creditAccountName = await _getAccountName(
            creditEntry['ACCOUNTS_setupid'].toString(),
          );

          vouchers.add(
            BankVoucher(
              id: int.parse(entry.key),
              date: _formatDateForParsing(debitEntry['ACCOUNTS_date']),
              debit: debitAccountName,
              credit: creditAccountName,
              amount: double.parse(debitEntry['ACCOUNTS_amount'].toString()),
              remarks: debitEntry['ACCOUNTS_remarks']?.toString() ?? '',
            ),
          );
        }
      }

      setState(() {
        _vouchers = vouchers;
        _isLoading = false;
        _filterVouchersByMonth();
      });
    } catch (e) {
      print('Error loading vouchers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateForParsing(String dateString) {
    try {
      // Handle different date formats
      if (dateString.contains('/')) {
        // Format: dd/MM/yyyy or d/M/yyyy
        List<String> parts = dateString.split('/');
        if (parts.length == 3) {
          String day = parts[0].padLeft(2, '0');
          String month = parts[1].padLeft(2, '0');
          String year = parts[2];
          return '$year-$month-$day';
        }
      } else if (dateString.contains('-')) {
        // Already in correct format or needs conversion
        return dateString;
      }
      return DateTime.now().toIso8601String().split('T')[0];
    } catch (e) {
      print('Error formatting date: $e');
      return DateTime.now().toIso8601String().split('T')[0];
    }
  }

  Future<String> _getAccountName(String setupId) async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> accounts = await db.query(
        "TABLE_ACCOUNTSETTINGS",
        where: "keyid = ?",
        whereArgs: [setupId],
      );

      if (accounts.isNotEmpty) {
        Map<String, dynamic> accountData = jsonDecode(accounts.first["data"]);
        return accountData['Accountname']?.toString() ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Error getting account name: $e');
      return 'Unknown';
    }
  }

  void _filterVouchersByMonth() {
    _filteredVouchers =
        _vouchers.where((voucher) {
          try {
            DateTime voucherDate = DateTime.parse(voucher.date);
            return voucherDate.year == _selectedDate.year &&
                voucherDate.month == _selectedDate.month;
          } catch (e) {
            print('Error parsing voucher date: ${voucher.date}');
            return false;
          }
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Voucher'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadVouchers),
        ],
      ),
      body: Column(
        children: [
          // Month/Year Picker
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedMonth,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                ],
              ),
            ),
          ),

          // Table Header
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {
                0: FlexColumnWidth(2.0),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    _buildTableHeaderCell('Date'),
                    _buildTableHeaderCell('Debit'),
                    _buildTableHeaderCell('Amount'),
                    _buildTableHeaderCell('Credit'),
                    _buildTableHeaderCell('Action'),
                  ],
                ),
              ],
            ),
          ),

          // Table Data
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredVouchers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No vouchers found for ${_selectedMonth}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: {
                            0: FlexColumnWidth(2.0),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.5),
                          },
                          children:
                              _filteredVouchers.map((voucher) {
                                return TableRow(
                                  children: [
                                    _buildTableDataCell(
                                      _formatDisplayDate(voucher.date),
                                    ),
                                    _buildTableDataCell(voucher.debit),
                                    _buildTableDataCell(
                                      voucher.amount.toStringAsFixed(0),
                                    ),
                                    _buildTableDataCell(voucher.credit),
                                    _buildTableActionCell(voucher),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddScreen(),
        backgroundColor: Colors.pink,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDisplayDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d/M/yyyy').format(date);
    } catch (e) {
      print('Error formatting display date: $e');
      return dateString;
    }
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableDataCell(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTableActionCell(BankVoucher voucher) {
    return Container(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => _showActionDialog(voucher),
        child: Text(
          'Edit/\nDelete',
          style: TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showActionDialog(BankVoucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Action'),
          content: Text('What would you like to do with this voucher?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToEditScreen(voucher);
              },
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmDelete(voucher);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BankVoucher voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this voucher?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVoucher(voucher);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVoucher(BankVoucher voucher) async {
    try {
      final db = await DatabaseHelper().database;
      await db.delete(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
        whereArgs: [5, voucher.id.toString()],
      );

      _loadVouchers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bank voucher deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting voucher: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting voucher: $e')));
      }
    }
  }

  Future<void> _showMonthYearPicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedMonth = DateFormat('MMM/yyyy').format(pickedDate);
        _filterVouchersByMonth();
      });
    }
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditVoucherScreen()),
    );
    if (result == true) {
      _loadVouchers();
    }
  }

  void _navigateToEditScreen(BankVoucher voucher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditVoucherScreen(voucher: voucher),
      ),
    );
    if (result == true) {
      _loadVouchers();
    }
  }
}
