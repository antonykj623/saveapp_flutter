

import 'package:flutter/material.dart';
import 'package:new_project_2025/view_model/Task/notification_service/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
    DeviceOrientation.portraitDown,
  ]);
  
  await TaskNotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const TestNotificationPage(),
    );
  }
}

class TestNotificationPage extends StatefulWidget {
  const TestNotificationPage({Key? key}) : super(key: key);

  @override
  State<TestNotificationPage> createState() => _TestNotificationPageState();
}

class _TestNotificationPageState extends State<TestNotificationPage> {
  String _status = "Ready to test";
  int _pendingCount = 0;
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final hasPerms = await TaskNotificationService.checkPermissions();
    final pending = await TaskNotificationService.getPendingNotifications();
    
    setState(() {
      _hasPermissions = hasPerms;
      _pendingCount = pending.length;
      _status = hasPerms 
          ? "✅ Ready! Permissions granted" 
          : "❌ Need permissions";
    });
  }

  Future<void> _testImmediate() async {
    try {
      await TaskNotificationService.showImmediateNotification(
        id: 99999,
        title: '🎉 Test Notification',
        body: 'If you see this, notifications are working!',
      );
      
      setState(() {
        _status = "✅ Immediate notification sent!\nCheck your notification bar";
      });
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    }
  }

  Future<void> _test1Minute() async {
    try {
      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 1));
      
      final success = await TaskNotificationService.scheduleTaskNotification(
        taskId: 99998,
        taskName: 'Test Task - 1 minute',
        remindDateTime: testTime,
      );
      
      if (success) {
        setState(() {
          _status = "✅ Notification scheduled for ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}\n\n"
                    "🚀 NOW CLOSE THE APP!\n"
                    "You'll get notification in 1 minute";
        });
        await _checkSetup();
      }
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    }
  }

  Future<void> _test2Minutes() async {
    try {
      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 2));
      
      final success = await TaskNotificationService.scheduleTaskNotification(
        taskId: 99997,
        taskName: 'Test Task - 2 minutes',
        remindDateTime: testTime,
      );
      
      if (success) {
        setState(() {
          _status = "✅ Notification scheduled for ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}\n\n"
                    "🚀 NOW CLOSE THE APP!\n"
                    "You'll get notification in 2 minutes";
        });
        await _checkSetup();
      }
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _status = "Requesting permissions...";
    });
    
    final success = await TaskNotificationService.requestPermissions();
    
    setState(() {
      _hasPermissions = success;
      _status = success 
          ? "✅ Permissions granted!" 
          : "❌ Permissions denied. Check device settings.";
    });
  }

  Future<void> _cancelAll() async {
    await TaskNotificationService.cancelAllNotifications();
    setState(() {
      _status = "✅ All test notifications cancelled";
      _pendingCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Background Notifications'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _hasPermissions ? Colors.green.shade50 : Colors.red.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      _hasPermissions ? Icons.check_circle : Icons.warning,
                      size: 60,
                      color: _hasPermissions ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pending: $_pendingCount notifications',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '📋 How to Test:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Request permissions (if needed)'),
                  Text('2. Test immediate notification'),
                  Text('3. Schedule 1-minute notification'),
                  Text('4. CLOSE THIS APP COMPLETELY'),
                  Text('5. Wait for notification'),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ Make sure to swipe app away from recent apps!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Permission Button
            if (!_hasPermissions) ...[
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.security, size: 28),
                label: const Text(
                  'REQUEST PERMISSIONS',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Test Immediate
            ElevatedButton.icon(
              onPressed: _hasPermissions ? _testImmediate : null,
              icon: const Icon(Icons.bolt, size: 28),
              label: const Text(
                'TEST NOW (Immediate)',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test 1 Minute
            ElevatedButton.icon(
              onPressed: _hasPermissions ? _test1Minute : null,
              icon: const Icon(Icons.timer, size: 28),
              label: const Text(
                'SCHEDULE 1 MINUTE',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test 2 Minutes
            ElevatedButton.icon(
              onPressed: _hasPermissions ? _test2Minutes : null,
              icon: const Icon(Icons.schedule, size: 28),
              label: const Text(
                'SCHEDULE 2 MINUTES',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Refresh
            OutlinedButton.icon(
              onPressed: _checkSetup,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel All
            OutlinedButton.icon(
              onPressed: _cancelAll,
              icon: const Icon(Icons.clear_all, color: Colors.red),
              label: const Text(
                'Cancel All Test Notifications',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Success Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.celebration,
                    size: 48,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you get notification after closing app:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '🎉 BACKGROUND NOTIFICATIONS WORK! 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

