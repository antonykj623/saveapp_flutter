import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  var obscureText = true.obs;
  final formKey = GlobalKey<FormState>();

  void toggleObscure() {
    obscureText.value = !obscureText.value;
  }

  void login() {
    if (formKey.currentState!.validate()) {
      
      Get.snackbar("Success", "Logged in!");
    }
  }
}
