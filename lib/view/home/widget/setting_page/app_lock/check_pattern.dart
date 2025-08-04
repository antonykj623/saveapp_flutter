import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:flutter/foundation.dart' show listEquals;

class CheckPattern extends StatefulWidget {
  const CheckPattern({super.key});

  @override
  _CheckPatternState createState() => _CheckPatternState();
}

class _CheckPatternState extends State<CheckPattern>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<int>? savedPattern;
  bool isLoading = true;
  int attemptCount = 0;
  final int maxAttempts = 5;

  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _breatheController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadSavedPattern();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _breatheController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> loadSavedPattern() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patternString = prefs.getString('lock_pattern');
      final bool appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;

      debugPrint('=== CheckPattern Load ===');
      debugPrint('App Lock Enabled: $appLockEnabled');
      debugPrint('Pattern String: $patternString');
      debugPrint('=======================');

      if (appLockEnabled && patternString != null && patternString.isNotEmpty) {
        setState(() {
          savedPattern =
              patternString
                  .split(',')
                  .map((e) => int.tryParse(e))
                  .where((e) => e != null)
                  .cast<int>()
                  .toList();
          isLoading = false;
        });
      } else {
        debugPrint('No valid pattern or app lock disabled - checking token');
        await _navigateBasedOnToken();
      }
    } catch (e) {
      debugPrint('Error loading pattern: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        _showErrorSnackbar(
          'Error loading security settings. Please try again.',
        );
      }
    }
  }

  Future<void> _navigateBasedOnToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    await prefs.setBool('needs_pattern_verification', false);
    await prefs.setBool('app_was_closed_after_logout', false);

    debugPrint(
      'Token: ${token != null && token.isNotEmpty ? "Exists" : "Not found"}',
    );

    if (mounted) {
      if (token == null || token.isEmpty) {
        debugPrint('No token - navigating to LoginScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        debugPrint('Token exists - navigating to SaveApp');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SaveApp()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> handlePatternInput(List<int> input) async {
    if (listEquals<int>(input, savedPattern)) {
      try {
        _pulseController.forward();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('needs_pattern_verification', false);
        await prefs.setBool('app_was_closed_after_logout', false);

        debugPrint('Pattern verified successfully - checking token');

        _showSuccessSnackbar('Pattern Verified Successfully!');

        await Future.delayed(const Duration(milliseconds: 1500));
        await _navigateBasedOnToken();
      } catch (e) {
        debugPrint('Error saving preferences: $e');
        if (mounted) {
          _showErrorSnackbar('Error verifying pattern. Please try again.');
        }
      }
    } else {
      _shakeController.forward().then((_) => _shakeController.reset());

      setState(() {
        attemptCount++;
      });

      if (attemptCount >= maxAttempts) {
        await handleMaxAttemptsExceeded();
      } else {
        final remainingAttempts = maxAttempts - attemptCount;
        _showWarningSnackbar(
          'Incorrect Pattern',
          '$remainingAttempts ${remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining',
        );
      }
    }
  }

  Future<void> handleMaxAttemptsExceeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.setBool('needs_pattern_verification', false);
      await prefs.setBool('app_was_closed_after_logout', false);

      debugPrint(
        'Max attempts exceeded - logging out and navigating to LoginScreen',
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _buildSecurityDialog();
          },
        );
      }
    } catch (e) {
      debugPrint('Error handling max attempts: $e');
      if (mounted) {
        _showErrorSnackbar('Error during logout. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final patternSize =
        screenSize.width * 0.7 < screenSize.height * 0.4
            ? screenSize.width * 0.7
            : screenSize.height * 0.4;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ]
                    : [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                      const Color(0xFF8E2DE2),
                    ],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? _buildLoadingScreen(screenSize, isDark)
                  : SingleChildScrollView(
                    child: _buildMainContent(screenSize, isDark, patternSize),
                  ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(Size screenSize, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _breatheAnimation,
              child: Container(
                padding: EdgeInsets.all(screenSize.width * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.04),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: screenSize.height * 0.03),
            Text(
              'Initializing Security...',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenSize.width * 0.045,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              'Loading your security settings',
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Size screenSize, bool isDark, double patternSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenSize.height * 0.8),
        child: Column(
          children: [
            // Modern Header with Logo
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.03,
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _breatheAnimation,
                    child: Container(
                      padding: EdgeInsets.all(screenSize.width * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Secure Access',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.07,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Draw your pattern to unlock',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Main Pattern Area
            Container(
              margin: EdgeInsets.only(top: screenSize.height * 0.02),
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.03),

                  // Title Section
                  Column(
                    children: [
                      Text(
                        'Enter Pattern',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.07,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      Text(
                        'Connect the dots in the correct sequence',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color:
                              isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Error Count Display
                  if (attemptCount > 0) ...[
                    SizedBox(height: screenSize.height * 0.02),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Failed attempts: $attemptCount/$maxAttempts',
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.035,
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  SizedBox(height: screenSize.height * 0.03),

                  // Pattern Lock Container
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: EdgeInsets.all(screenSize.width * 0.06),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: patternSize,
                            maxHeight: patternSize,
                          ),
                          child: PatternLock(
                            selectedColor: const Color(0xFF667eea),
                            notSelectedColor:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            pointRadius: screenSize.width * 0.035,
                            showInput: true,
                            dimension: 3,
                            relativePadding: 0.7,
                            selectThreshold: 25,
                            fillPoints: true,
                            onInputComplete: handlePatternInput,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.03),

                  // Security Tips
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFF0EA5E9),
                          size: screenSize.width * 0.05,
                        ),
                        SizedBox(width: screenSize.width * 0.03),
                        Expanded(
                          child: Text(
                            'Too many failed attempts will log you out for security',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.033,
                              color: const Color(0xFF0EA5E9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Security Lockout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Too many failed pattern attempts detected. For your security, you have been automatically logged out.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Return to Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWarningSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
