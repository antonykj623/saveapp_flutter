import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_screen.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'EditDeleteBill.dart';
import 'addBill.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingPageState();
}

class _BillingPageState extends State<Billing> with TickerProviderStateMixin {
  List<Map<String, dynamic>> billData = [];
  String selectedYearMonth = DateFormat('MM-yyyy').format(DateTime.now());
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  final ScrollController _verticalScrollController = ScrollController();
  late AnimationController _headerController;
  late AnimationController _cardController;
  late AnimationController _fabController;
  late Animation<double> _headerSlideAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _fabRotateAnimation;
  bool _isLoading = true;
  bool _isGridView = false;

  // Premium feature variables
  bool isCheckingPremium = false;
  PremiumStatus? premiumStatus;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _fabRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));
    _checkPremiumAndLoadData();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _headerController.dispose();
    _cardController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumAndLoadData() async {
    setState(() => isCheckingPremium = true);
    try {
      final status = await PremiumService().checkPremiumStatus(
        forceRefresh: true,
      );
      setState(() {
        premiumStatus = status;
        isCheckingPremium = false;
      });
      _loadBillData();
    } catch (e) {
      setState(() => isCheckingPremium = false);
      _loadBillData();
    }
  }

  Future<void> _loadBillData() async {
    setState(() => _isLoading = true);

    try {
      final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');

      List<Map<String, dynamic>> filteredData =
          data.where((item) {
            String dateStr = item['ACCOUNTS_date'] ?? '';
            if (dateStr.isEmpty) return false;
            try {
              DateTime itemDate;
              if (dateStr.contains('-') && dateStr.split('-').length == 3) {
                if (dateStr.split('-')[0].length == 4) {
                  itemDate = DateTime.parse(dateStr);
                } else {
                  List<String> parts = dateStr.split('-');
                  itemDate = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                }
              } else {
                return false;
              }

              return itemDate.year == selectedStartDate.year &&
                  itemDate.month == selectedStartDate.month;
            } catch (e) {
              print("Date parsing error: $e");
              return false;
            }
          }).toList();

      Map<String, Map<String, dynamic>> billGroups = {};
      for (var item in filteredData) {
        String billNumber =
            item['ACCOUNTS_billVoucherNumber']?.toString() ?? '';
        String type = item['ACCOUNTS_type'] ?? '';

        if (billNumber.isNotEmpty) {
          if (!billGroups.containsKey(billNumber)) {
            billGroups[billNumber] = {
              'billNumber': billNumber,
              'date': item['ACCOUNTS_date'],
              'amount': item['ACCOUNTS_amount'],
              'remarks': item['ACCOUNTS_remarks'],
              'credit': null,
              'debit': null,
            };
          }
          if (type == 'credit') {
            billGroups[billNumber]!['credit'] = item;
          } else if (type == 'debit') {
            billGroups[billNumber]!['debit'] = item;
          }
        }
      }

      List<Map<String, dynamic>> processedBills = [];
      for (var bill in billGroups.values) {
        String customerName = await _getAccountName(
          bill['credit']?['ACCOUNTS_setupid'] ?? '0',
        );
        String incomeName = await _getAccountName(
          bill['debit']?['ACCOUNTS_setupid'] ?? '0',
        );

        String displayDate = bill['date'];
        try {
          DateTime dateTime;
          if (displayDate.split('-')[0].length == 4) {
            dateTime = DateTime.parse(displayDate);
          } else {
            List<String> parts = displayDate.split('-');
            dateTime = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
          displayDate = DateFormat('dd-MM-yyyy').format(dateTime);
        } catch (e) {}

        processedBills.add({
          'date': displayDate,
          'partyName': customerName,
          'amount': bill['amount'],
          'creditAccount': incomeName,
          'billNumber': bill['billNumber'],
          'remarks': bill['remarks'] ?? '',
        });
      }

      setState(() {
        billData = processedBills;
        _isLoading = false;
      });

      _headerController.forward();
      _cardController.forward();
    } catch (e) {
      print("Error loading bill data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getAccountName(String id) async {
    try {
      List<Map<String, dynamic>> allRows = await DatabaseHelper().queryallacc();
      for (var row in allRows) {
        if (row['keyid'].toString() == id) {
          Map<String, dynamic> dat = jsonDecode(row["data"]);
          return dat['Accountname'].toString();
        }
      }
      return 'Unknown Account';
    } catch (e) {
      print("Error getting account name: $e");
      return 'Error';
    }
  }

  String _getDisplayStartDate() {
    return DateFormat('MMMM yyyy').format(selectedStartDate);
  }

  void selectDate(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
          if (isStart) {
            selectedStartDate = pickedDate;
          } else {
            selectedEndDate = pickedDate;
          }
          _headerController.reset();
          _cardController.reset();
          _loadBillData();
        });
      }
    });
  }

  String _calculateTotal() {
    double total = 0;
    for (var item in billData) {
      total += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
    }
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildModernHeader(),
                _buildStatsSection(),
                if (premiumStatus != null)
                  PremiumService.buildPremiumBanner(
                    context: context,
                    status: premiumStatus!,
                    isChecking: isCheckingPremium,
                    onRefresh: _checkPremiumAndLoadData,
                  ),
                _buildViewToggle(),
                Expanded(
                  child:
                      _isLoading
                          ? _buildLoadingState()
                          : billData.isEmpty
                          ? _buildEmptyState()
                          : _isGridView
                          ? _buildGridView()
                          : _buildTableView(),
                ),
              ],
            ),
          ),
          if (isCheckingPremium)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verifying Access...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Opacity(opacity: _headerController.value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade400,
              Colors.purple.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${billData.length} Bills',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      icon: Icon(
                        _isGridView ? Icons.table_chart : Icons.grid_view,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                onTap: () => selectDate(true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade400,
                              Colors.purple.shade300,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Period',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _getDisplayStartDate(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _headerController.value),
          child: Opacity(opacity: _headerController.value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Amount',
                value: '₹${_calculateTotal()}',
                icon: Icons.account_balance_wallet,
                gradient: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Total Bills',
                value: '${billData.length}',
                icon: Icons.receipt_long,
                gradient: [Colors.orange.shade400, Colors.orange.shade600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade100, Colors.purple.shade100],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading bills...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No Bills Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'for ${_getDisplayStartDate()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 32),
          // ElevatedButton.icon(
          //   onPressed: () async {
          //     final result = await Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const AddBill()),
          //     );
          //     if (result == true) {
          //       _headerController.reset();
          //       _cardController.reset();
          //       _loadBillData();
          //     }
          //   },
          //   icon: Icon(Icons.add),
          //   label: Text('Create First Bill'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.deepPurple,
          //     foregroundColor: Colors.white,
          //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                label: 'Table View',
                icon: Icons.table_chart,
                isSelected: !_isGridView,
                onTap: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildToggleButton(
                label: 'Grid View',
                icon: Icons.grid_view,
                isSelected: _isGridView,
                onTap: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.purple.shade400,
                      ],
                    )
                    : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableView() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: FadeTransition(
        opacity: _cardController,
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.deepPurple.shade200,
                      width: 2,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildTableHeader(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _verticalScrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTableBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        _buildHeaderCell('Bill No', Icons.receipt, 120),
        _buildHeaderCell('Date', Icons.calendar_today, 150),
        _buildHeaderCell('Party Name', Icons.person, 200),
        _buildHeaderCell('Amount', Icons.currency_rupee, 140),
        _buildHeaderCell('Credit Account', Icons.account_balance_wallet, 180),
        _buildHeaderCell('Actions', Icons.settings, 180),
      ],
    );
  }

  Widget _buildHeaderCell(String label, IconData icon, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.deepPurple.shade700, size: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.deepPurple.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody() {
    return Column(
      children: List.generate(
        billData.length,
        (index) => _buildTableBodyRow(billData[index], index),
      ),
    );
  }

  Widget _buildTableBodyRow(Map<String, dynamic> item, int index) {
    final isEven = index % 2 == 0;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? Colors.white : Colors.grey.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildBodyCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${item['billNumber'].toString().padLeft(4, '0')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              120,
            ),
            _buildBodyCell(
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.orange.shade700,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              150,
            ),
            _buildBodyCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  item['partyName'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              200,
            ),
            _buildBodyCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: Text(
                  '₹${item['amount']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              140,
            ),
            _buildBodyCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['creditAccount'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              180,
            ),
            _buildBodyCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTableActionButton(
                    icon: Icons.edit,
                    color: Colors.deepPurple,
                    tooltip: 'Edit',
                    onTap: () async {
                      setState(() => isCheckingPremium = true);
                      final canAdd = await PremiumService().canAddData(
                        forceRefresh: true,
                      );
                      final status = PremiumService().getCachedStatus();
                      setState(() {
                        isCheckingPremium = false;
                        premiumStatus = status;
                      });

                      if (status != null && status.productId == 2 && !canAdd) {
                        PremiumService.showPremiumExpiredDialog(
                          context,
                          customMessage: 'Premium required to edit bills.',
                        );
                        return;
                      }

                      if (!canAdd) {
                        PremiumService.showPremiumExpiredDialog(
                          context,
                          customMessage: 'Premium required to edit bills.',
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EditBill(billNumber: item['billNumber']),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _headerController.reset();
                          _cardController.reset();
                          _loadBillData();
                        }
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildTableActionButton(
                    icon: Icons.receipt_long,
                    color: Colors.green,
                    tooltip: 'Receipt',
                    onTap: () => _handleGetReceipt(index),
                  ),
                ],
              ),
              180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCell(Widget child, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: child,
    );
  }

  Widget _buildTableActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildCardListView() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: FadeTransition(
        opacity: _cardController,
        child: ListView.builder(
          controller: _verticalScrollController,
          padding: EdgeInsets.all(16),
          itemCount: billData.length,
          itemBuilder: (context, index) {
            return _buildBillCard(billData[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> item, int index) {
    final colors = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.pink.shade400, Colors.pink.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
    ];
    final gradient = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill #${item['billNumber'].toString().padLeft(4, '0')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withOpacity(0.9),
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              item['date'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${item['amount']}',
                      style: TextStyle(
                        color: gradient[1],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Party Name',
                    value: item['partyName'],
                    color: Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.account_balance_wallet,
                    label: 'Credit Account',
                    value: item['creditAccount'],
                    color: Colors.purple,
                  ),
                  if (item['remarks'] != null &&
                      item['remarks'].toString().isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.note,
                      label: 'Remarks',
                      value: item['remarks'],
                      color: Colors.orange,
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCardActionButton(
                          label: 'Edit',
                          icon: Icons.edit,
                          color: Colors.deepPurple,
                          onTap: () async {
                            setState(() => isCheckingPremium = true);
                            final canAdd = await PremiumService().canAddData(
                              forceRefresh: true,
                            );
                            final status = PremiumService().getCachedStatus();
                            setState(() {
                              isCheckingPremium = false;
                              premiumStatus = status;
                            });

                            if (status != null &&
                                status.productId == 2 &&
                                !canAdd) {
                              PremiumService.showPremiumExpiredDialog(
                                context,
                                customMessage:
                                    'Premium required to edit bills.',
                              );
                              return;
                            }

                            if (!canAdd) {
                              PremiumService.showPremiumExpiredDialog(
                                context,
                                customMessage:
                                    'Premium required to edit bills.',
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditBill(
                                      billNumber: item['billNumber'],
                                    ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _headerController.reset();
                                _cardController.reset();
                                _loadBillData();
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildCardActionButton(
                          label: 'Receipt',
                          icon: Icons.receipt_long,
                          color: Colors.green,
                          onTap: () => _handleGetReceipt(index),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: FadeTransition(
        opacity: _cardController,
        child: GridView.builder(
          controller: _verticalScrollController,
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: billData.length,
          itemBuilder: (context, index) {
            return _buildGridCard(billData[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> item, int index) {
    final colors = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.pink.shade400, Colors.pink.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
    ];
    final gradient = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              setState(() => isCheckingPremium = true);
              final canAdd = await PremiumService().canAddData(
                forceRefresh: true,
              );
              final status = PremiumService().getCachedStatus();
              setState(() {
                isCheckingPremium = false;
                premiumStatus = status;
              });

              if (status != null && status.productId == 2 && !canAdd) {
                PremiumService.showPremiumExpiredDialog(
                  context,
                  customMessage: 'Premium required to edit bills.',
                );
                return;
              }
              if (!canAdd) {
                PremiumService.showPremiumExpiredDialog(
                  context,
                  customMessage: 'Premium required to edit bills.',
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditBill(billNumber: item['billNumber']),
                ),
              ).then((value) {
                if (value == true) {
                  _headerController.reset();
                  _cardController.reset();
                  _loadBillData();
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${item['billNumber']}',
                          style: TextStyle(
                            color: gradient[1],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    item['partyName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    item['date'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '₹${item['amount']}',
                          style: TextStyle(
                            color: gradient[1],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return RotationTransition(
      turns: _fabRotateAnimation,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        elevation: 8,
        onPressed: () async {
          _fabController.forward().then((_) => _fabController.reverse());

          setState(() => isCheckingPremium = true);
          final canAdd = await PremiumService().canAddData(forceRefresh: true);
          final status = PremiumService().getCachedStatus();

          setState(() {
            isCheckingPremium = false;
            premiumStatus = status;
          });

          if (status != null && status.productId == 2 && !canAdd) {
            PremiumService.showPremiumExpiredDialog(
              context,
              customMessage:
                  status.isPremium
                      ? 'Your premium subscription has expired.'
                      : 'Your trial period has ended.\nPlease upgrade to continue.',
            );
            return;
          }

          if (!canAdd) {
            PremiumService.showPremiumExpiredDialog(
              context,
              customMessage:
                  status?.isPremium == true
                      ? 'Your premium subscription has expired.'
                      : 'Your trial period has ended.\nPlease upgrade to continue.',
            );
            return;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBill()),
          );
          if (result == true) {
            _headerController.reset();
            _cardController.reset();
            _loadBillData();
          }
        },
        icon: Icon(Icons.add, color: Colors.white, size: 28),
        label: Text(
          'New Bill',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleGetReceipt(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiptsPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Getting receipt for ${billData[index]['partyName']}',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}
