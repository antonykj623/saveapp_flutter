import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/app/Modules/login/OTP_page/OTP_page.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/services/API_services/sms_helper/sms_helper.dart';
import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view_model/Resgistration_page/Resgistration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_loading/widget_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobilenumber = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

  final apidata = ApiHelper();

  /// Generate random 4-digit OTP
  int generateFourDigitNumber() {
    var random = Random();
    return 1000 + random.nextInt(9000); // Generates from 1000 to 9999
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _mobilenumber.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    var uuid = Uuid().v4();
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, String> logdata = {
      "mobile": _mobilenumber.text.trim(),
      "password": _passwordController.text.trim(),
      "uuid": uuid,
      "timestamp": timestamp,
    };

    try {
      String logresponse = await apidata.postApiResponse(
        "UserLogin.php",
        logdata,
      );
      await handleLoginResponse(context, logresponse);
    } catch (e) {
      print("Error: $e");
      _showErrorDialog(
        "Login Error",
        "An error occurred during login. Please try again.",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleLoginResponse(
    BuildContext context,
    String response,
  ) async {
    try {
      final data = jsonDecode(response);

      int status = data['status'];
      String message = data['message'];

      if (status == 0) {
        _showErrorDialog("Login Failed", message);
      } else if (status == 2) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('status', status);
        await prefs.setString('token', data['token']);
        await prefs.setString('userid', data['userid']);
        await prefs.setString('message', message);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SaveApp()),
          );
        }
      }
    } catch (e) {
      print("Error parsing response: $e");
      _showErrorDialog(
        "Error",
        "An error occurred while processing the login response.",
      );
    }
  }

  Future<void> _launchSignUpURL() async {
    const String url = 'https://mysaveapp.com/signup';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(
          "Error",
          "Could not open the signup page. Please try again later.",
        );
      }
    } catch (e) {
      print("Error launching URL: $e");
      _showErrorDialog(
        "Error",
        "Could not open the signup page. Please try again later.",
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ForgotPasswordDialog(onSubmit: _submitForgotPassword);
      },
    );
  }

  Future<void> _submitForgotPassword(String mobileNumber) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Verifying mobile number..."),
              ],
            ),
          ),
    );

    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String apiUrl =
          "https://mysaving.in/IntegraAccount/api/getUserByMobile.php?mobile=$mobileNumber&timestamp=$timestamp";

      final response = await http.get(Uri.parse(apiUrl));

      if (mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 1 ||
            data['success'] == true ||
            data.containsKey('user')) {
          await _sendPasswordResetSMS(mobileNumber);
        } else {
          _showErrorDialog(
            "Mobile number not found",
            "The mobile number $mobileNumber is not registered with us. Please check the number and try again.",
          );
        }
      } else {
        _showErrorDialog(
          "Server Error",
          "Unable to verify mobile number. Please try again later.",
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      print("Error verifying mobile number: $e");
      _showErrorDialog(
        "Network Error",
        "Unable to connect to server. Please check your internet connection and try again.",
      );
    }
  }

  Future<void> _sendPasswordResetSMS(String mobileNumber) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Sending SMS..."),
              ],
            ),
          ),
    );

    try {
      final smsResult = await SMSHelper.sendForgotPasswordOTP(mobileNumber);

      if (mounted) {
        Navigator.pop(context);
      }

      if (smsResult['success']) {
        int randomOTP = generateFourDigitNumber();
        String otpString = randomOTP.toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('forgot_password_otp', otpString);
        await prefs.setString('forgot_password_mobile', mobileNumber);
        await prefs.setInt(
          'otp_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );

        _showPasswordResetSuccessDialog(mobileNumber, otpString);
      } else {
        _showErrorDialog(
          "SMS Error",
          "Failed to send SMS. Please try again later.\n\nError: ${smsResult['message']}",
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      print("Error sending SMS: $e");
      _showErrorDialog(
        "SMS Error",
        "Failed to send SMS. Please try again later.",
      );
    }
  }

  void _showPasswordResetSuccessDialog(String mobileNumber, String otp) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "SMS Sent Successfully",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 15),
                Text(
                  "Password reset OTP has been sent to $mobileNumber",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Your OTP is: $otp",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please enter this OTP to reset your password.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToOTPVerification(mobileNumber, 'forgot_password');
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _navigateToOTPVerification(String mobileNumber, String purpose) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SimpleOTPVerificationScreen(
              mobileNumber: mobileNumber,
              purpose: purpose,
            ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularWidgetLoading(
        loading: isLoading,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
            ),
          ),
          child: Form(
            key: _loginFormKey,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
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
                        style: const TextStyle(color: Colors.white),
                        controller: _passwordController,
                        decoration: InputDecoration(
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
                              color: Colors.white,
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
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            'Forgot password?',
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
                          onPressed: () {
                            if (_loginFormKey.currentState!.validate()) {
                              loginUser();
                            }
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
                        onPressed: _launchSignUpURL,
                        child: const Text(
                          'Don\'t have an account? Create one',
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
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const _ForgotPasswordDialog({required this.onSubmit});

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final TextEditingController _forgotPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _forgotFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _forgotPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Forgot Password",
        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _forgotFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your mobile number to reset your password:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _forgotPasswordController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Mobile Number',
                prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return "Enter valid mobile number";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_forgotFormKey.currentState!.validate()) {
              final mobile = _forgotPasswordController.text.trim();
              Navigator.pop(context);
              widget.onSubmit(mobile);
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
