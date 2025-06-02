import 'package:flutter/material.dart';

class ViewMilestonesPage extends StatefulWidget {
  @override
  _ViewMilestonesPageState createState() => _ViewMilestonesPageState();
}

class _ViewMilestonesPageState extends State<ViewMilestonesPage> {
  List<Milestone> milestones = [
    Milestone(
      startDate: DateTime(2025, 5, 31),
      endDate: DateTime(2025, 6, 28),
      amount: 600.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'View Milestones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Handle save action
            },
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
                return MilestoneCard(
                  milestone: milestones[index],
                  onEdit: () => _showMilestoneDialog(context, milestones[index]),
                  onDelete: () => _deleteMilestone(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMilestoneDialog(context, null),
        backgroundColor: Color(0xFFE91E63),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showMilestoneDialog(BuildContext context, Milestone? milestone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MilestoneDialog(
          milestone: milestone,
          onSave: (newMilestone) {
            setState(() {
              if (milestone == null) {
                milestones.add(newMilestone);
              } else {
                int index = milestones.indexOf(milestone);
                milestones[index] = newMilestone;
              }
            });
          },
        );
      },
    );
  }

  void _deleteMilestone(int index) {
    setState(() {
      milestones.removeAt(index);
    });
  }
}

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MilestoneCard({
    Key? key,
    required this.milestone,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Start Date:', _formatDate(milestone.startDate)),
          SizedBox(height: 16),
          _buildRow('End Date:', _formatDate(milestone.endDate), showArrow: true),
          SizedBox(height: 16),
          _buildRow('Amount:', milestone.amount.toString()),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDelete,
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Color(0xFFE57373),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool showArrow = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (showArrow)
          Icon(
            Icons.chevron_right,
            color: Colors.grey[600],
            size: 20,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}

class MilestoneDialog extends StatefulWidget {
  final Milestone? milestone;
  final Function(Milestone) onSave;

  const MilestoneDialog({
    Key? key,
    this.milestone,
    required this.onSave,
  }) : super(key: key);

  @override
  _MilestoneDialogState createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _amountController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.milestone?.startDate;
    _endDate = widget.milestone?.endDate;
    
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );
    _amountController = TextEditingController(
      text: widget.milestone?.amount.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDateField(
              controller: _startDateController,
              hintText: 'Start date',
              onTap: () => _selectDate(context, true),
            ),
            SizedBox(height: 16),
            _buildDateField(
              controller: _endDateController,
              hintText: 'End date',
              onTap: () => _selectDate(context, false),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _amountController,
              hintText: 'Amount',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saveMilestone,
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey[600],
          size: 20,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00897B)),
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00897B)),
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00897B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  void _saveMilestone() {
    if (_startDate != null && _endDate != null && _amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        final milestone = Milestone(
          startDate: _startDate!,
          endDate: _endDate!,
          amount: amount,
        );
        widget.onSave(milestone);
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}

class Milestone {
  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  Milestone({
    required this.startDate,
    required this.endDate,
    required this.amount,
  });
}