import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/app/Modules/login/password_rest_screen/password_rest_screen.dart';
import 'package:new_project_2025/services/API_services/sms_helper/sms_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleOTPVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String purpose; // 'forgot_password' or 'registration'

  const SimpleOTPVerificationScreen({
    Key? key,
    required this.mobileNumber,
    required this.purpose,
  }) : super(key: key);

  @override
  State<SimpleOTPVerificationScreen> createState() =>
      _SimpleOTPVerificationScreenState();
}

class _SimpleOTPVerificationScreenState
    extends State<SimpleOTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _resendTimer = 60;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(_animationController);
    _startResendTimer();
    // Defer autofill to after the first frame to avoid build scope issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoFillOTP();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    if (!mounted) return;
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _autoFillOTP() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedOTP = prefs.getString('${widget.purpose}_otp');

      if (savedOTP != null &&
          savedOTP.length == 4 &&
          _otpController.text.isEmpty) {
        setState(() {
          _otpController.text = savedOTP;
        });
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
      }
    } catch (e) {
      print("Error auto-filling OTP: $e");
    }
  }

  Future<void> _verifyOTP() async {
    if (!mounted) return;

    String enteredOTP = _otpController.text.trim();
    if (enteredOTP.length != 4 || !RegExp(r'^\d{4}$').hasMatch(enteredOTP)) {
      _showErrorDialog("Invalid OTP", "Please enter a valid 4-digit OTP.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedOTP = prefs.getString('${widget.purpose}_otp');
      int? otpTimestamp = prefs.getInt('otp_timestamp');

      if (savedOTP == null || otpTimestamp == null) {
        if (mounted) {
          _showErrorDialog(
            "Error",
            "OTP session expired. Please request a new OTP.",
          );
        }
        return;
      }

      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - otpTimestamp > 600000) {
        // 10 minutes
        if (mounted) {
          _showErrorDialog(
            "OTP Expired",
            "The OTP has expired. Please request a new OTP.",
          );
        }
        return;
      }

      if (enteredOTP == savedOTP) {
        if (widget.purpose == 'forgot_password') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PasswordResetScreen(mobileNumber: widget.mobileNumber),
            ),
          );
        } else {
          // Handle registration OTP verification
          _showSuccessDialog("OTP Verified", "OTP verified successfully!", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
        }
      } else {
        _showErrorDialog("Invalid OTP", "The OTP you entered is incorrect.");
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      _showErrorDialog(
        "Error",
        "An error occurred while verifying OTP. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!mounted || !_isResendEnabled) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SMSHelper.sendForgotPasswordOTP(widget.mobileNumber);
      if (result['success']) {
        int newOTP = SMSHelper.generateFourDigitNumber();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('${widget.purpose}_otp', newOTP.toString());
        await prefs.setInt(
          'otp_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        _startResendTimer();
        _showSuccessDialog(
          "OTP Resent",
          "A new OTP has been sent to ${widget.mobileNumber}.",
          () => Navigator.pop(context),
        );
      } else {
        _showErrorDialog(
          "Resend Failed",
          "Failed to resend OTP: ${result['message']}",
        );
      }
    } catch (e) {
      print("Error resending OTP: $e");
      _showErrorDialog(
        "Error",
        "An error occurred while resending OTP. Please try again.",
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
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
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
                  backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2D3D), Color(0xFF11877C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_open, color: Colors.teal, size: 50),
                      const SizedBox(height: 20),
                      Text(
                        "Enter OTP",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "A 4-digit OTP has been sent to ${widget.mobileNumber}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: "OTP",
                                prefixIcon: const Icon(
                                  Icons.vpn_key,
                                  color: Colors.teal,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length != 4) {
                                  return 'Please enter a valid 4-digit OTP';
                                }
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _isResendEnabled ? _resendOTP : null,
                            child: Text(
                              _isResendEnabled
                                  ? "Resend OTP"
                                  : "Resend in $_resendTimer s",
                              style: TextStyle(
                                color:
                                    _isResendEnabled
                                        ? Colors.teal
                                        : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _verifyOTP,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text("Verify OTP"),
                          ),
                        ],
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
