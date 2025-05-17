import 'package:get/get.dart';
import 'package:new_project_2025/app/Modules/login/login_binding.dart';
import 'package:new_project_2025/view/home/Login_screen_widget.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
  ];
}
