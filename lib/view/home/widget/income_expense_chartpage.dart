import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(
    const MaterialApp(home: ChartPage(), debugShowCheckedModeBanner: false),
  );
}

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String selectedYear = '2025';
  final List<String> years = ['2023', '2024', '2025', '2026'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Income and Expenditure',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    value: selectedYear,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      }
                    },
                    items:
                        years.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(
                    width: 0.5,
                    color: Colors.grey,
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 2400,
                  maximum: 3600,
                  interval: 200,
                  majorGridLines: const MajorGridLines(
                    width: 0.5,
                    color: Colors.grey,
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                  opposedPosition: false,
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  orientation: LegendItemOrientation.horizontal,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<FinancialData, String>>[
                  ColumnSeries<FinancialData, String>(
                    name: 'Income',
                    dataSource: getChartData(),
                    xValueMapper: (FinancialData data, _) => data.month,
                    yValueMapper: (FinancialData data, _) => data.income,
                    color: Colors.green,
                    width: 0.6,
                    spacing: 0.2,
                  ),
                  ColumnSeries<FinancialData, String>(
                    name: 'Expense',
                    dataSource: getChartData(),
                    xValueMapper: (FinancialData data, _) => data.month,
                    yValueMapper: (FinancialData data, _) => data.expense,
                    color: Colors.purple,
                    width: 0.6,
                    spacing: 0.2,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'My Chart',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FinancialData> getChartData() {
    return [
      FinancialData('Jan', 0, 0),
      FinancialData('Feb', 0, 0),
      FinancialData('Mar', 0, 0),
      FinancialData('Apr', 0, 0),
      FinancialData('May', 2500, 3600),
      FinancialData('Jun', 0, 0),
      FinancialData('Jul', 0, 0),
      FinancialData('Aug', 0, 0),
      FinancialData('Sep', 0, 0),
      FinancialData('Oct', 0, 0),
      FinancialData('Nov', 0, 0),
      FinancialData('Dec', 0, 0),
    ];
  }
}

class FinancialData {
  final String month;
  final double income;
  final double expense;

  FinancialData(this.month, this.income, this.expense);
}
