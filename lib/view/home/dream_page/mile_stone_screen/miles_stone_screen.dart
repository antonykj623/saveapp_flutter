import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MileStone {
  DateTime startDate;
  DateTime endDate;
  double amount;
  bool isEmpty; // Track if this is an empty milestone

  MileStone({
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.isEmpty = false,
  });
}

class AddMileStonePage extends StatefulWidget {
  @override
  _AddMileStonePageState createState() => _AddMileStonePageState();
}

class _AddMileStonePageState extends State<AddMileStonePage> {
  List<MileStone> milestones = [];
  int? selectedMilestoneIndex;
  Set<int> expandedMilestones = {}; // Track which milestones are expanded
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    milestones.add(
      MileStone(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        amount: 0.0,
        isEmpty: true,
      ),
    );
  }

  void _addMilestone(
    int index,
    DateTime? startDate,
    DateTime? endDate,
    String amountText,
  ) {
    if (startDate != null && endDate != null && amountText.isNotEmpty) {
      setState(() {
        if (selectedMilestoneIndex != null) {
          milestones[selectedMilestoneIndex!] = MileStone(
            startDate: startDate,
            endDate: endDate,
            amount: double.tryParse(amountText) ?? 0.0,
            isEmpty: false,
          );
        } else {
          // Add new milestone
          milestones.add(
            MileStone(
              startDate: startDate,
              endDate: endDate,
              amount: double.tryParse(amountText) ?? 0.0,
              isEmpty: false,
            ),
          );
        }

        _resetForm();
      });
    }
  }

  void _deleteMilestone(int index) {
    setState(() {
      if (milestones.length > 1) {
        milestones.removeAt(index);
      } else {
        // If only one milestone, reset it to empty
        milestones[0] = MileStone(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          amount: 0.0,
          isEmpty: true,
        );
      }
      _resetForm();
    });
  }

  void _addMoreMilestone() {
    setState(() {
      milestones.add(
        MileStone(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          amount: 0.0,
          isEmpty: true,
        ),
      );
    });
  }

  void _onMilestoneSelected(int index) {
    setState(() {
      if (expandedMilestones.contains(index)) {
        // Collapse the milestone
        expandedMilestones.remove(index);
        if (selectedMilestoneIndex == index) {
          _resetForm();
        }
      } else {
        expandedMilestones.add(index);
        selectedMilestoneIndex = index;
        final milestone = milestones[index];
        amountController.text =
            milestone.isEmpty ? '' : milestone.amount.toString();
      }
    });
  }

  void _resetForm() {
    setState(() {
      selectedMilestoneIndex = null;
      expandedMilestones.clear();
      amountController.clear();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('d-M-yyyy').format(date);
  }

  String _formatDateDisplay(DateTime date, bool isEmpty) {
    if (isEmpty) {
      return '';
    }
    return DateFormat('d-M-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add MileStone',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                bool isExpanded = expandedMilestones.contains(index);

                // Local state for the form in the expanded section
                DateTime? localStartDate =
                    milestone.isEmpty ? null : milestone.startDate;
                DateTime? localEndDate =
                    milestone.isEmpty ? null : milestone.endDate;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _onMilestoneSelected(index),
                      child: Container(
                        margin: EdgeInsets.only(bottom: isExpanded ? 0 : 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              isExpanded
                                  ? BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  )
                                  : BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start date: ${_formatDateDisplay(milestone.startDate, milestone.isEmpty)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'End date: ${_formatDateDisplay(milestone.endDate, milestone.isEmpty)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Amount: ${milestone.isEmpty ? '0.0' : milestone.amount.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.chevron_right,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: StatefulBuilder(
                          builder: (
                            BuildContext context,
                            StateSetter setFormState,
                          ) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[400]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      localStartDate ??
                                                      DateTime.now(),
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime(2030),
                                                );
                                            if (picked != null &&
                                                picked != localStartDate) {
                                              setFormState(() {
                                                localStartDate = picked;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  localStartDate != null
                                                      ? _formatDate(
                                                        localStartDate!,
                                                      )
                                                      : 'Start date',
                                                  style: TextStyle(
                                                    color:
                                                        localStartDate != null
                                                            ? Colors.black
                                                            : Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey[600],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[400]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            final DateTime? picked =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      localEndDate ??
                                                      DateTime.now(),
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime(2030),
                                                );
                                            if (picked != null &&
                                                picked != localEndDate) {
                                              setFormState(() {
                                                localEndDate = picked;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  localEndDate != null
                                                      ? _formatDate(
                                                        localEndDate!,
                                                      )
                                                      : 'End date',
                                                  style: TextStyle(
                                                    color:
                                                        localEndDate != null
                                                            ? Colors.black
                                                            : Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey[600],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      suffixIcon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed:
                                            () => _addMilestone(
                                              index,
                                              localStartDate,
                                              localEndDate,
                                              amountController.text,
                                            ),
                                        child: Text(
                                          selectedMilestoneIndex != null
                                              ? 'add'
                                              : 'update',
                                          style: TextStyle(
                                            color: Color(0xFF2196F3),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 32),
                                    Expanded(
                                      child: TextButton(
                                        onPressed:
                                            () => _deleteMilestone(index),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Color(0xFFF44336),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _addMoreMilestone,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Color(0xFF2196F3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Add More',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MileStone App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('MileStone App')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AddMileStonePage()),
//             );
//           },
//           child: Text('Add MileStone'),
//         ),
//       ),
//     );
//   }
// }
