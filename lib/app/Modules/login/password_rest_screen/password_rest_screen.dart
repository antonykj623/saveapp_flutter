import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetScreen extends StatefulWidget {
  final String mobileNumber;

  const PasswordResetScreen({Key? key, required this.mobileNumber})
    : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen>
    with TickerProviderStateMixin {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordStrong = false;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shakeAnimation;

  // API Configuration
  static const String baseUrl =
      "https://mysaving.in/IntegraAccount/api/changePassword.php";

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    String password = _newPasswordController.text;
    bool hasMinLength = password.length >= 8;

    setState(() {
      _isPasswordStrong = hasMinLength;
    });
  }

  double _getPasswordStrength() {
    String password = _newPasswordController.text;
    if (password.isEmpty) return 0.0;

    double strength = 0.0;
    if (password.length >= 8)
      strength = 1.0;
    else
      strength = password.length / 8;

    return strength;
  }

  Color _getPasswordStrengthColor() {
    double strength = _getPasswordStrength();
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.6) return Colors.yellow;
    if (strength <= 0.8) return Colors.blue;
    return Colors.green;
  }

  String _getPasswordStrengthText() {
    double strength = _getPasswordStrength();
    if (strength < 1.0) return "Password must be at least 8 characters";
    return "Password meets requirements";
  }

  Future<Map<String, dynamic>> _resetPassword({
    required String mobile,
    required String password,
    required String timestamp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': mobile,
          'password': password,
          'timestamp': timestamp,
        }),
      );

      print("Password Reset Response Status: ${response.statusCode}");
      print("Password Reset Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': jsonResponse,
            'message': 'Password reset successfully',
          };
        } catch (e) {
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': response.body,
            'message': 'Password reset successfully',
          };
        }
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'data': response.body,
          'message': 'Failed to reset password: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Error resetting password: $e");
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'message': 'Error resetting password: $e',
      };
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward().then((_) => _shakeController.reverse());
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog(
        "Password Mismatch",
        "New password and confirm password do not match.",
      );
      _shakeController.forward().then((_) => _shakeController.reverse());
      return;
    }

    if (!_isPasswordStrong) {
      _showErrorDialog(
        "Invalid Password",
        "Password must be at least 8 characters long.",
      );
      return;
    }

    // Validate mobile number format (10 digits)
    if (!RegExp(r'^\d{10}$').hasMatch(widget.mobileNumber)) {
      _showErrorDialog(
        "Invalid Mobile Number",
        "The mobile number is invalid. Please try again.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final result = await _resetPassword(
        mobile: widget.mobileNumber,
        password: _newPasswordController.text,
        timestamp: timestamp,
      );

      if (result['success']) {
        // Clear OTP-related data only on success
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('forgot_password_otp');
        await prefs.remove('forgot_password_mobile');
        await prefs.remove('otp_timestamp');

        _showSuccessDialog(
          "Password Reset Successful",
          "Your password has been reset successfully! You can now login with your new password.",
          () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Remove all previous routes
            );
          },
        );
      } else {
        _showErrorDialog(
          "Reset Failed",
          "Failed to reset password: ${result['message']}",
        );
      }
    } catch (e) {
      print("Error in password reset: $e");
      _showErrorDialog(
        "Error",
        "An error occurred while resetting password. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
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

  void _showSuccessDialog(
    String title,
    String message,
    VoidCallback onPressed,
  ) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.teal, size: 50),
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
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    bool showStrengthIndicator = false,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
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
                obscureText: !isVisible,
                validator: validator,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.teal.shade600,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.teal.shade600,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.teal.shade600,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2D3D), Color(0xFF11877C), Color(0xFF0D6B5E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          10 *
                          ((_shakeController.value * 4).floor() % 2 == 0
                              ? 1
                              : -1),
                      0,
                    ),
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.lock_reset,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Reset Password",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Create a new secure password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Mobile number display
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.teal.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.teal.shade600,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Mobile: ${widget.mobileNumber}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // New Password Field
                              _buildPasswordField(
                                controller: _newPasswordController,
                                label: "New Password",
                                hint: "Enter your new password",
                                isVisible: _isNewPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter new password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  return null;
                                },
                                showStrengthIndicator: true,
                              ),

                              const SizedBox(height: 10),

                              // Password Strength Indicator
                              if (_newPasswordController.text.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: _getPasswordStrength(),
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _getPasswordStrengthColor(),
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _getPasswordStrengthText(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getPasswordStrengthColor(),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Confirm Password Field
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                label: "Confirm Password",
                                hint: "Confirm your new password",
                                isVisible: _isConfirmPasswordVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 30),

                              // Submit Button
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.teal.shade600,
                                      Colors.teal.shade700,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.3),
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed:
                                      _isLoading ? null : _handlePasswordReset,
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            "Reset Password",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Back to Login
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    color: Colors.teal.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
