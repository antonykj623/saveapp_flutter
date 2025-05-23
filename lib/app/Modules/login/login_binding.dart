import 'package:get/get.dart';
import 'package:new_project_2025/app/Modules/login/login_control.dart';
import 'package:new_project_2025/view_model/home_view_model.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
 Get.lazyPut<LoginController>(() => LoginController());
   // Get.lazyPut<LoginController>(() => HomeScreen());
  }
}
