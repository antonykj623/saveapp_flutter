// ViewDetailsScreen
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:new_project_2025/view/home/dream_page/add_dream_screen/add_dream_screen.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';

class ViewDetailsScreen extends StatefulWidget {
  final Dream dream;
  final Function(Dream)? onDreamUpdated; // Callback for updating the dream

  ViewDetailsScreen({required this.dream, this.onDreamUpdated});

  @override
  _ViewDetailsScreenState createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  late Dream dream;
  final _formKey = GlobalKey<FormState>();
  String? selectedTarget;
  String targetName = '';
  double targetAmount = 0.0;
  String? selectedInvestment;
  double savedAmount = 0.0;
  DateTime? selectedDate;
  String notes = '';

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
        title: Text('View Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddDreamScreen(
                        onDreamAdded: (newDream) {}, // Not used for editing
                        onDreamUpdated: (updatedDream) {
                          setState(() {
                            dream = updatedDream; // Update local dream
                          });
                          widget.onDreamUpdated?.call(
                            updatedDream,
                          ); // Notify parent
                        },
                        dream: dream, // Pass current dream for editing
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 32,
                          color: Colors.teal,
                        ),
                        SizedBox(width: 12),
                        Text(
                          dream.category,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow('Name', dream.name),
                    _buildDetailRow(
                      'Target Date',
                      '${dream.targetDate.day}-${dream.targetDate.month}-${dream.targetDate.year}',
                    ),
                    _buildDetailRow(
                      'Target Amount',
                      dream.targetAmount.toString(),
                    ),
                    _buildDetailRow('Investment Account', dream.investment),
                    _buildDetailRow(
                      'Closing balance',
                      dream.closingBalance.toString(),
                    ),
                    _buildDetailRow(
                      'Total Added Amount',
                      dream.addedAmount.toString(),
                    ),
                    _buildDetailRow(
                      'Saved Amount',
                      dream.savedAmount.toString(),
                    ),
                    _buildDetailRow('Notes', dream.notes),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Progress Circle
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dream.progressPercentage.toStringAsFixed(2)} %',
                        style: TextStyle(
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
            SizedBox(height: 30),
            // Action Buttons
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCalculator(context, "Target"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Add Amount',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // View Milestone functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'View Milestone',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showGoalReachedDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 14))),
          Text(':', style: TextStyle(fontSize: 14)),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('Are you sure you want to mark this goal as reached?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Goal marked as reached!')),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
