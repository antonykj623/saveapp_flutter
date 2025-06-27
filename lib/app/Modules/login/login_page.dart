import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view_model/Resgistration_page/Resgistration_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAVE App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  initState() {
    apidata;

    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobilenumber = TextEditingController();

  var apidata = ApiHelper();

  void loginUser() async {
    var uuid = Uuid().v4(); // generates a random UUID
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, String> logdata = {
      "mobile": _mobilenumber.text.trim(),
      "password": _passwordController.text.trim(),
      "uuid": uuid,
      "timestamp": timestamp,
    };

    ApiHelper api = ApiHelper();

    try {
      String logresponse = await api.postApiResponse("UserLogin.php", logdata);

      print("Response: $logresponse");
      //  var res = json.decode(logresponse);
      // print("res is...$res");

      handleLoginResponse(context, logresponse);

      //if (parseLoginResponse.statusCode == 200) {
      //   // Parse JSON
      //   var data = json.decode(response.body);
      //
      //   bool status = data['status'];
      //   String message = data['message'];
      //   String? token = data['token'];
      //
      //   print("Status: $status");
      //   print("Message: $message");
      //   print("Token: $token");
      // } else {
      //   print("Error: ${response.statusCode}");
      // }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> handleLoginResponse(
    BuildContext context,
    String response,
  ) async {
    try {
      final data = jsonDecode(
        response,
      ); // Decode once — result is Map<String, dynamic>

      int status = data['status'];
      String message = data['message'];

      if (status == 0) {
        // Show alert dialog for error
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Login Failed"),
                content: Text(message), // "No user found"
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      } else if (status == 2) {
        int status = data['status'];
        String token = data['token'];
        String userId = data['userid'];
        String message = data['message'];

        print('Status: $status');
        print('Token: $token');
        print('User ID: $userId');
        print('Message: $message');
        //saved to shared preference

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('status', status);
        await prefs.setString('token', token);
        await prefs.setString('userid', userId);
        await prefs.setString('message', message);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SaveApp()),
        );
      }
    } catch (e) {
      print("Error parsing response: $e");
    }
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('password', _passwordController.text);

    // String? token = prefs.getString('token');
    // String? userId = prefs.getString('userid');
    // int? status = prefs.getInt('status');
    //
    // print("Saved token: $token");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(' password saved!')));
  }

  bool isLoading = false;
  // Future<void> login() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //
  //   final url = Uri.parse("https://your-api-url.com/login.php"); // Replace with your API
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //     //  'email': emailController.text,
  //       'password': _passwordController.text,
  //     }),
  //   );
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  //
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     print("Login successful: $responseData");
  //     // Navigate or save token etc.
  //   } else {
  //     print("Login failed: ${response.body}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Login failed. Check credentials.")),
  //     );
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/login.png", height: 150),
                    const SizedBox(height: 10),

                    const Text(
                      'My Personal App',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      controller: _mobilenumber,
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please Enter Mobile';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      obscureText: _obscureText,
                      style: TextStyle(color: Colors.white),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please Enter Password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password ?',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          //call Jsondata
                          // if(_mobilenumber.text == "" )
                          //   {
                          //     _mobilenumber.text = "Please Enter Mobile Number";
                          //
                          //   }
                          // else if(_passwordController.text == ""){
                          //
                          //   _passwordController.text = "Please Enter Password";
                          //
                          // }
                          if (_mobilenumber.text == "" &&
                              _passwordController.text == "") {
                            _mobilenumber.text = "Please Enter Mobile Number";
                            _passwordController.text = "Please Enter Password";
                          } else {
                            loginUser();
                          }

                          final prefs = await SharedPreferences.getInstance();

                          int? status = prefs.getInt('status');
                          print("Error status code is $status");

                          // else {
                          //   // Push to HomePage
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => SaveApp()),
                          //   );
                          // }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Don\'t you have account ? Create new one',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
