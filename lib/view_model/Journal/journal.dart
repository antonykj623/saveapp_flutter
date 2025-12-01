import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/Journal/addJournal.dart';
import 'package:new_project_2025/view_model/Journal/Journel_class_model_class.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.pink,
        ),
      ),
      home: const Journal(),
    );
  }
}

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalPageState();
}

class _JournalPageState extends State<Journal> {
  String selectedYearMonth = DateFormat('MMM/yyyy').format(DateTime.now());
  List<Map<String, dynamic>> journalEntries = [];
  double total = 0;
  bool isLoading = true;
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries() async {
    try {
      setState(() {
        isLoading = true;
      });

      final db = await DatabaseHelper().database;
      final monthYear = selectedYearMonth.split('/');
      final month = monthYear[0].toLowerCase();
      final year = monthYear[1];

      // Fetch journal entries with VoucherType = 4 (corrected from 3)
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
    } catch (e) {
      print('Error loading journal entries: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading journal entries: $e')),
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
      print('Error fetching account name: $e');
      return 'Unknown';
    }
  }

  void _selectMonthYear() async {
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
              title: const Text('Select Month and Year'),
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
                    onChanged: (value) {
                      setStateSB(() {
                        selectedMonth = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
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
                    onChanged: (value) {
                      setStateSB(() {
                        selectedYear = value!;
                      });
                    },
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
                    setState(() {
                      selectedYearMonth = '$selectedMonth/$selectedYear';
                    });
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

  double _calculateTotal(List<Map<String, dynamic>> entries) {
    double total = 0;
    for (var entry in entries) {
      total += double.tryParse(entry['amount'].toString()) ?? 0;
    }
    return total;
  }

  void _editItem(int index) async {
    final entry = journalEntries[index];

    // Create JournalEntry object for editing
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
      MaterialPageRoute(
        builder: (context) => AddJournal(journalEntry: journalEntry),
      ),
    );

    if (result == true) {
      _loadJournalEntries();
    }
  }

  void _deleteItem(int index) async {
    final entryId = journalEntries[index]['entryId'];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this journal entry?',
            ),
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
                      whereArgs: [4, entryId], // Changed to VoucherType 4
                    );
                    setState(() {
                      journalEntries.removeAt(index);
                      total = _calculateTotal(journalEntries);
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Journal entry deleted successfully'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error deleting journal entry: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting journal entry: $e'),
                        ),
                      );
                    }
                  }
                  Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Journal', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadJournalEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Month/Year Picker
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: _selectMonthYear,
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
                      selectedYearMonth,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
          ),
          // Table Section
          Expanded(
            child:
                isLoading
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
                            'Loading Journal Entries...',
                            style: TextStyle(
                              color: Colors.teal[800],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : journalEntries.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 80,
                            color: Colors.teal[200],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No journal entries found for $selectedYearMonth',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.teal[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new journal entry to get started!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Table Header - Only show when there is data
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              border: const Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildHeaderCell('Date', flex: 4),
                                _buildHeaderCell('Debit', flex: 3),
                                _buildHeaderCell('Amount', flex: 2),
                                _buildHeaderCell('Credit', flex: 3),
                                _buildHeaderCell('Actions', flex: 3),
                              ],
                            ),
                          ),
                          // Table Body
                          Expanded(
                            child: ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: journalEntries.length,
                              itemBuilder: (context, index) {
                                final item = journalEntries[index];
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(item['date'], flex: 4),
                                      _buildDataCell(
                                        item['debitAccount'],
                                        flex: 3,
                                      ),
                                      _buildDataCell(
                                        '₹${item['amount']}',
                                        flex: 2,
                                      ),
                                      _buildDataCell(
                                        item['creditAccount'],
                                        flex: 3,
                                      ),
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
          // Total Section and Add Button
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
                  '₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 25),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddJournal(),
                      ),
                    );
                    if (result == true) {
                      _loadJournalEntries();
                    }
                  },
                  tooltip: 'Add Journal',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
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
        decoration: const BoxDecoration(
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
        constraints: const BoxConstraints(minHeight: 80),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildActionCell(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
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
}
