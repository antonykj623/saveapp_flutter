import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/Journal/addJournal.dart';
import 'package:new_project_2025/view_model/Journal/Journel_class_model_class.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalPageState();
}

class _JournalPageState extends State<Journal> with TickerProviderStateMixin {
  String selectedYearMonth = DateFormat('MMM/yyyy').format(DateTime.now());
  List<Map<String, dynamic>> journalEntries = [];
  double total = 0;
  bool isLoading = true;
  bool isCheckingPremium = false;
  PremiumStatus? premiumStatus;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkPremiumAndLoadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
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
      _loadJournalEntries();
    } catch (e) {
      setState(() => isCheckingPremium = false);
      _loadJournalEntries();
    }
  }

  Future<void> _loadJournalEntries() async {
    try {
      setState(() => isLoading = true);
      final db = await DatabaseHelper().database;
      final monthYear = selectedYearMonth.split('/');
      final month = monthYear[0].toLowerCase();
      final year = monthYear[1];

      final List<Map<String, dynamic>> debitEntries = await db.query(
        'TABLE_ACCOUNTS',
        where:
            "ACCOUNTS_VoucherType = ? AND ACCOUNTS_month = ? AND ACCOUNTS_year = ? AND ACCOUNTS_type = ?",
        whereArgs: [4, month, year, 'debit'],
      );

      List<Map<String, dynamic>> entries = [];
      for (var debitEntry in debitEntries) {
        final entryId = debitEntry['ACCOUNTS_entryid'];
        final creditEntry = await db.query(
          'TABLE_ACCOUNTS',
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [4, entryId, 'credit'],
        );

        if (creditEntry.isNotEmpty) {
          final debitAccount = await _getAccountName(
            debitEntry['ACCOUNTS_setupid'],
          );
          final creditAccount = await _getAccountName(
            creditEntry.first['ACCOUNTS_setupid'],
          );
          entries.add({
            'entryId': entryId.toString(),
            'date': debitEntry['ACCOUNTS_date'].toString(),
            'debitAccount': debitAccount,
            'creditAccount': creditAccount,
            'amount': debitEntry['ACCOUNTS_amount'].toString(),
            'remarks': debitEntry['ACCOUNTS_remarks']?.toString() ?? "",
          });
        }
      }

      setState(() {
        journalEntries = entries;
        total = _calculateTotal(entries);
        isLoading = false;
      });

      _fadeController.forward();
    } catch (e) {
      print('Error loading journal entries: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<String> _getAccountName(dynamic setupId) async {
    try {
      final db = await DatabaseHelper().database;
      final account = await db.query(
        'TABLE_ACCOUNTSETTINGS',
        where: "keyid = ?",
        whereArgs: [setupId],
      );
      if (account.isNotEmpty) {
        final data = account.first['data'];
        Map<String, dynamic> accountData;
        if (data is String) {
          accountData = jsonDecode(data);
        } else if (data is Map<String, dynamic>) {
          accountData = data;
        } else {
          return 'Unknown';
        }
        return accountData['Accountname']?.toString() ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  double _calculateTotal(List<Map<String, dynamic>> entries) {
    double total = 0;
    for (var entry in entries) {
      total += double.tryParse(entry['amount'].toString()) ?? 0;
    }
    return total;
  }

  void _selectMonthYear() async {
    // ... (keep your existing month/year picker)
    final now = DateTime.now();
    final years = List.generate(
      10,
      (index) => (now.year + index - 5).toString(),
    );
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String selectedMonth = selectedYearMonth.split('/')[0];
    String selectedYear = selectedYearMonth.split('/')[1];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Select Month & Year',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    items:
                        months
                            .map(
                              (month) => DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setStateSB(() => selectedMonth = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedYear,
                    isExpanded: true,
                    items:
                        years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setStateSB(() => selectedYear = value!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(
                      () => selectedYearMonth = '$selectedMonth/$selectedYear',
                    );
                    _loadJournalEntries();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// -- PREMIUM CHECK before ADD/EDIT/DELETE ----------------------------------
  Future<void> _handleAddJournal() async {
    setState(() => isCheckingPremium = true);

    final canAdd = await PremiumService().canAddData(forceRefresh: true);
    final status = PremiumService().getCachedStatus();

    setState(() {
      isCheckingPremium = false;
      premiumStatus = status;
    });

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
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const AddJournal(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
    if (result == true) _loadJournalEntries();
  }

  Future<void> _editItem(int index) async {
    setState(() => isCheckingPremium = true);

    final canAdd = await PremiumService().canAddData(forceRefresh: true);
    final status = PremiumService().getCachedStatus();

    setState(() {
      isCheckingPremium = false;
      premiumStatus = status;
    });

    if (!canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage: 'Premium required to edit journal entries.',
      );
      return;
    }

    // Proceed with edit
    final entry = journalEntries[index];
    final journalEntry = JournalEntry(
      entryId: int.parse(entry['entryId']),
      date: entry['date'],
      debitAccount: entry['debitAccount'],
      creditAccount: entry['creditAccount'],
      amount: double.parse(entry['amount']),
      remarks: entry['remarks'],
    );
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AddJournal(journalEntry: journalEntry),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
    if (result == true) _loadJournalEntries();
  }

  Future<void> _deleteItem(int index) async {
    setState(() => isCheckingPremium = true);

    final canAdd = await PremiumService().canAddData(forceRefresh: true);
    final status = PremiumService().getCachedStatus();

    setState(() {
      isCheckingPremium = false;
      premiumStatus = status;
    });

    if (!canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage: 'Premium required to delete journal entries.',
      );
      return;
    }

    final entryId = journalEntries[index]['entryId'];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Delete Entry',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w800,
              ),
            ),
            content: const Text('Are you sure? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final db = await DatabaseHelper().database;
                    await db.delete(
                      'TABLE_ACCOUNTS',
                      where:
                          "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
                      whereArgs: [4, entryId],
                    );
                    setState(() {
                      journalEntries.removeAt(index);
                      total = _calculateTotal(journalEntries);
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✓ Entry deleted successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: size.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.teal[700]!,
                  Colors.teal[500]!,
                  Colors.cyan[400]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // HEADER ...
                // ... rest of your untouched header and premium banner code ...
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Record transactions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          _slideController.reset();
                          _fadeController.reset();
                          _checkPremiumAndLoadData();
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseController.value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (premiumStatus != null)
                  PremiumService.buildPremiumBanner(
                    context: context,
                    status: premiumStatus!,
                    isChecking: isCheckingPremium,
                    onRefresh: _checkPremiumAndLoadData,
                  ),
                SizedBox(height: size.height * 0.02),

                // Month selector, table, loading/empty state, total, etc.
                // ... keep rest of your unchanged code for UI, with FAB below ...
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: GestureDetector(
                      onTap: _selectMonthYear,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.teal[100]!,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Period',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedYearMonth,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.teal[800],
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal[400]!,
                                    Colors.teal[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _fadeController,
                      curve: Curves.easeInOut,
                    ),
                    child:
                        isLoading || isCheckingPremium
                            ? _buildLoadingState()
                            : journalEntries.isEmpty
                            ? _buildEmptyState()
                            : _buildJournalTable(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[50]!, Colors.cyan[50]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.teal[100]!, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal[700],
                        ),
                      ),
                    ],
                  ),
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
                        valueColor: AlwaysStoppedAnimation(Colors.teal),
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.purple[600]),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isCheckingPremium ? 'Checking Access...' : 'Loading Entries...',
            style: TextStyle(
              color: Colors.purple[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[100]!, Colors.pink[100]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 50,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Entries Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first journal entry\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      ),
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth * 0.92),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[600]!, Colors.teal[500]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(screenWidth * 0.20),
                    1: FixedColumnWidth(screenWidth * 0.18),
                    2: FixedColumnWidth(screenWidth * 0.18),
                    3: FixedColumnWidth(screenWidth * 0.18),
                    4: FixedColumnWidth(screenWidth * 0.18),
                  },
                  children: [
                    TableRow(
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(screenWidth * 0.20),
                    1: FixedColumnWidth(screenWidth * 0.18),
                    2: FixedColumnWidth(screenWidth * 0.18),
                    3: FixedColumnWidth(screenWidth * 0.18),
                    4: FixedColumnWidth(screenWidth * 0.18),
                  },
                  children:
                      journalEntries.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        return TableRow(
                          decoration: BoxDecoration(
                            color:
                                index % 2 == 0
                                    ? Colors.white
                                    : Colors.purple[50],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.purple[100]!,
                                width: 1,
                              ),
                            ),
                          ),
                          children: [
                            _buildTableDataCell(
                              _formatDisplayDate(item['date']),
                              isBold: true,
                            ),
                            _buildTableDataCell(item['debitAccount']),
                            _buildTableDataCellAmount('₹${item['amount']}'),
                            _buildTableDataCell(item['creditAccount']),
                            _buildTableActionCell(index),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDisplayDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d/M/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableDataCell(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTableDataCellAmount(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[400]!, Colors.purple[600]!],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildTableActionCell(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _editItem(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 12),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _deleteItem(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// FAB respects premium/trial/sales (locked if !active)
  Widget _buildFAB() {
    final status = premiumStatus;
    final isActive = status?.isActive ?? false;
    return isActive
        ? AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (_pulseController.value * 0.1),
              child: FloatingActionButton(
                onPressed: _handleAddJournal,
                backgroundColor: Colors.transparent,
                elevation: 8,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[600]!, Colors.cyan[500]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        )
        : FloatingActionButton(
          backgroundColor: Colors.grey[400],
          onPressed:
              () => PremiumService.showPremiumExpiredDialog(
                context,
                customMessage:
                    status?.isPremium == true
                        ? 'Your premium subscription has expired.'
                        : 'Your trial period has ended.\nPlease upgrade to continue.',
              ),
          child: const Icon(Icons.lock),
        );
  }
}
