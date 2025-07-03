import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_project_2025/view/home/widget/signuppage/signupData/signupdata.dart';
import 'package:new_project_2025/view/home/widget/signuppage/signupusermodel/signupmodeluser.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignUp(),
    );
  }
}


class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final promocode = TextEditingController();
  final confirmpassword = TextEditingController();
  
  var db = DatabaseHelper.instance;
  
  var dropdownvalue = 'India'.obs;
  var dropdownvalue1 = 'Kerala'.obs;
  
  var showWidget = false.obs;
  var confirmPass = ''.obs;
  var promocode1 = ''.obs;
  var promovisible = true.obs;
  var isVisible = false.obs;
  
  var emailBorderColor = Colors.white.obs;
  var mobileBorderColor = Colors.white.obs;
  var value = false.obs;
  
 
  final items = [
    'India',
    'Iran',
    'Ireland',
    'Australia',
    'Germany',
  ];
  
  final items1 = [
    'Kerala',
    'Rajasthan',
    'Tamilnadu',
    'Newdelhi',
    'Germany',
  ];
  
  void toggleVisibility() {
    isVisible.value = true;
  }
  
  void toggleNonVisibility() {
    isVisible.value = false;
  }
  
  void togglePromoCode() {
    showWidget.toggle();
  }
  
  void clearText() {
    username.clear();
    password.clear();
    email.clear();
    mobile.clear();
    confirmpassword.clear();
    promocode.clear();
  }
  
  void queryAll() async {
    var allrows = await db.queryall();
    allrows.forEach((row) {
      print("Rowdatas are:$row");
    });
  }
  
  void deleteData() async {
    await db.deleteData();
    print("Rows Deleted");
  }
  
  Future<void> registerUser() async {
    if (username.text.isEmpty || 
        email.text.isEmpty || 
        mobile.text.isEmpty || 
        password.text.isEmpty || 
        confirmpassword.text.isEmpty || 
        dropdownvalue1.isEmpty || 
        dropdownvalue.isEmpty) {
      
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        title: 'Fill all details',
      );
    } else {
      final nametext = username.text;
      final passwordtext = password.text;
      final confirmpasswordtext = confirmpassword.text;
      final emailtext = email.text;
      final promocodetext = promocode.text;
      final mobiletext = mobile.text;
      final countrytext = dropdownvalue.value;
      final state = dropdownvalue1.value;
      
      Future<Users> usr = db.create(Users(
        username: nametext,
        email: emailtext,
        mobile: mobiletext,
        promocode: promocodetext,
        confirmpassword: confirmpasswordtext,
        country: countrytext,
        password: passwordtext,
        state: state
      ));
      
      usr.then((value) {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.success,
          title: 'Registration Completed Please Login..',
        );
        Get.back();
      });
    }
  }
  
  String? validateMobile(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isEmpty || !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
  
  String? validatePassword(String? value) {
    confirmPass.value = value!;
    if (value.isEmpty) {
      return "Please Enter New Password";
    } else if (value.length < 8) {
      return "Password must be atleast 8 characters long";
    } else {
      return null;
    }
  }
  
  String? validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return "Please Re-Enter New Password";
    } else if (value.length < 8) {
      return "Password must be atleast 8 characters long";
    } else if (value != confirmPass.value) {
      return "Password must be same as above";
    } else {
      return null;
    }
  }
  
  void updateEmailBorderColor(String value) {
    if (validateEmail(value) == null) {
      emailBorderColor.value = Color(0xFFE91e63);
    } else {
      emailBorderColor.value = Colors.grey.shade300;
    }
  }
  
  void updateMobileBorderColor(String value) {
    if (validateMobile(value) == null) {
      mobileBorderColor.value = Color(0xFFE91e63);
    } else {
      mobileBorderColor.value = Colors.grey.shade300;
    }
  }
  
  @override
  void onClose() {
    username.dispose();
    password.dispose();
    email.dispose();
    mobile.dispose();
    promocode.dispose();
    confirmpassword.dispose();
    super.onClose();
  }
}

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controller
    final controller = Get.put(SignUpController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft, 
          colors: [
            Color.fromARGB(255, 58, 93, 102),
            Color.fromARGB(255, 10, 154, 179)
          ]
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Signup'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5),
                  
                  // Username Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: controller.username,
                      enabled: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 254, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        hintText: "Name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Your name!!';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Email Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      validator: controller.validateEmail,
                      controller: controller.email,
                      enabled: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 254, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        hintText: "Email Address",
                      ),
                      onChanged: (value) {
                        controller.updateEmailBorderColor(value);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
           
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      validator: controller.validateMobile,
                      controller: controller.mobile,
                      enabled: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 254, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        hintText: "Mobile",
                      ),
                      onChanged: (value) {
                        controller.updateMobileBorderColor(value);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Password Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: controller.password,
                      enabled: true,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 254, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        hintText: "Password",
                      ),
                      validator: controller.validatePassword,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Confirm Password Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: controller.confirmpassword,
                      enabled: true,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 255, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 254, 255, 255), 
                            width: 1.0
                          ),
                        ),
                        hintText: "Confirm Password",
                      ),
                      validator: controller.validateConfirmPassword,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Country Dropdown
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Obx(() => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 254, 254), 
                            style: BorderStyle.solid, 
                            width: 0.80
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.dropdownvalue.value,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: controller.items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.dropdownvalue.value = newValue;
                                print("new value is..$newValue");
                              }
                            },
                          ),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // State Dropdown
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Obx(() => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0.0),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 254, 254), 
                            style: BorderStyle.solid, 
                            width: 0.80
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.dropdownvalue1.value,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: controller.items1.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (String? newValue1) {
                              if (newValue1 != null) {
                                controller.dropdownvalue1.value = newValue1;
                                print("Value is..:$newValue1");
                              }
                            },
                          ),
                        ),
                      )),
                    ),
                  ),
                  
                  // Promotional Code Section
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => controller.showWidget.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Container(
                                  width: 350,
                                  height: 200,
                                  color: Color.fromARGB(255, 39, 138, 163),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: controller.promocode,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: const Color.fromARGB(255, 255, 255, 255), 
                                              width: 1.0
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: const Color.fromARGB(255, 254, 255, 255), 
                                              width: 1.0
                                            ),
                                          ),
                                          hintText: "Enter Promocode",
                                          hintStyle: TextStyle(color: Colors.white),
                                        ),
                                        validator: (String? value) {
                                          controller.promocode1.value = value ?? '';
                                          if (value!.isEmpty) {
                                            return "Please Enter Promocode";
                                          } else if (value.length <= 1) {
                                            return "Promocode must be atleast 10 characters long";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 46, 151, 165),
                                          foregroundColor: const Color.fromARGB(255, 89, 14, 175),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                        ),
                                        onPressed: controller.togglePromoCode,
                                        child: Text("VALIDATE"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container()
                        ),
                        
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Do you have a promotional code',
                                  style: TextStyle(color: Colors.white),
                                )
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 65, 161, 199),
                                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                                ),
                                onPressed: controller.togglePromoCode,
                                child: Text('Yes'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 65, 161, 199),
                                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                                ),
                                onPressed: () {
                                  // This would be replaced with GetX implementation
                                  Widget _myListView(BuildContext context) {
                                    return ListView(
                                      children: ListTile.divideTiles(
                                        context: context,
                                        tiles: [
                                          ListTile(title: Text('Sun')),
                                          ListTile(title: Text('Moon')),
                                          ListTile(title: Text('Star')),
                                        ],
                                      ).toList(),
                                    );
                                  }
                                },
                                child: Text('No'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Submit Button
                  Container(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: controller.registerUser,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.blue, fontSize: 25),
                      ),
                    ),
                  ),
                  
                  // Checkbox Row
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 10),
                      const Text(
                        'Library Implementation Of Searching Algorithm: ',
                        style: TextStyle(fontSize: 17.0),
                      ),
                      const SizedBox(width: 10),
                      Obx(() => Checkbox(
                        tristate: true,
                        value: controller.value.value,
                        onChanged: (bool? newValue) {
                          controller.value.value = newValue!;
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}