import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmAccountScreen extends StatefulWidget {
  @override
  _ConfirmAccountScreenState createState() => _ConfirmAccountScreenState();
}

class _ConfirmAccountScreenState extends State<ConfirmAccountScreen>
    with TickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _floatingController;
  late AnimationController _formController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _particleController;

  late List<Animation<Offset>> _floatingAnimations;
  late Animation<double> _formAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late List<Animation<Offset>> _particleAnimations;

  final ApiHelper _apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _floatingAnimations = List.generate(5, (index) {
      final patterns = [
        {'begin': Offset(0, 0), 'end': Offset(0.2, -0.3)},
        {'begin': Offset(0, 0), 'end': Offset(-0.15, -0.25)},
        {'begin': Offset(0, 0), 'end': Offset(0.3, -0.2)},
        {'begin': Offset(0, 0), 'end': Offset(-0.25, -0.35)},
        {'begin': Offset(0, 0), 'end': Offset(0.1, -0.4)},
      ];

      final startInterval = (index / 5) * 0.6;
      final endInterval = startInterval + 0.4;

      return Tween<Offset>(
        begin: patterns[index]['begin']!,
        end: patterns[index]['end']!,
      ).animate(
        CurvedAnimation(
          parent: _floatingController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeInOut),
        ),
      );
    });

    _particleAnimations = List.generate(8, (index) {
      final startInterval = (index / 8) * 0.5;
      final endInterval = startInterval + 0.5;

      return Tween<Offset>(begin: Offset(0, 1), end: Offset(0, -1)).animate(
        CurvedAnimation(
          parent: _particleController,
          curve: Interval(startInterval, endInterval, curve: Curves.linear),
        ),
      );
    });

    _formController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _formController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _particleController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_mobileController.text.isEmpty || _passwordController.text.isEmpty) {
      _shakeForm();
      _showCustomSnackBar('Please fill all fields', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First verify user credentials
      final verifyResponse = await _apiHelper.verifyUserCredentials(
        _mobileController.text.trim(),
        _passwordController.text.trim(),
      );

      if (verifyResponse['status'] == 2) {
        // Credentials verified, proceed with deletion
        final deleteResponse = await _apiHelper.deleteAccount();

        if (deleteResponse['status'] == 1) {
          // Clear shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          _showCustomSnackBar('Account deleted successfully!', Colors.green);
          _mobileController.clear();
          _passwordController.clear();

          // Navigate back to login screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          _showCustomSnackBar(
            deleteResponse['message'] ?? 'Failed to delete account',
            Colors.red,
          );
        }
      } else {
        _shakeForm();
        _showCustomSnackBar(
          verifyResponse['message'] ?? 'Invalid credentials',
          Colors.red,
        );
      }
    } catch (e) {
      _shakeForm();
      _showCustomSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shakeForm() {
    HapticFeedback.vibrate();
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  color == Colors.green ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.all(20),
        elevation: 8,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
          colors: [
            Color(0xFF1A237E),
            Color(0xFF3949AB),
            Color(0xFF00BCD4),
            Color(0xFF4DD0E1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles
          ...List.generate(8, (index) {
            final positions = [
              {'left': 20.0 + (index * 45), 'size': 4.0 + (index % 3)},
              {'left': 60.0 + (index * 35), 'size': 3.0 + (index % 4)},
              {'left': 100.0 + (index * 40), 'size': 5.0 + (index % 2)},
              {'left': 30.0 + (index * 50), 'size': 2.0 + (index % 5)},
              {'left': 80.0 + (index * 30), 'size': 6.0 + (index % 3)},
              {'left': 120.0 + (index * 25), 'size': 4.0 + (index % 4)},
              {'left': 50.0 + (index * 55), 'size': 3.0 + (index % 2)},
              {'left': 90.0 + (index * 20), 'size': 5.0 + (index % 3)},
            ];

            return Positioned(
              left: positions[index]['left']!,
              child: SlideTransition(
                position: _particleAnimations[index],
                child: Container(
                  width: positions[index]['size']!,
                  height: positions[index]['size']!,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Enhanced floating elements
          ...List.generate(5, (index) {
            final elements = [
              {'top': 80.0, 'left': 30.0, 'size': 120.0, 'opacity': 0.1},
              {'top': 200.0, 'right': 20.0, 'size': 80.0, 'opacity': 0.08},
              {'bottom': 300.0, 'left': 60.0, 'size': 150.0, 'opacity': 0.12},
              {'top': 350.0, 'right': 80.0, 'size': 90.0, 'opacity': 0.09},
              {'bottom': 150.0, 'right': 30.0, 'size': 110.0, 'opacity': 0.1},
            ];

            return Positioned(
              top: elements[index]['top'],
              left: elements[index]['left'],
              right: elements[index]['right'],
              bottom: elements[index]['bottom'],
              child: SlideTransition(
                position: _floatingAnimations[index],
                child: Container(
                  width: elements[index]['size']!,
                  height: elements[index]['size']!,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(elements[index]['opacity']!),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: ScaleTransition(
                      scale: _formAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Header section with enhanced design
                          Column(
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'ACCOUNT VERIFICATION',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              ShaderMask(
                                shaderCallback:
                                    (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.white70],
                                    ).createShader(bounds),
                                child: Text(
                                  'Confirm Your Identity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Enter your credentials to proceed with account deletion',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 60),

                          // Form fields with enhanced design
                          _buildEnhancedInputField(
                            controller: _mobileController,
                            hintText: 'Mobile Number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                          ),
                          SizedBox(height: 30),
                          _buildEnhancedInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 50),

                          // Enhanced submit button
                          Container(
                            width: double.infinity,
                            height: 65,
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: _isLoading ? null : _submitForm,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors:
                                          _isLoading
                                              ? [
                                                Colors.grey.withOpacity(0.3),
                                                Colors.grey.withOpacity(0.2),
                                              ]
                                              : [
                                                Colors.white.withOpacity(0.25),
                                                Colors.white.withOpacity(0.15),
                                              ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, -5),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child:
                                        _isLoading
                                            ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                                Text(
                                                  'Verifying...',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.verified_user,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Confirm Account',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon:
              prefixIcon != null
                  ? Container(
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    child: Icon(
                      prefixIcon,
                      color: Colors.white.withOpacity(0.8),
                      size: 22,
                    ),
                  )
                  : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        ),
      ),
    );
  }
}
