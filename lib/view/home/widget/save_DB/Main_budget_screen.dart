// import 'package:flutter/material.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Edit_budget_screen/Edit_budget_screen.dart';


// void main() {
//   runApp(MaterialApp(home: BudgetScreen()));
// }


//
// import '../budget_page/Budegt_database_helper/Budget_data_base.dart';
//
// void main() {
//   runApp(MaterialApp(home: BudgetScreen()));
// }
//

// class BudgetScreen extends StatefulWidget {
//   @override
//   _BudgetScreenState createState() => _BudgetScreenState();
// }


// class _BudgetScreenState extends State<BudgetScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _amountController = TextEditingController();


//
// class _BudgetScreenState extends State<BudgetScreen> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _amountController = TextEditingController();
//

//   int selectedYear = DateTime.now().year;
//   String? selectedAccount;
//   List<BudgetClass> budgets = [];
//   List<String> accountNames = [
//     'Agriculture Expenses',
//     'Accounts for Children',
//     'Household Expenses',
//     'Transportation',
//     'Healthcare',
//     'Education',
//     'Savings',
//     'Entertainment',
//   ];
//   double totalAmount = 0.0;
//   List<String> months = [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadAccountNames();
//   }

//   Future<void> _loadAccountNames() async {
//     final accounts = await _dbHelper.getAccountNames();
//     setState(() {
//       accountNames = accounts.isNotEmpty ? accounts : accountNames;
//       selectedAccount = accountNames.isNotEmpty ? accountNames.first : null;
//     });
//     _loadBudgets();
//   }

//   Future<void> _loadBudgets() async {
//     if (selectedAccount != null) {
//       final budgetList = await _dbHelper.getBudgets(
//         selectedAccount!,
//         selectedYear,
//       );
//       setState(() {
//         budgets = budgetList.map((map) => BudgetClass.fromMap(map)).toList();
//         _calculateTotal();
//       });
//     }
//   }

//   Future<void> _submitBudget() async {
//     if (_amountController.text.isEmpty || selectedAccount == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter an amount and select an account')),
//       );
//       return;
//     }

//     double? monthlyAmount;
//     try {
//       monthlyAmount = double.parse(_amountController.text);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
//       return;
//     }

//     for (var budget in budgets) {
//       if (budget.id != null) {
//         await _dbHelper.deleteBudget(budget.id!);
//       }
//     }

//     for (String month in months) {
//       await _dbHelper.insertBudget({
//         'account_name': selectedAccount!,
//         'year': selectedYear,
//         'month': month,
//         'amount': monthlyAmount,
//       });
//     }

//     _loadBudgets();
//     _amountController.clear();
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Budget submitted successfully')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Budget', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.teal,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<int>(
//                         isExpanded: true, // Ensures dropdown takes full width
//                         value: selectedYear,
//                         items:
//                             [2024, 2025, 2026, 2027].map((year) {
//                               return DropdownMenuItem<int>(
//                                 value: year,
//                                 child: Text(
//                                   year.toString(),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedYear = value!;
//                           });
//                           _loadBudgets();
//                         },
//                         hint: Text(
//                           'Select Year',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         style: TextStyle(color: Colors.black87, fontSize: 16),
//                         dropdownColor:
//                             Colors.white, // Ensures dropdown is visible
//                         icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         isExpanded: true, // Ensures dropdown takes full width
//                         value: selectedAccount,
//                         hint: Text(
//                           'Select An Account',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         items:
//                             accountNames.map((account) {
//                               return DropdownMenuItem<String>(
//                                 value: account,
//                                 child: Text(
//                                   account,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black87,
//                                   ),
//                                   overflow:
//                                       TextOverflow
//                                           .ellipsis, // Prevents overflow
//                                 ),
//                               );
//                             }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedAccount = value;
//                           });
//                           _loadBudgets();
//                         },
//                         style: TextStyle(color: Colors.black87, fontSize: 16),
//                         dropdownColor:
//                             Colors.white, // Ensures dropdown is visible
//                         icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: TextField(
//                 controller: _amountController,
//                 decoration: InputDecoration(
//                   labelText: 'Amount per month',
//                   border: InputBorder.none,
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//             SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _submitBudget,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: Text(
//                   'Submit',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//             SizedBox(height: 32),
//             if (budgets.isNotEmpty) ...[
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Table(
//                     border: TableBorder.all(color: Colors.grey),
//                     children: [
//                       TableRow(
//                         decoration: BoxDecoration(color: Colors.grey[200]),
//                         children: [
//                           _buildTableCell('Month', isHeader: true),
//                           _buildTableCell('Amount', isHeader: true),
//                           _buildTableCell('Action', isHeader: true),
//                         ],
//                       ),
//                       ...budgets
//                           .map(
//                             (budget) => TableRow(
//                               children: [
//                                 _buildTableCell(budget.month),
//                                 _buildTableCell(
//                                   budget.amount.toStringAsFixed(2),
//                                 ),
//                                 _buildActionCell(budget),
//                               ],
//                             ),
//                           )
//                           .toList(),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Total: ${totalAmount.toStringAsFixed(2)}',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTableCell(String text, {bool isHeader = false}) {
//     return Padding(
//       padding: EdgeInsets.all(12),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCell(BudgetClass budget) {
//     return Padding(
//       padding: EdgeInsets.all(8),
//       child: IconButton(
//         icon: Icon(Icons.edit, color: Colors.green),
//         onPressed: () => _editBudget(budget),
//       ),
//     );
//   }

//   void _editBudget(BudgetClass budget) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) =>
//                 EditBudgetScreen(budget: budget, onUpdate: _loadBudgets),
//       ),
//     );
//   }
// }
