import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/Design.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/check_pattern.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/set_pattern.dart';
import 'package:new_project_2025/view_model/Task/notification_service/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TaskNotificationService.initialize();
  debugPrint('✅ Notification service initialized');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Global navigator key for auto backup
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final _autoBackupService = AutoBackupService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize auto backup service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        _autoBackupService.initialize(context);
        debugPrint('✅ Auto Backup Service initialized with daily scheduler');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoBackupService.dispose();
    debugPrint('🔴 Auto Backup Service disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check auto backup when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        debugPrint('📱 App resumed - checking for pending auto backups');
        _autoBackupService.onAppResume(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SAVE App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child:
              child ??
              const MaterialApp(
                home: Scaffold(body: Center(child: Text('App Loading Error'))),
              ),
        );
      },
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
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final hasPermissions = await TaskNotificationService.checkPermissions();
      if (!hasPermissions) {
        debugPrint('⚠️ Requesting notification permissions...');
        await TaskNotificationService.requestPermissions();
      }

      await delayedFunction();
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeApp: $e');
      debugPrint('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize app: $e';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<void> delayedFunction() async {
    try {
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
            _navigateToCheckPattern();
          }
          return;
        } else {
          await prefs.setBool('needs_pattern_verification', false);
          await prefs.setBool('app_was_closed_after_logout', false);
          debugPrint('App lock disabled - cleared verification flags');
        }
      }

      if (appLockEnabled) {
        if (lockPattern != null && lockPattern.isNotEmpty) {
          debugPrint('App lock enabled with pattern - showing pattern lock');
          if (mounted) {
            _navigateToCheckPattern();
          }
          return;
        } else {
          debugPrint(
            'App lock enabled but no pattern - redirect to set pattern',
          );
          if (mounted) {
            _navigateToSetPattern();
          }
          return;
        }
      }

      debugPrint('No pattern verification needed - checking token status');
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint('No token - going to login');
        if (mounted) {
          _navigateToLogin();
        }
      } else {
        debugPrint('Token exists - going to main app');
        if (mounted) {
          _navigateToHome();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in delayedFunction: $e');
      debugPrint('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Navigation error: $e';
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint('Error navigating to login: $e');
      _showErrorAndExit();
    }
  }

  void _navigateToHome() {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SaveApp()),
      );
      debugPrint('✅ Navigated to Home - Auto backup will check shortly');
    } catch (e) {
      debugPrint('Error navigating to home: $e');
      _navigateToLogin();
    }
  }

  void _navigateToCheckPattern() {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CheckPattern()),
      );
    } catch (e) {
      debugPrint('Error navigating to check pattern: $e');
      _navigateToLogin();
    }
  }

  void _navigateToSetPattern() {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetPattern()),
      );
    } catch (e) {
      debugPrint('Error navigating to set pattern: $e');
      _navigateToLogin();
    }
  }

  void _showErrorAndExit() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Unknown error occurred',
            ),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Exit'),
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
                      debugPrint('Image loading error: $error');
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
              if (_isLoading) ...[
                const Text(
                  'Loading...',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ] else if (_errorMessage.isNotEmpty) ...[
                Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _navigateToLogin(),
                  child: const Text('Go to Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
