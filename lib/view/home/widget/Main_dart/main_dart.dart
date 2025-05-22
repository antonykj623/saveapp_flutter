import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/payment_page/databasehelper/data_base_helper.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payhment_page.dart';
import 'package:sqflite/sqflite.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(
     MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payment Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF008080),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008080),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008080),
          primary: const Color(0xFF008080),
          secondary: const Color(0xFFD81B60),
        ),
        useMaterial3: true,
      ),
      home: const PaymentsPage(),
    );
  }
}