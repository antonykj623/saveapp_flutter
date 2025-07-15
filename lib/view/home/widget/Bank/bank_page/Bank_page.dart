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
          var bankEntry = entry.value.firstWhere(
            (e) => e['ACCOUNTS_cashbanktype'] == '2', // Bank account
            orElse: () => entry.value.first,
          );
          var cashEntry = entry.value.firstWhere(
            (e) =>
                e['ACCOUNTS_cashbanktype'] !=
                '2', // Cash or other non-bank account
            orElse: () => entry.value.last,
          );

          String bankAccountName = await _getAccountName(
            bankEntry['ACCOUNTS_setupid'].toString(),
          );
          String cashAccountName = await _getAccountName(
            cashEntry['ACCOUNTS_setupid'].toString(),
          );

          String transactionType;
          String debitAccount;
          String creditAccount;

          if (bankEntry['ACCOUNTS_type'] == 'debit') {
            transactionType = 'Deposit';
            debitAccount = bankAccountName;
            creditAccount = cashAccountName;
          } else {
            transactionType = 'Withdrawal';
            debitAccount = cashAccountName;
            creditAccount = bankAccountName;
          }

          vouchers.add(
            BankVoucher(
              id: int.parse(entry.key),
              date: _formatDateForParsing(bankEntry['ACCOUNTS_date']),
              debit: debitAccount,
              credit: creditAccount,
              amount: double.parse(bankEntry['ACCOUNTS_amount'].toString()),
              remarks: bankEntry['ACCOUNTS_remarks']?.toString() ?? '',
              transactionType: transactionType,
            ),
          );
        } else {
          print("Data not found for entryId: ${entry.key}");
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
      if (dateString.contains('/')) {
        List<String> parts = dateString.split('/');
        if (parts.length == 3) {
          String day = parts[0].padLeft(2, '0');
          String month = parts[1].padLeft(2, '0');
          String year = parts[2];
          return '$year-$month-$day';
        }
      } else if (dateString.contains('-')) {
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
        backgroundColor: Colors.teal,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Bank Vouchers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadVouchers,
            tooltip: 'Refresh',
          ),
        ],
        elevation: 4,
        shadowColor: Colors.teal.withOpacity(0.4),
      ),
      body: Column(
        children: [
          // Month/Year Picker
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedMonth,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.teal[400], size: 20),
                ],
              ),
            ),
          ),

          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Table(
              border: TableBorder.all(
                color: Colors.teal[100]!,
                width: 1,
                borderRadius: BorderRadius.circular(12),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.0),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
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
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Vouchers...',
                            style: TextStyle(
                              color: Colors.teal[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _filteredVouchers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.teal[200]),
                          const SizedBox(height: 16),
                          Text(
                            'No vouchers found for $_selectedMonth',
                            style: TextStyle(
                              color: Colors.teal[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new voucher to get started!',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.teal[100]!,
                            width: 1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.0),
                          },
                          children:
                              _filteredVouchers.asMap().entries.map((entry) {
                                int index = entry.key;
                                BankVoucher voucher = entry.value;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color:
                                        index % 2 == 0
                                            ? Colors.white
                                            : Colors.teal[50],
                                    borderRadius:
                                        index == _filteredVouchers.length - 1
                                            ? BorderRadius.vertical(
                                              bottom: Radius.circular(12),
                                            )
                                            : null,
                                  ),
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
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 6,
        tooltip: 'Add Voucher',
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
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildTableActionCell(BankVoucher voucher) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => _showActionDialog(voucher),
        child: Text(
          'Edit/\nDelete',
          style: TextStyle(
            color: Colors.red[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Choose Action',
            style: TextStyle(
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('What would you like to do with this voucher?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToEditScreen(voucher);
              },
              child: Text('Edit', style: TextStyle(color: Colors.teal[700])),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmDelete(voucher);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red[600])),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Confirm Delete',
            style: TextStyle(
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Are you sure you want to delete this voucher?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVoucher(voucher);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red[600])),
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
          SnackBar(
            content: Text('Bank voucher deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting voucher: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting voucher: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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
