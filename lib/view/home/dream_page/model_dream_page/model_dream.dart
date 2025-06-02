import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/dream_page/dream_main_page/dream_page_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Savings',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyDreamScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dream {
  String name;
  String category;
  String investment;
  double closingBalance;
  double addedAmount;
  double savedAmount;
  double targetAmount;
  DateTime targetDate;
  String notes;

  Dream({
    required this.name,
    required this.category,
    required this.investment,
    this.closingBalance = 0.0,
    this.addedAmount = 0.0,
    this.savedAmount = 0.0,
    required this.targetAmount,
    required this.targetDate,
    this.notes = '',
  });

  double get progressPercentage => (savedAmount / targetAmount) * 100;
}
