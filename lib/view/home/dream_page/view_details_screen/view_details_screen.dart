import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/dream_page/add_dream_screen/add_dream_screen.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';
import 'package:new_project_2025/view/home/dream_page/view_miles_stone/view_mile_stone.dart';

import '../../widget/save_DB/Budegt_database_helper/Save_DB.dart';

class ViewDetailsScreen extends StatefulWidget {
  final Dream dream;
  final Function(Dream)? onDreamUpdated;

     
  const ViewDetailsScreen({
    required this.dream,
    this.onDreamUpdated,
    super.key,
  });

  @override
  _ViewDetailsScreenState createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  late Dream dream;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    dream = widget.dream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'View Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddDreamScreen(
                        onDreamAdded: (newDream) {}, // Not used for editing
                        onDreamUpdated: (updatedDream) async {
                          try {
                            final result = await _dbHelper.updateDream(
                              dream.id!,
                              updatedDream,
                            );
                            if (result > 0) {
                              setState(() {
                                dream = updatedDream;
                              });
                              widget.onDreamUpdated?.call(updatedDream);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dream updated successfully!'),
                                ),
                              );
                            } else {
                              throw Exception('Failed to update dream');
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update dream: $e'),
                              ),
                            );
                          }
                        },
                        dream: dream,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 32,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dream.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Name', dream.name),
                    _buildDetailRow(
                      'Target Date',
                      '${dream.targetDate.day}-${dream.targetDate.month}-${dream.targetDate.year}',
                    ),
                    _buildDetailRow(
                      'Target Amount',
                      dream.targetAmount.toStringAsFixed(2),
                    ),
                    _buildDetailRow('Investment Account', dream.investment),
                    _buildDetailRow(
                      'Closing Balance',
                      dream.closingBalance.toStringAsFixed(2),
                    ),
                    _buildDetailRow(
                      'Total Added Amount',
                      dream.addedAmount.toStringAsFixed(2),
                    ),
                    _buildDetailRow(
                      'Saved Amount',
                      dream.savedAmount.toStringAsFixed(2),
                    ),
                    _buildDetailRow('Notes', dream.notes),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: dream.progressPercentage / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.teal,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dream.progressPercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dream.savedAmount.toInt()} / ${dream.targetAmount.toInt()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCalculator(context, 'saved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Amount',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMilestonesPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'View Milestone',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showGoalReachedDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Set as Goal Reached',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          const Text(':', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
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
                      padding: const EdgeInsets.all(16),
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
                          const SizedBox(height: 4),
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
                    const SizedBox(height: 16),
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
                                        padding: const EdgeInsets.symmetric(
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
                                        style: const TextStyle(
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
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          double value = double.tryParse(currentValue) ?? 0.0;
                          if (type == 'saved') {
                            try {
                              final updatedDream = Dream(
                                id: dream.id,
                                name: dream.name,
                                category: dream.category,
                                investment: dream.investment,
                                targetAmount: dream.targetAmount,
                                savedAmount: dream.savedAmount + value,
                                targetDate: dream.targetDate,
                                notes: dream.notes,
                                closingBalance: dream.closingBalance,
                                addedAmount: dream.addedAmount + value,
                              );
                              final result = await _dbHelper.updateDream(
                                dream.id!,
                                updatedDream,
                              );
                              if (result > 0) {
                                setState(() {
                                  dream = updatedDream;
                                });
                                widget.onDreamUpdated?.call(updatedDream);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Amount added successfully!'),
                                  ),
                                );
                              } else {
                                throw Exception('Failed to update dream');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add amount: $e'),
                                ),
                              );
                            }
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
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

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text(
            'Are you sure you want to mark this goal as reached?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Optionally update the dream to mark it as reached (add a flag in the Dream model if needed)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal marked as reached!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark goal as reached: $e'),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
