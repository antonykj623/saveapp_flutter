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

class _CheckPatternState extends State<CheckPattern> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<int>? savedPattern;
  bool isLoading = true;
  int attemptCount = 0;
  final int maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    loadSavedPattern();
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
        // If app lock is disabled or no pattern exists, check token
        debugPrint('No valid pattern or app lock disabled - checking token');
        await _navigateBasedOnToken();
      }
    } catch (e) {
      debugPrint('Error loading pattern: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading security settings. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateBasedOnToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Clear verification flags
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('needs_pattern_verification', false);
        await prefs.setBool('app_was_closed_after_logout', false);

        debugPrint('Pattern verified successfully - checking token');

        // After successful pattern verification, check token
        await _navigateBasedOnToken();
      } catch (e) {
        debugPrint('Error saving preferences: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error verifying pattern. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        attemptCount++;
      });

      if (attemptCount >= maxAttempts) {
        await handleMaxAttemptsExceeded();
      } else {
        final remainingAttempts = maxAttempts - attemptCount;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Wrong pattern! $remainingAttempts attempts remaining",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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
            return AlertDialog(
              title: const Text('Security Alert'),
              content: const Text(
                'Too many failed pattern attempts. For security reasons, you have been logged out.',
              ),
              actions: [
                TextButton(
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
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error handling max attempts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final patternLockSize = screenSize.width * 0.8; // 80% of screen width

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00897B), Color(0xFF00796B)],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loading security settings...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.04,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Custom App Bar
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05,
                            vertical: screenSize.height * 0.02,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: screenSize.width * 0.03),
                              Flexible(
                                child: Text(
                                  'App Lock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenSize.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Main Content
                        Container(
                          constraints: BoxConstraints(
                            minHeight: screenSize.height * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Draw your pattern",
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.065,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenSize.height * 0.01),
                                  if (attemptCount > 0)
                                    Text(
                                      "Attempts: $attemptCount/$maxAttempts",
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.035,
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              SizedBox(height: screenSize.height * 0.05),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: patternLockSize,
                                  maxHeight: patternLockSize,
                                ),
                                child: PatternLock(
                                  selectedColor: const Color(0xFF00897B),
                                  notSelectedColor: Colors.grey[300]!,
                                  pointRadius: screenSize.width * 0.03,
                                  showInput: true,
                                  dimension: 3,
                                  relativePadding: 0.7,
                                  selectThreshold: 25,
                                  fillPoints: true,
                                  onInputComplete: handlePatternInput,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
