import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Edit_voucher_bank/Edit_bank_voucherh.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';


class BankVoucherListScreen extends StatefulWidget {
  @override
  _BankVoucherListScreenState createState() => _BankVoucherListScreenState();
}

class _BankVoucherListScreenState extends State<BankVoucherListScreen> {
  final BankDatabase _bankDatabase = BankDatabase();
  List<BankVoucher> _vouchers = [];
  List<BankVoucher> _filteredVouchers = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMonth = DateFormat('MMM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final vouchers = await _bankDatabase.getVouchers();
    setState(() {
      _vouchers = vouchers;
      _filterVouchersByMonth();
    });
  }

  void _filterVouchersByMonth() {
    _filteredVouchers =
        _vouchers.where((voucher) {
          DateTime voucherDate = DateTime.parse(voucher.date);
          return voucherDate.year == _selectedDate.year &&
              voucherDate.month == _selectedDate.month;
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
      ),
      body: Column(
        children: [
          // Month Selector
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
            child: Container(
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
                              DateFormat(
                                'd/M/yyyy',
                              ).format(DateTime.parse(voucher.date)),
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
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  Widget _buildTableActionCell(BankVoucher voucher) {
    return Container(
      padding: EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => _navigateToEditScreen(voucher),
        child: Text(
          'Edit/\nDelete',
          style: TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
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
