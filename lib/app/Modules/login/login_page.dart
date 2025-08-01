import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/app/Modules/login/OTP_page/OTP_page.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/services/API_services/sms_helper/sms_helper.dart';
import 'package:new_project_2025/view/home/widget/Resgistration_page/Resgistration_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/check_pattern.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobilenumber = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  final apidata = ApiHelper();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _passwordController.dispose();
    _mobilenumber.dispose();
    super.dispose();
  }

  /// Generate random 4-digit OTP
  int generateFourDigitNumber() {
    var random = Random();
    return 1000 + random.nextInt(9000); // Generates from 1000 to 9999
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
      debugPrint("Error: $e");
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

        debugPrint('Login successful - navigating to main app');

        if (mounted) {
          // Navigate directly to main app
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SaveApp()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint("Error parsing response: $e");
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
      debugPrint("Error launching URL: $e");
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
      builder: (context) => _buildLoadingDialog("Verifying mobile number..."),
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
      debugPrint("Error verifying mobile number: $e");
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
      builder: (context) => _buildLoadingDialog("Sending SMS..."),
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
      debugPrint("Error sending SMS: $e");
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
          (context) => _buildSuccessDialog(
            "SMS Sent Successfully",
            "Password reset OTP has been sent to $mobileNumber\n\nYour OTP is: $otp\n\nPlease enter this OTP to reset your password.",
            () {
              Navigator.pop(context);
              _navigateToOTPVerification(mobileNumber, 'forgot_password');
            },
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

  Widget _buildLoadingDialog(String message) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDialog(
    String title,
    String message,
    VoidCallback onPressed,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green.shade50],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: onPressed,
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.red.shade50],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Color(0xFFE57373)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFloatingShape({
    required double size,
    required Color color,
    required double top,
    required double left,
    required double animationOffset,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          top: top + (_floatingAnimation.value * animationOffset),
          left: left,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularWidgetLoading(
        loading: isLoading,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF667eea)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating background shapes
              _buildFloatingShape(
                size: 80,
                color: Colors.white.withOpacity(0.1),
                top: 100,
                left: 50,
                animationOffset: 1.0,
              ),
              _buildFloatingShape(
                size: 120,
                color: Colors.white.withOpacity(0.05),
                top: 200,
                left: MediaQuery.of(context).size.width - 150,
                animationOffset: -0.8,
              ),
              _buildFloatingShape(
                size: 60,
                color: Colors.white.withOpacity(0.15),
                top: 400,
                left: 30,
                animationOffset: 1.2,
              ),
              _buildFloatingShape(
                size: 100,
                color: Colors.white.withOpacity(0.08),
                top: 500,
                left: MediaQuery.of(context).size.width - 120,
                animationOffset: -1.0,
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Form(
                            key: _loginFormKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo and title section
                                AnimatedBuilder(
                                  animation: _floatingAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        _floatingAnimation.value * 0.5,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          "assets/login.png",
                                          height: 120,
                                          width: 120,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                ShaderMask(
                                  shaderCallback:
                                      (bounds) => const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFE3F2FD),
                                        ],
                                      ).createShader(bounds),
                                  child: const Text(
                                    'My Personal App',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Welcome back! Please sign in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 50),

                                // Login form
                                _buildGlassmorphicContainer(
                                  child: Column(
                                    children: [
                                      _buildStyledTextField(
                                        controller: _mobilenumber,
                                        hintText: 'Mobile Number',
                                        icon: Icons.phone_android,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please Enter Mobile';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 25),
                                      _buildStyledTextField(
                                        controller: _passwordController,
                                        hintText: 'Password',
                                        icon: Icons.lock_outline,
                                        obscureText: _obscureText,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please Enter Password';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _showForgotPasswordDialog,
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      // Login button
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Color(0xFFF5F5F5),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_loginFormKey.currentState!
                                                .validate()) {
                                              loginUser();
                                            }
                                          },
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Color(0xFF667eea),
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Sign up link
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _launchSignUpURL,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Don't have an account? ",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                          const TextSpan(
                                            text: "Create one",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
              ),
            ],
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

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _forgotPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _forgotFormKey = GlobalKey<FormState>();

  late AnimationController _dialogAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dialogAnimationController, curve: Curves.easeIn),
    );

    _dialogAnimationController.forward();
  }

  @override
  void dispose() {
    _dialogAnimationController.dispose();
    _forgotPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Form(
              key: _forgotFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.2),
                          const Color(0xFF764ba2).withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Enter your mobile number to reset your password:",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _forgotPasswordController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return "Enter valid mobile number";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              if (_forgotFormKey.currentState!.validate()) {
                                final mobile =
                                    _forgotPasswordController.text.trim();
                                Navigator.pop(context);
                                widget.onSubmit(mobile);
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
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
