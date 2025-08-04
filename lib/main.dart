import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/set_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/check_pattern.dart';

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
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    delayedFunction();
  }

  Future<void> delayedFunction() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    
    bool needsPatternVerification =
        prefs.getBool('needs_pattern_verification') ?? false;
    bool appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    String? lockPattern = prefs.getString('lock_pattern');
    bool appWasClosedAfterLogout =
        prefs.getBool('app_was_closed_after_logout') ?? false;

    debugPrint('=== App Launch Priority Check ===');
    debugPrint('Needs Pattern Verification: $needsPatternVerification');
    debugPrint('App Was Closed After Logout: $appWasClosedAfterLogout');
    debugPrint('App Lock Enabled: $appLockEnabled');
    debugPrint(
      'Has Lock Pattern: ${lockPattern != null && lockPattern.isNotEmpty}',
    );
    debugPrint('================================');

   
    if (needsPatternVerification || appWasClosedAfterLogout) {
      if (appLockEnabled) {
        debugPrint('Pattern verification required - showing pattern lock');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CheckPattern()),
          );
        }
        return;
      } else {
        // If app lock is disabled but verification was needed, clear the flag
        await prefs.setBool('needs_pattern_verification', false);
        await prefs.setBool('app_was_closed_after_logout', false);
        debugPrint('App lock disabled - cleared verification flags');
      }
    }

    // Priority 2: If app lock is enabled, check pattern
    if (appLockEnabled) {
      if (lockPattern != null && lockPattern.isNotEmpty) {
        debugPrint('App lock enabled with pattern - showing pattern lock');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CheckPattern()),
          );
        }
        return;
      } else {
        // No pattern set, but app lock enabled - redirect to set pattern
        debugPrint('App lock enabled but no pattern - redirect to set pattern');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SetPattern()),
          );
        }
        return;
      }
    }

    // Priority 3: Check token for login status
    debugPrint('No pattern verification needed - checking token status');
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint('No token - going to login');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      debugPrint('Token exists - going to main app');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SaveApp()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00897B), Color(0xFF00796B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    "assets/Invoice.jpg",
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'SAVE App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Loading...',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
