import 'package:get/get.dart';
import 'package:new_project_2025/app/Modules/login/login_control.dart';
import 'package:new_project_2025/view_model/AccountSet_up/accountsetup.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
 Get.lazyPut<LoginController>(() => LoginController());
   // Get.lazyPut<LoginController>(() => HomeScreen());
  }
}
