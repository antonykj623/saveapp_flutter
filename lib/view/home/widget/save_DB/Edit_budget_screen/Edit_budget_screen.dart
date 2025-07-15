import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/budget_class/budget_class.dart';

class EditBudgetScreen extends StatefulWidget {
  final BudgetClass budget;
  final VoidCallback onUpdate;

  EditBudgetScreen({required this.budget, required this.onUpdate});

  @override
  _EditBudgetScreenState createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _amountController = TextEditingController();

  String? selectedAccount;
  int selectedYear = 2025;
  List<String> accountNames = [
    'Agriculture Expenses',
    'Accounts for Children',
    'Household Expenses',
    'Transportation',
    'Healthcare',
    'Education',
    'Savings',
    'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    selectedAccount = widget.budget.accountName;
    selectedYear = widget.budget.year;
    _amountController.text = widget.budget.amount.toString();
    _loadAccountNames();
  }

  Future<void> _loadAccountNames() async {
    final accounts = await _dbHelper.getAccountNames();
    setState(() {
      accountNames = accounts.isNotEmpty ? accounts : accountNames;
      if (!accountNames.contains(selectedAccount)) {
        selectedAccount = accountNames.isNotEmpty ? accountNames.first : null;
      }
    });
  }

  Future<void> _updateBudget() async {
    if (_amountController.text.isEmpty || selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount and select an account')),
      );
      return;
    }

    double? amount;
    try {
      amount = double.parse(_amountController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    await _dbHelper.updateBudget(widget.budget.id!, {
      'account_name': selectedAccount!,
      'year': selectedYear,
      'month': widget.budget.month,
      'amount': amount,
    });

    widget.onUpdate();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget updated successfully')),
    );
  }

  Future<void> _deleteBudget() async {
    await _dbHelper.deleteBudget(widget.budget.id!);
    widget.onUpdate();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Budget deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Budget', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteBudget,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedAccount,
                  hint: Text('Select An Account', style: TextStyle(color: Colors.grey)),
                  items: accountNames.map((account) {
                    return DropdownMenuItem<String>(
                      value: account,
                      child: Text(
                        account,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccount = value;
                    });
                  },
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedYear,
                  hint: Text('Select Year', style: TextStyle(color: Colors.grey)),
                  items: [2024, 2025, 2026, 2027].map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}