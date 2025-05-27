import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/Insurance_list_page/insurance_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insurance Management',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InsuranceListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}