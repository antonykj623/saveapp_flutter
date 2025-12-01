// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// void main() {
//   runApp(
//     const MaterialApp(home: ChartPage(), debugShowCheckedModeBanner: false),
//   );
// }

// class ChartPage extends StatefulWidget {
//   const ChartPage({Key? key}) : super(key: key);

//   @override
//   State<ChartPage> createState() => _ChartPageState();
// }

// class _ChartPageState extends State<ChartPage> {
//   String selectedYear = '2025';
//   final List<String> years = ['2023', '2024', '2025', '2026'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Income and Expenditure',
//           style: TextStyle(color: Colors.black87),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Year Dropdown
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Container(
//               width: 180,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: ButtonTheme(
//                   alignedDropdown: true,
//                   child: DropdownButton<String>(
//                     value: selectedYear,
//                     icon: const Icon(Icons.keyboard_arrow_down),
//                     isExpanded: true,
//                     onChanged: (String? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           selectedYear = newValue;
//                         });
//                       }
//                     },
//                     items:
//                         years.map<DropdownMenuItem<String>>((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Chart
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SfCartesianChart(
//                 plotAreaBorderWidth: 0,
//                 primaryXAxis: CategoryAxis(
//                   majorGridLines: const MajorGridLines(
//                     width: 0.5,
//                     color: Colors.grey,
//                   ),
//                   axisLine: const AxisLine(width: 0),
//                   labelStyle: const TextStyle(
//                     color: Colors.black87,
//                     fontSize: 12,
//                   ),
//                 ),
//                 primaryYAxis: NumericAxis(
//                   minimum: 2400,
//                   maximum: 3600,
//                   interval: 200,
//                   majorGridLines: const MajorGridLines(
//                     width: 0.5,
//                     color: Colors.grey,
//                   ),
//                   axisLine: const AxisLine(width: 0),
//                   labelStyle: const TextStyle(
//                     color: Colors.black87,
//                     fontSize: 12,
//                   ),
//                   opposedPosition: false,
//                 ),
//                 legend: Legend(
//                   isVisible: true,
//                   position: LegendPosition.bottom,
//                   orientation: LegendItemOrientation.horizontal,
//                   textStyle: const TextStyle(fontSize: 12),
//                 ),
//                 tooltipBehavior: TooltipBehavior(enable: true),
//                 series: <CartesianSeries<FinancialData, String>>[
//                   ColumnSeries<FinancialData, String>(
//                     name: 'Income',
//                     dataSource: getChartData(),
//                     xValueMapper: (FinancialData data, _) => data.month,
//                     yValueMapper: (FinancialData data, _) => data.income,
//                     color: Colors.green,
//                     width: 0.6,
//                     spacing: 0.2,
//                   ),
//                   ColumnSeries<FinancialData, String>(
//                     name: 'Expense',
//                     dataSource: getChartData(),
//                     xValueMapper: (FinancialData data, _) => data.month,
//                     yValueMapper: (FinancialData data, _) => data.expense,
//                     color: Colors.purple,
//                     width: 0.6,
//                     spacing: 0.2,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Footer
//           Padding(
//             padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: Text(
//                 'My Chart',
//                 style: TextStyle(color: Colors.grey[700], fontSize: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<FinancialData> getChartData() {
//     return [
//       FinancialData('Jan', 0, 0),
//       FinancialData('Feb', 0, 0),
//       FinancialData('Mar', 0, 0),
//       FinancialData('Apr', 0, 0),
//       FinancialData('May', 2500, 3600),
//       FinancialData('Jun', 0, 0),
//       FinancialData('Jul', 0, 0),
//       FinancialData('Aug', 0, 0),
//       FinancialData('Sep', 0, 0),
//       FinancialData('Oct', 0, 0),
//       FinancialData('Nov', 0, 0),
//       FinancialData('Dec', 0, 0),
//     ];
//   }
// }

// class FinancialData {
//   final String month;
//   final double income;
//   final double expense;  

//   FinancialData(this.month, this.income, this.expense);
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'save_DB/Budegt_database_helper/Save_DB.dart';

class IncomeExpenditureChartPage extends StatefulWidget {
  const IncomeExpenditureChartPage({Key? key}) : super(key: key);

  @override
  State<IncomeExpenditureChartPage> createState() =>
      _IncomeExpenditureChartPageState();
}

class _IncomeExpenditureChartPageState
    extends State<IncomeExpenditureChartPage> {
  String selectedYear = DateTime.now().year.toString();
  List<String> years = [];
  List<MonthlyFinancialData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeYears();
    _loadChartData();
  }

  void _initializeYears() {
    int currentYear = DateTime.now().year;
    years = List.generate(5, (index) => (currentYear - 2 + index).toString());
  }

  Future<void> _loadChartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');

      // Initialize monthly data for all 12 months
      Map<int, MonthlyFinancialData> monthlyData = {};
      for (int i = 1; i <= 12; i++) {
        monthlyData[i] = MonthlyFinancialData(
          DateFormat('MMM').format(DateTime(2000, i)),
          0,
          0,
        );
      }

      print('=== Loading Chart Data for Year: $selectedYear ===');

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          // Only process income and expense accounts
          if (accountType != 'income account' &&
              accountType != 'expense account') {
            continue;
          }

          // Get all transactions for this account
          final transactions = await db.rawQuery(
            '''
            SELECT * FROM TABLE_ACCOUNTS 
            WHERE ACCOUNTS_setupid = ? 
            AND ACCOUNTS_VoucherType IN (1, 2)
            ''',
            [account['keyid'].toString()],
          );

          // Process each transaction
          for (var tx in transactions) {
            try {
              // Parse the date (format: dd/MM/yyyy)
              String dateStr = tx['ACCOUNTS_date'].toString();
              DateTime txDate = DateFormat('dd/MM/yyyy').parse(dateStr);

              // Check if transaction is in selected year
              if (txDate.year.toString() != selectedYear) {
                continue;
              }

              int month = txDate.month;
              double amount = double.parse(tx['ACCOUNTS_amount'].toString());
              String transactionType =
                  tx['ACCOUNTS_type'].toString().toLowerCase();

              double debit = transactionType == 'debit' ? amount : 0;
              double credit = transactionType == 'credit' ? amount : 0;

              // Calculate based on account type
              if (accountType == 'income account') {
                // Income = Credits - Debits
                double netIncome = credit - debit;
                monthlyData[month]!.income += netIncome;
              } else {
                // Expense = Debits - Credits
                double netExpense = debit - credit;
                monthlyData[month]!.expense += netExpense;
              }
            } catch (e) {
              print('Error parsing transaction: $e');
              continue;
            }
          }
        }
      }

      // Convert map to sorted list
      List<MonthlyFinancialData> sortedData = [];
      for (int i = 1; i <= 12; i++) {
        sortedData.add(monthlyData[i]!);
      }

      setState(() {
        chartData = sortedData;
        isLoading = false;
      });

      print('Chart data loaded successfully');
    } catch (e) {
      print('Error loading chart data: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chart data: $e')),
        );
      }
    }
  }

  double _getMaxValue() {
    if (chartData.isEmpty) return 1000;
    
    double maxIncome =
        chartData.map((e) => e.income).reduce((a, b) => a > b ? a : b);
    double maxExpense =
        chartData.map((e) => e.expense).reduce((a, b) => a > b ? a : b);
    double max = maxIncome > maxExpense ? maxIncome : maxExpense;

    // Add 20% padding to the max value
    return max > 0 ? (max * 1.2) : 1000;
  }

  double _getTotalIncome() {
    return chartData.fold(0.0, (sum, item) => sum + item.income);
  }

  double _getTotalExpense() {
    return chartData.fold(0.0, (sum, item) => sum + item.expense);
  }

  double _getNetProfitLoss() {
    return _getTotalIncome() - _getTotalExpense();
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = _getMaxValue();
    double interval = maxValue / 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Income & Expenditure Chart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChartData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading chart data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year Selection Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Select Year: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedYear,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.teal,
                                ),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedYear = newValue;
                                    });
                                    _loadChartData();
                                  }
                                },
                                items: years.map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Income',
                            _getTotalIncome(),
                            Colors.green,
                            Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Expense',
                            _getTotalExpense(),
                            Colors.purple,
                            Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Net Profit/Loss Card
                  _buildNetProfitLossCard(),

                  const SizedBox(height: 20),

                  // Chart Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Comparison',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Income vs Expense for $selectedYear',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            primaryXAxis: CategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              axisLine: const AxisLine(
                                width: 1,
                                color: Colors.grey,
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: maxValue,
                              interval: interval,
                              majorGridLines: MajorGridLines(
                                width: 0.5,
                                color: Colors.grey.shade200,
                              ),
                              axisLine: const AxisLine(
                                width: 1,
                                color: Colors.grey,
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                              ),
                              numberFormat: NumberFormat.compact(),
                            ),
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              orientation: LegendItemOrientation.horizontal,
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              iconHeight: 15,
                              iconWidth: 15,
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              format: 'point.x : ₹point.y',
                              borderWidth: 2,
                              borderColor: Colors.teal,
                            ),
                            series: <
                                CartesianSeries<MonthlyFinancialData, String>>[
                              ColumnSeries<MonthlyFinancialData, String>(
                                name: 'Income',
                                dataSource: chartData,
                                xValueMapper:
                                    (MonthlyFinancialData data, _) =>
                                        data.month,
                                yValueMapper:
                                    (MonthlyFinancialData data, _) =>
                                        data.income,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 0.5,
                                spacing: 0.2,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: false,
                                ),
                              ),
                              ColumnSeries<MonthlyFinancialData, String>(
                                name: 'Expense',
                                dataSource: chartData,
                                xValueMapper:
                                    (MonthlyFinancialData data, _) =>
                                        data.month,
                                yValueMapper:
                                    (MonthlyFinancialData data, _) =>
                                        data.expense,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 0.5,
                                spacing: 0.2,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Monthly Breakdown Table
                  _buildMonthlyBreakdownTable(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetProfitLossCard() {
    double netProfit = _getNetProfitLoss();
    bool isProfit = netProfit >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProfit
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isProfit ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isProfit ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isProfit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isProfit ? Colors.green : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfit ? 'Net Profit' : 'Net Loss',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${netProfit.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Monthly Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
              columns: const [
                DataColumn(
                  label: Text(
                    'Month',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Income',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Expense',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Net',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: chartData.map((data) {
                double net = data.income - data.expense;
                return DataRow(
                  cells: [
                    DataCell(Text(data.month)),
                    DataCell(
                      Text(
                        '₹${data.income.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${data.expense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${net.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: net >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyFinancialData {
  final String month;
  double income;
  double expense;

  MonthlyFinancialData(this.month, this.income, this.expense);
}