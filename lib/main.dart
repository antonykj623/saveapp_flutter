  import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:new_project_2025/app/routes/app_page.dart';
import 'package:new_project_2025/app/routes/app_routes.dart';
import 'package:new_project_2025/view/home/widget/investment/investmentList_pag/Investment_List_screen.dart';

// void main() {
//   runApp(
//     GetMaterialApp(  
//     debugShowCheckedModeBanner: false,
//     title: "SAVE App",
//     initialRoute: AppRoutes.login,
//     getPages: AppPages.pages,
//     theme: ThemeData(primarySwatch: Colors.teal),
//   ));
// }


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investment Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InvestmentListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}