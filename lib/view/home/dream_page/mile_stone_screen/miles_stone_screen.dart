import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../widget/save_DB/Budegt_database_helper/Save_DB.dart'; // Adjust path as needed

// Updated MileStone class with target reference
class MileStone {
  DateTime startDate;
  DateTime endDate;
  double amount;
  bool isEmpty;
  int? id;
  int? targetId; // Add target reference

  MileStone({
    this.id,
    this.targetId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.isEmpty = false,
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'amount': amount,
    'isEmpty': isEmpty,
    'targetId': targetId,
  };

  factory MileStone.fromJson(Map<String, dynamic> json, {int? id}) => MileStone(
    id: id,
    targetId: json['targetId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    amount: json['amount'],
    isEmpty: json['isEmpty'] ?? false,
  );
}

class AddMileStonePage extends StatefulWidget {
  final int targetId; // Required targetId to associate milestones with a dream

  const AddMileStonePage({required this.targetId, super.key});

  @override
  _AddMileStonePageState createState() => _AddMileStonePageState();
}

class _AddMileStonePageState extends State<AddMileStonePage> {
  List<MileStone> milestones = [];
  int? selectedMilestoneIndex;
  Set<int> expandedMilestones = {};
  TextEditingController amountController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedMilestones = await _dbHelper.getMilestonesByTargetId(
        widget.targetId,
      );
      setState(() {
        milestones = loadedMilestones;
        // Sort milestones by start date
        milestones.sort((a, b) => a.startDate.compareTo(b.startDate));
        // Add empty milestone if none exist
        if (milestones.isEmpty) {
          milestones.add(
            MileStone(
              targetId: widget.targetId,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              amount: 0.0,
              isEmpty: true,
            ),
          );
        }
      });
    } catch (e) {
      print('Error loading milestones for target ${widget.targetId}: $e');
      setState(() {
        milestones = [
          MileStone(
            targetId: widget.targetId,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            amount: 0.0,
            isEmpty: true,
          ),
        ];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addMilestone(
    int index,
    DateTime? startDate,
    DateTime? endDate,
    String amountText,
  ) async {
    // Validation checks
    if (startDate == null || endDate == null || amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (startDate.isAtSameMomentAs(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start and end dates cannot be the same')),
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Check for date conflicts
    if (_hasDateConflict(startDate, endDate, index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date range conflicts with existing milestone'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      MileStone milestone = MileStone(
        targetId: widget.targetId,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
        isEmpty: false,
      );

      if (selectedMilestoneIndex != null && selectedMilestoneIndex == index) {
        // Update existing milestone
        milestone.id = milestones[index].id;
        if (milestone.id != null) {
          await _dbHelper.updateMilestone(milestone);
        } else {
          // If no ID exists, insert as new
          final newId = await _dbHelper.insertMilestone(
            milestone,
            widget.targetId,
          );
          milestone.id = newId;
        }
        setState(() {
          milestones[index] = milestone;
          _resetForm();
        });
      } else {
        // Add new milestone
        final newId = await _dbHelper.insertMilestone(
          milestone,
          widget.targetId,
        );
        milestone.id = newId;
        setState(() {
          if (milestones[index].isEmpty) {
            milestones[index] = milestone;
          } else {
            milestones.insert(index + 1, milestone);
          }
          _resetForm();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Milestone saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving milestone: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteMilestone(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Milestone'),
            content: const Text(
              'Are you sure you want to delete this milestone?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (milestones[index].id != null) {
        await _dbHelper.deleteData('TABLE_MILESTONE', milestones[index].id!);
      }

      setState(() {
        if (milestones.length > 1) {
          milestones.removeAt(index);
        } else {
          milestones[0] = MileStone(
            targetId: widget.targetId,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            amount: 0.0,
            isEmpty: true,
          );
        }
        _resetForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Milestone deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting milestone: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addMoreMilestone() {
    setState(() {
      DateTime latestEndDate = DateTime.now();
      final nonEmptyMilestones = milestones.where((m) => !m.isEmpty).toList();
      if (nonEmptyMilestones.isNotEmpty) {
        latestEndDate = nonEmptyMilestones
            .map((m) => m.endDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }
      DateTime newStartDate = latestEndDate.add(const Duration(days: 1));

      milestones.add(
        MileStone(
          targetId: widget.targetId,
          startDate: newStartDate,
          endDate: newStartDate,
          amount: 0.0,
          isEmpty: true,
        ),
      );
    });
  }

  void _onMilestoneSelected(int index) {
    setState(() {
      if (expandedMilestones.contains(index)) {
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

  bool _hasDateConflict(
    DateTime startDate,
    DateTime endDate,
    int currentIndex,
  ) {
    for (int i = 0; i < milestones.length; i++) {
      if (i == currentIndex || milestones[i].isEmpty) continue;
      MileStone existing = milestones[i];
      bool overlaps =
          (startDate.isBefore(existing.endDate) ||
              startDate.isAtSameMomentAs(existing.endDate)) &&
          (endDate.isAfter(existing.startDate) ||
              endDate.isAtSameMomentAs(existing.startDate));
      if (overlaps) return true;
    }
    return false;
  }

  String _formatDate(DateTime date) {
    return DateFormat('d-M-yyyy').format(date);
  }

  String _formatDateDisplay(DateTime date, bool isEmpty) {
    if (isEmpty) return '';
    return DateFormat('d-M-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add MileStone',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = milestones[index];
                    bool isExpanded = expandedMilestones.contains(index);
                    DateTime? localStartDate =
                        milestone.isEmpty ? null : milestone.startDate;
                    DateTime? localEndDate =
                        milestone.isEmpty ? null : milestone.endDate;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _onMilestoneSelected(index),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: isExpanded ? 0 : 16,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  isExpanded
                                      ? const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      )
                                      : BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start date: ${_formatDateDisplay(milestone.startDate, milestone.isEmpty)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'End date: ${_formatDateDisplay(milestone.endDate, milestone.isEmpty)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
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
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                            localStartDate !=
                                                                    null
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[600],
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
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey[400]!,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                                : Colors
                                                                    .grey[600],
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
                                    const SizedBox(height: 16),
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
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                          suffixIcon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed:
                                                isLoading
                                                    ? null
                                                    : () => _addMilestone(
                                                      index,
                                                      localStartDate,
                                                      localEndDate,
                                                      amountController.text,
                                                    ),
                                            child: Text(
                                              selectedMilestoneIndex != null
                                                  ? 'Update'
                                                  : 'Add',
                                              style: const TextStyle(
                                                color: Color(0xFF2196F3),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          child: TextButton(
                                            onPressed:
                                                isLoading
                                                    ? null
                                                    : () =>
                                                        _deleteMilestone(index),
                                            child: const Text(
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _addMoreMilestone,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
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
