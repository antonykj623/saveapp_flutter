import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_project_2025/view/home/dream_page/mile_stone_screen/miles_stone_screen.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';

class AddDreamScreen extends StatefulWidget {
  final Function(Dream) onDreamAdded;
  final Function(Dream)? onDreamUpdated;
  final Dream? dream;

  AddDreamScreen({required this.onDreamAdded, this.onDreamUpdated, this.dream});

  @override
  _AddDreamScreenState createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedTarget;
  String targetName = '';
  double targetAmount = 0.0;
  String? selectedInvestment;
  double savedAmount = 0.0;
  DateTime? selectedDate;
  String notes = '';

  final List<Map<String, dynamic>> targetCategories = [
    {'name': 'Vehicle', 'icon': Icons.directions_car},
    {'name': 'New home', 'icon': Icons.home},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Emergency', 'icon': Icons.local_hospital},
    {'name': 'Healthcare', 'icon': Icons.health_and_safety},
    {'name': 'Party', 'icon': Icons.celebration},
    {'name': 'Charity', 'icon': Icons.volunteer_activism},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.dream != null) {
      selectedTarget = widget.dream!.category;
      targetName = widget.dream!.name;
      targetAmount = widget.dream!.targetAmount;
      selectedInvestment = widget.dream!.investment;
      savedAmount = widget.dream!.savedAmount;
      selectedDate = widget.dream!.targetDate;
      notes = widget.dream!.notes;
    }
  }

  IconData? _getSelectedIcon() {
    final category = targetCategories.firstWhere(
      (cat) => cat['name'] == selectedTarget,
      orElse: () => {'icon': Icons.help_outline},
    );
    return category['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.dream == null ? 'Add Dream' : 'Edit Dream',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // TARGET SELECTION BUTTON - REPLACED DROPDOWN
              GestureDetector(
                onTap: _showTargetCategoriesDialog,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      if (selectedTarget != null) ...[
                        Icon(_getSelectedIcon(), color: Colors.teal, size: 24),
                        SizedBox(width: 10),
                        Text(selectedTarget!, style: TextStyle(fontSize: 16)),
                      ] else ...[
                        Text(
                          'Select Target',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      Spacer(),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: targetName,
                decoration: InputDecoration(
                  hintText: 'Target Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => targetName = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Target Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'target'),
                readOnly: true,
                controller: TextEditingController(
                  text: targetAmount > 0 ? targetAmount.toString() : '',
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedInvestment,
                    hint: Text('Select Investment'),
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedInvestment = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'My Saving',
                        child: Text('My Saving'),
                      ),
                      DropdownMenuItem(
                        value: 'Fixed Deposit',
                        child: Text('Fixed Deposit'),
                      ),
                      DropdownMenuItem(
                        value: 'Mutual Fund',
                        child: Text('Mutual Fund'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Saved Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'saved'),
                readOnly: true,
                controller: TextEditingController(
                  text: savedAmount > 0 ? savedAmount.toString() : '',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Select Target Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text:
                      selectedDate != null
                          ? '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                          : '',
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMileStonePage(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add MileStone'),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: notes,
                decoration: InputDecoration(
                  hintText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => notes = value,
              ),
              Spacer(),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedTarget == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a target category'),
                        ),
                      );
                      return;
                    }

                    final updatedDream = Dream(
                      name: targetName,
                      category: selectedTarget!,
                      investment: selectedInvestment ?? 'My Saving',
                      targetAmount: targetAmount,
                      savedAmount: savedAmount,
                      targetDate: selectedDate ?? DateTime.now(),
                      notes: notes,
                    );

                    if (widget.dream == null) {
                      widget.onDreamAdded(updatedDream);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dream added successfully!')),
                      );
                    } else {
                      widget.onDreamUpdated?.call(updatedDream);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dream updated successfully!')),
                      );
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    widget.dream == null ? 'Add' : 'Update',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTargetCategoriesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Target Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: targetCategories.length,
                  itemBuilder: (context, index) {
                    final category = targetCategories[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTarget = category['name'];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              selectedTarget == category['name']
                                  ? Colors.teal.withOpacity(0.2)
                                  : Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              selectedTarget == category['name']
                                  ? Border.all(color: Colors.teal, width: 2)
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              size: 32,
                              color: Colors.teal,
                            ),
                            SizedBox(height: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCalculator(BuildContext context, String type) {
    String currentValue = '';
    String firstNumber = '';
    String operator = '';
    String displayExpression = '';
    bool isOperatorPressed = false;
    bool showResult = false;

    List<List<String>> buttonRows = [
      ['1', '2', '3', '/'],
      ['4', '5', '6', '-'],
      ['7', '8', '9', 'X'],
      ['.', '0', '%', '+'],
      ['DEL', '='],
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (displayExpression.isNotEmpty)
                            Text(
                              displayExpression,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          SizedBox(height: 4),
                          Text(
                            currentValue.isEmpty ? '0' : currentValue,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  showResult
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ...buttonRows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              row.map((buttonText) {
                                bool isOperator = [
                                  '/',
                                  '-',
                                  'X',
                                  '+',
                                  '=',
                                  'DEL',
                                  '%',
                                ].contains(buttonText);
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (buttonText == 'DEL') {
                                            if (showResult) {
                                              currentValue = '';
                                              displayExpression = '';
                                              firstNumber = '';
                                              operator = '';
                                              isOperatorPressed = false;
                                              showResult = false;
                                            } else if (currentValue
                                                .isNotEmpty) {
                                              currentValue = currentValue
                                                  .substring(
                                                    0,
                                                    currentValue.length - 1,
                                                  );
                                            }
                                          } else if (buttonText == '=') {
                                            if (firstNumber.isNotEmpty &&
                                                operator.isNotEmpty &&
                                                currentValue.isNotEmpty) {
                                              try {
                                                double num1 = double.parse(
                                                  firstNumber,
                                                );
                                                double num2 = double.parse(
                                                  currentValue,
                                                );
                                                double result = 0;

                                                displayExpression =
                                                    '$firstNumber $operator $currentValue =';

                                                switch (operator) {
                                                  case '+':
                                                    result = num1 + num2;
                                                    break;
                                                  case '-':
                                                    result = num1 - num2;
                                                    break;
                                                  case 'X':
                                                    result = num1 * num2;
                                                    break;
                                                  case '/':
                                                    result =
                                                        num2 != 0
                                                            ? num1 / num2
                                                            : 0;
                                                    break;
                                                  case '%':
                                                    result =
                                                        num1 * (num2 / 100);
                                                    break;
                                                }

                                                currentValue = result
                                                    .toStringAsFixed(2)
                                                    .replaceAll(
                                                      RegExp(r'\.?0*$'),
                                                      '',
                                                    );
                                                showResult = true;
                                                firstNumber = '';
                                                operator = '';
                                                isOperatorPressed = false;
                                              } catch (e) {
                                                currentValue = 'Error';
                                                displayExpression = '';
                                                showResult = true;
                                              }
                                            }
                                          } else if (isOperator &&
                                              buttonText != '=') {
                                            if (showResult) {
                                              firstNumber = currentValue;
                                              operator = buttonText;
                                              displayExpression =
                                                  '$currentValue $buttonText';
                                              currentValue = '';
                                              isOperatorPressed = true;
                                              showResult = false;
                                            } else if (currentValue
                                                    .isNotEmpty &&
                                                !isOperatorPressed) {
                                              firstNumber = currentValue;
                                              operator = buttonText;
                                              displayExpression =
                                                  '$currentValue $buttonText';
                                              currentValue = '';
                                              isOperatorPressed = true;
                                            }
                                          } else {
                                            if (showResult) {
                                              currentValue = buttonText;
                                              displayExpression = '';
                                              firstNumber = '';
                                              operator = '';
                                              isOperatorPressed = false;
                                              showResult = false;
                                            } else {
                                              currentValue += buttonText;
                                              isOperatorPressed = false;
                                            }
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isOperator
                                                ? Colors.grey[400]
                                                : Colors.grey[300],
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        buttonText,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    }),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[900]!, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          double value = double.tryParse(currentValue) ?? 0.0;
                          if (type == 'target') {
                            this.setState(() {
                              targetAmount = value;
                            });
                          } else if (type == 'saved') {
                            this.setState(() {
                              savedAmount = value;
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          'INSERT',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
