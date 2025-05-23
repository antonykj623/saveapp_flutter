import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:new_project_2025/app/routes/app_page.dart';
import 'package:new_project_2025/app/routes/app_routes.dart';

import 'package:new_project_2025/view/home/widget/Reciept/Receipt_class/receipt_class.dart';
import 'package:new_project_2025/view_model/ledgerCashtable.dart';




void main() {
  runApp((MaterialApp(home: Ledgercash(),)));
  // runApp(
  //
  //   GetMaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   title: "SAVE App",
  //   initialRoute: AppRoutes.login,
  //   getPages: AppPages.pages,
  //   theme: ThemeData(primarySwatch: Colors.teal),
  // ));
}
