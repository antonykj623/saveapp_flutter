// File: lib/services/task_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class TaskNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();
      
      _initialized = true;
      debugPrint('✅ TaskNotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing TaskNotificationService: $e');
    }
  }

  /// Request notification permissions
  static Future<bool> _requestPermissions() async {
    try {
      // Request notification permission
      var notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied) {
        notificationStatus = await Permission.notification.request();
      }

      // Request exact alarm permission (Android 12+)
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (alarmStatus.isDenied) {
        alarmStatus = await Permission.scheduleExactAlarm.request();
      }

      debugPrint('📱 Notification Permission: ${notificationStatus.name}');
      debugPrint('⏰ Exact Alarm Permission: ${alarmStatus.name}');

      return notificationStatus.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // You can add navigation logic here
    // Example: Navigate to task detail page
  }

  /// Schedule a task notification
  static Future<bool> scheduleTaskNotification({
    required int taskId,
    required String taskName,
    required DateTime remindDateTime,
  }) async {
    try {
      // Ensure service is initialized
      if (!_initialized) {
        await initialize();
      }

      // Check if notification time is in the future
      if (remindDateTime.isBefore(DateTime.now())) {
        debugPrint('⚠️ Notification time is in the past, skipping...');
        return false;
      }

      // Convert DateTime to TZDateTime
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        remindDateTime,
        tz.local,
      );

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_channel_01', // Channel ID - must be unique
        'Task Reminders', // Channel name
        channelDescription: 'Notifications for scheduled tasks and reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        ticker: 'Task Reminder',
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      // Combined notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        taskId, // Unique ID for each task
        '📋 Task Reminder', // Notification title
        taskName, // Notification body
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task_$taskId', // Data to pass when notification is tapped
      );

      debugPrint('✅ Notification scheduled successfully!');
      debugPrint('   Task ID: $taskId');
      debugPrint('   Task Name: $taskName');
      debugPrint('   Scheduled Time: $scheduledDate');
      
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
      return false;
    }
  }

  /// Cancel a specific task notification
  static Future<void> cancelTaskNotification(int taskId) async {
    try {
      await _notifications.cancel(taskId);
      debugPrint('✅ Notification cancelled for Task ID: $taskId');
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Show immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      // Ensure service is initialized
      if (!_initialized) {
        await initialize();
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_channel_01',
        'Task Reminders',
        channelDescription: 'Notifications for scheduled tasks',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, notificationDetails);
      debugPrint('✅ Immediate notification sent: $title');
    } catch (e) {
      debugPrint('❌ Error showing immediate notification: $e');
    }
  }

  /// Check if permissions are granted
  static Future<bool> checkPermissions() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      
      return notificationStatus.isGranted && 
             (alarmStatus.isGranted || alarmStatus.isLimited);
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Manually request permissions (if needed)
  static Future<bool> requestPermissions() async {
    return await _requestPermissions();
  }
}