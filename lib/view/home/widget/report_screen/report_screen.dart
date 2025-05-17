import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ReportScreen(),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  final List<String> reportItems = const [
    'Transactions',
    'Ledgers',
    'Cash and Bank',
    'Income and Expenditure Statement',
    'My Networth',
    'Reminders',
    'List of My Assets',
    'List of My Liabilities',
    'List of My Insurances',
    'List of My Investment',
    "Bill Register ",
    'Recharge Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: reportItems.length,
          itemBuilder: (context, index) {
            return _buildReportItem(
              title: reportItems[index],
              onTap: () {
                print('${reportItems[index]} tapped');
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
