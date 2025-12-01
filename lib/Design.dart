import 'package:flutter/material.dart';
import 'package:new_project_2025/services/Back_and_Restore/Backupand_restore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AutoBackupService {
  static final AutoBackupService _instance = AutoBackupService._internal();
  factory AutoBackupService() => _instance;
  AutoBackupService._internal();

  final BackupController _backupController = BackupController();
  bool _isChecking = false;
  Timer? _dailyTimer;

  /// Initialize auto backup service - call this in main.dart or app startup
  Future<void> initialize(BuildContext context) async {
    // Check immediately on app start
    await checkAndPerformAutoBackup(context);

    // Schedule daily check at 12:00 AM
    _scheduleDailyBackup(context);
  }

  /// Schedule backup to run daily at 12:00 AM
  void _scheduleDailyBackup(BuildContext context) {
    _dailyTimer?.cancel();

    // Calculate time until next 12:00 AM
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 0, 0);

    // If it's already past midnight today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    final duration = scheduledTime.difference(now);

    debugPrint(
      'Auto backup scheduled in ${duration.inHours} hours ${duration.inMinutes % 60} minutes',
    );

    // Schedule the backup
    _dailyTimer = Timer(duration, () {
      performDailyBackup(context);
      // Reschedule for next day
      _scheduleDailyBackup(context);
    });
  }

  Future<void> performDailyBackup(BuildContext context) async {
    debugPrint('Performing daily auto backup at ${DateTime.now()}');
    await _backupController.performDailyAutoBackups(context);
  }

  Future<void> checkAndPerformAutoBackup(BuildContext context) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      final shouldServerBackup =
          await _backupController.shouldPerformAutoServerBackup();
      if (shouldServerBackup) {
        debugPrint('Performing auto server backup on app start');
        await _backupController.performAutoServerBackup(context);
      }

      
      final shouldDriveBackup =
          await _backupController.shouldPerformAutoDriveBackup();
      if (shouldDriveBackup) {
        debugPrint('Performing auto drive backup on app start');
        await _backupController.performAutoDriveBackup(context);
      }
    } catch (e) {
      debugPrint('Auto backup check error: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Call this when app comes to foreground
  Future<void> onAppResume(BuildContext context) async {
    await checkAndPerformAutoBackup(context);
  }

  /// Dispose timers when not needed
  void dispose() {
    _dailyTimer?.cancel();
  }

  /// Get status information for UI
  Future<Map<String, dynamic>> getBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'server_enabled': await _backupController.isAutoServerBackupEnabled(),
      'drive_enabled': await _backupController.isAutoDriveBackupEnabled(),
      'last_server_backup': prefs.getString('last_auto_server_backup_date'),
      'last_drive_backup': prefs.getString('last_auto_drive_backup_date'),
      'next_backup_time': _getNextBackupTime(),
    };
  }

  String _getNextBackupTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0);
    final difference = tomorrow.difference(now);

    if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'soon (at 12:00 AM)';
    }
  }
}
