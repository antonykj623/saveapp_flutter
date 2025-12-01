import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/report_screen/List_of_Insurance_report/List_of_insurance.dart';
import 'package:new_project_2025/view/home/widget/report_screen/List_of_assets/List_of_assets.dart';
import 'package:new_project_2025/view/home/widget/report_screen/My_net_worth/my_net_worth.dart';
import 'package:new_project_2025/view/home/widget/report_screen/Recharge_report/Recharge_report_screen.dart';
import 'package:new_project_2025/view/home/widget/report_screen/Transaction/Transaction.dart';
import 'package:new_project_2025/view/home/widget/report_screen/bill_Res/Bill_Register.dart';
import 'package:new_project_2025/view/home/widget/report_screen/ledger/Income_And_Expenditure.dart';
import 'package:new_project_2025/view/home/widget/report_screen/ledger/ledger.dart';
import 'package:new_project_2025/view/home/widget/report_screen/list_investment_report/List_of_invesment.dart';
import 'package:new_project_2025/view/home/widget/report_screen/list_liabilities_Report/List_of_liabilities.dart';
import 'package:new_project_2025/view_model/CashBank/cashBank.dart';
import 'package:new_project_2025/view_model/Task/tasklist.dart';

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
    "Bill Register",
    'Recharge Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: reportItems.length,
          itemBuilder: (context, index) {
            return _buildReportItem(
              title: reportItems[index],
              onTap: () {
                if (reportItems[index] == 'Transactions') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionsScreen(),
                    ),
                  );
                } else if (reportItems[index] == 'Recharge Report') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RechargeReportPage(),
                    ),
                  );
                } else if (reportItems[index] == 'Cash and Bank') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Cashbank()),
                  );
                } else if (reportItems[index] == 'Ledgers') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentReceiptLedger(),
                    ),
                  );
                } else if (reportItems[index] == 'List of My Assets') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListOfAssetsPage()),
                  );
                } else if (reportItems[index] == 'List of My Liabilities') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListOfLiabilitiesPage(),
                    ),
                  );
                } else if (reportItems[index] == 'List of My Insurances') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListOfInsurancePage(),
                    ),
                  );
                } else if (reportItems[index] == 'List of My Investment') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListOfInvestmentPage(),
                    ),
                  );
                } else if (reportItems[index] == 'Bill Register') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BillRegisterPage()),
                  );
                } else if (reportItems[index] == "Reminders") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const TaskListPage(
                            title: "Reminders",
                            isReportPage: true,
                          ),
                    ),
                  );
                } else if (reportItems[index] ==
                    "Income and Expenditure Statement") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncomeExpenditure(),
                    ),
                  );
                } else if (reportItems[index] == "My Networth") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyNetworthScreen()),
                  );
                }
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
