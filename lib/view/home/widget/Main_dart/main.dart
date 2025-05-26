import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Bank_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Voucher App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: BankVoucherListScreen(),
    );
  }
}