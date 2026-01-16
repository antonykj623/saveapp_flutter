import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';

import '../../model/receipt.dart';
import '../../services/dbhelper/DatabaseHelper.dart';
import '../../services/dbhelper/dbhelper.dart';

import 'package:intl/intl.dart';

import 'addDiary.dart';

// Import the PremiumService

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<Diary> {
  bool _showContainer = false;

  var dropdownvalu = 'OneTime';
  var items1 = [
    'OneTime',
    'Daily',
    'Monthly',
    'Weekly',
    'Quarterly',
    'Half Yearly',
    'Yearly',
  ];
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();

  List<Receipt> receipts = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  // Premium status variables
  bool _isCheckingPremium = true;
  PremiumStatus? _premiumStatus;
  final PremiumService _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _checkPremiumAndLoad();
  }

  // Check premium status on page load
  Future<void> _checkPremiumAndLoad() async {
    setState(() {
      _isCheckingPremium = true;
    });

    try {
      final status = await _premiumService.checkPremiumStatus(
        forceRefresh: true,
      );
      setState(() {
        _premiumStatus = status;
        _isCheckingPremium = false;
      });

      if (status.isActive) {
        _loadReceipts();
      } else {
        // Show premium expired dialog
        if (mounted) {
          PremiumService.showPremiumExpiredDialog(
            context,
            customMessage:
                'Your access has expired. Please upgrade to access Diary features.',
            onUpgrade: () {
              // Navigate to upgrade page or show upgrade options
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UpgradePage()));
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _isCheckingPremium = false;
      });
    }
  }

  // Check premium before adding new diary
  Future<void> _checkPremiumBeforeAdd() async {
    final canAdd = await _premiumService.canAddData(forceRefresh: true);

    if (canAdd) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddDiary()),
        );
      }
    } else {
      if (mounted) {
        PremiumService.showPremiumExpiredDialog(
          context,
          customMessage:
              'Premium access required to add diary entries. Please upgrade to continue.',
          onUpgrade: () {
            // Navigate to upgrade page
          },
        );
      }
    }
  }

  void _showContentDialog() {
    // Check premium before showing content
    if (_premiumStatus?.isActive != true) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage: 'Premium access required to view diary entries.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: SizedBox(
            height: 700,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text(
                    "01-05-2025\n\nMy Subject\n\nygsudjbfjugfgh\nfhfghfhgfghfgghas\nbdufusdshdbjhbd",
                  ),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Edit"),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  toggleView() {
    setState(() {
      if (_showContainer) {
        _showContainer = false;
      } else {
        _showContainer = true;
      }
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _loadReceipts() async {
    // Only load if premium is active
    if (_premiumStatus?.isActive != true) {
      return;
    }
    // final receiptsList = await DatabaseHelper1.instance.getReceiptsByMonth(
    //   DateFormat('yyyy-MM-dd').format(selectedDate),
    // );
    // setState(() {
    //   receipts = receiptsList;
    //   total = receipts.fold(0, (sum, receipt) => sum + receipt.amount);
    // });
  }

  void showMonthYearPicker(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          if (isStart) {
            selected_startDate = pickedDate;
          } else {
            selected_endDate = pickedDate;
          }
        });
      }
    });
  }

  selectDate(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  String _getDisplayMonth() {
    final parts = selectedYearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat(
      'MMMM',
    ).format(DateTime(int.parse(year), month));
    return '$monthName $year';
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
        title: const Text('Diary', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Premium Status Banner
          if (_premiumStatus != null)
            PremiumService.buildPremiumBanner(
              context: context,
              status: _premiumStatus!,
              isChecking: _isCheckingPremium,
              onRefresh: () => _checkPremiumAndLoad(),
            ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 60,
                  child: InkWell(
                    onTap: () {
                      selectDate(true);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayStartDate(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 60,
                  child: InkWell(
                    onTap: () {
                      selectDate(false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getDisplayEndDate(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    value: dropdownvalu,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:
                        items1.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Center(child: Text(items)),
                          );
                        }).toList(),
                    onChanged: (String? newValue2) {
                      setState(() {
                        dropdownvalu = newValue2!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _loadReceipts();
            },
            child: const Text("Search"),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: (!_showContainer) ? 70 : 150,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text("This view was toggled!"),
                              ),
                              flex: 3,
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.download,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      (!_showContainer)
                                          ? Icons.arrow_drop_down
                                          : Icons.arrow_drop_up,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      toggleView();
                                    },
                                  ),
                                ],
                              ),
                              flex: 2,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        (_showContainer)
                            ? GestureDetector(
                              onTap: _showContentDialog,
                              child: Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.book,
                                      color: Colors.black,
                                      size: 50,
                                    ),
                                    Text(
                                      "01-05-2025\nMy Subject\nygsudjbfjugfghfhfghfhgfghfgghas\nbdufusdshdbjhbd",
                                    ),
                                  ],
                                ),
                                flex: 3,
                              ),
                            )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0, left: 300),
            child: Container(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Add Diary',
                shape: const CircleBorder(),
                onPressed: _checkPremiumBeforeAdd, // Premium check before add
                child: const Icon(Icons.add, color: Colors.white, size: 25),
              ),
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
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.black, style: BorderStyle.solid),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
