import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class BackupController {
  final String baseUrl = "https://mysaving.in/IntegraAccount";
  static const platform = MethodChannel('com.mysave.filemanager/channel');

  // ============================ MANUAL DRIVE BACKUP ============================
  Future<void> uploadToDrive(BuildContext context) async {
    try {
      _showLoadingDialog(context, "Preparing backup file...");

      final backupData = await _collectAllDatabaseData();
      final jsonString = jsonEncode(backupData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'MySaving_Backup_$timestamp.json';

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      Navigator.pop(context);

      _showLoadingDialog(context, "Opening file picker...");
      
      final result = await platform.invokeMethod('saveBackupFile', {
        'fileName': fileName,
        'filePath': filePath,
      });

      Navigator.pop(context);

      if (result == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_drive_backup_date', DateTime.now().toString());
        
        _showSuccessDialog(
          context,
          "Backup Saved!",
          "Backup file created successfully.\nYou can upload it to Drive, save it locally, or share it.",
        );
      } else if (result == 'cancelled') {
        _showInfoDialog(context, "Backup cancelled by user");
      } else {
        _showErrorDialog(context, "Failed to save backup file");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, "Backup failed: $e");
    }
  }

  // ============================ MANUAL DRIVE RESTORE ============================
  Future<void> restoreFromDrive(BuildContext context) async {
    try {
      _showLoadingDialog(context, "Opening file picker...");

      final result = await platform.invokeMethod('openBackupFile');

      Navigator.pop(context);

      if (result == null || result == 'cancelled') {
        _showInfoDialog(context, "No file selected");
        return;
      }

      final confirm = await _showConfirmDialog(context);
      if (confirm != true) return;

      _showLoadingDialog(context, "Reading backup file...");

      final filePath = result as String;
      final file = File(filePath);
      
      if (!await file.exists()) {
        Navigator.pop(context);
        _showErrorDialog(context, "File not found!");
        return;
      }

      final jsonString = await file.readAsString();
      Map<String, dynamic> backupData;
      
      try {
        backupData = jsonDecode(jsonString);
      } catch (e) {
        Navigator.pop(context);
        _showErrorDialog(context, "Invalid backup file format!");
        return;
      }

      _updateLoadingMessage(context, "Restoring data...");

      await DatabaseHelper().close();
      await _restoreAllDatabaseData(backupData);
      await DatabaseHelper().database;

      Navigator.pop(context);
      _showSuccessDialog(
        context,
        "Restore Successful!",
        "All data restored from backup file.",
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, "Restore failed: $e");
    }
  }

  // ============================ SERVER BACKUP (Manual) ============================
  Future<void> uploadBackup(BuildContext context) async {
    try {
      _showLoadingDialog(context, "Preparing backup...");

      final backupData = await _collectAllDatabaseData();
      final jsonString = jsonEncode(backupData);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        Navigator.pop(context);
        _showErrorDialog(context, "Please login first");
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/uploadBackupFile.php'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'data': jsonString,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 1 || result['success'] == true) {
          await prefs.setString('last_backup_date', DateTime.now().toString());
          _showSuccessDialog(
            context,
            "Server Backup Complete!",
            "Data saved to cloud server safely.",
          );
        } else {
          _showErrorDialog(context, result['message'] ?? "Upload failed");
        }
      } else {
        _showErrorDialog(context, "Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, "Error: $e");
    }
  }

  // ============================ SERVER RESTORE ============================
  Future<void> downloadAndRestore(BuildContext context) async {
    final confirm = await _showConfirmDialog(context);
    if (confirm != true) return;

    try {
      _showLoadingDialog(context, "Connecting...");

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        Navigator.pop(context);
        _showErrorDialog(context, "Login required!");
        return;
      }

      final userId = await _getUserId();
      final backupUrl = '$baseUrl/backups/$userId.json';

      final response = await http.get(
        Uri.parse(backupUrl),
        headers: {'Authorization': token, 'Accept': 'application/json'},
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        Map<String, dynamic> backupData;
        try {
          backupData = jsonDecode(response.body);
        } catch (e) {
          _showErrorDialog(context, "Backup file corrupted.\nPlease upload again.");
          return;
        }

        _showLoadingDialog(context, "Restoring data...");

        await DatabaseHelper().close();
        await _restoreAllDatabaseData(backupData);
        await DatabaseHelper().database;

        Navigator.pop(context);
        _showSuccessDialog(
          context,
          "Restore Successful!",
          "All data restored from server.",
        );
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        _showErrorDialog(context, "Access denied!\nPlease login again.");
      } else if (response.statusCode == 404) {
        _showErrorDialog(context, "No backup found!\nPlease create a backup first.");
      } else {
        _showErrorDialog(context, "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, "Restore failed: $e");
    }
  }

  // ============================ DATABASE OPERATIONS ============================
  Future<Map<String, dynamic>> _collectAllDatabaseData() async {
    final db = await _openDatabase();
    final Map<String, dynamic> backup = {};

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    for (var t in tables) {
      final tableName = t['name'] as String;
      final rows = await db.query(tableName);
      if (rows.isNotEmpty) {
        backup[tableName] = rows
            .map((r) => r.map((k, v) => MapEntry(k, v is Uint8List ? base64Encode(v) : v)))
            .toList();
      }
    }

    backup['_metadata'] = {'backup_time': DateTime.now().toIso8601String()};
    return backup;
  }

  Future<void> _restoreAllDatabaseData(Map<String, dynamic> data) async {
    final db = await _openDatabase();

    try {
      await db.transaction((txn) async {
        final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );
        for (var t in tables) {
          await txn.delete(t['name'] as String);
        }

        for (var entry in data.entries) {
          if (entry.key == '_metadata') continue;
          final rows = entry.value as List;
          for (var raw in rows) {
            final row = Map<String, dynamic>.from(raw);
            row.forEach((k, v) {
              if (v is String &&
                  v.length > 20 &&
                  RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(v) &&
                  v.length % 4 == 0) {
                try {
                  row[k] = base64Decode(v);
                } catch (_) {}
              }
            });
            await txn.insert(entry.key, row, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
    } finally {}
  }

  Future<Database> _openDatabase() async {
    return await DatabaseHelper().database;
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? "229";
  }

  // ============================ AUTO BACKUP SETTINGS ============================
  
  // Auto Server Backup
  Future<bool> isAutoServerBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_server_backup_enabled') ?? false;
  }

  Future<void> setAutoServerBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_server_backup_enabled', enabled);
    if (enabled) {
      await prefs.setString('auto_server_backup_enabled_date', DateTime.now().toString());
    }
  }

  // Auto Drive Backup
  Future<bool> isAutoDriveBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_drive_backup_enabled') ?? false;
  }

  Future<void> setAutoDriveBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_drive_backup_enabled', enabled);
    if (enabled) {
      await prefs.setString('auto_drive_backup_enabled_date', DateTime.now().toString());
    }
  }

  // Check if auto backup should run (daily at 12:00 AM)
  Future<bool> shouldPerformAutoServerBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = await isAutoServerBackupEnabled();
    
    if (!enabled) return false;

    final lastBackup = prefs.getString('last_auto_server_backup_date');
    if (lastBackup == null) return true;

    final lastBackupDate = DateTime.parse(lastBackup);
    final now = DateTime.now();

    // Check if it's a new day
    return now.difference(lastBackupDate).inDays >= 1;
  }

  Future<bool> shouldPerformAutoDriveBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = await isAutoDriveBackupEnabled();
    
    if (!enabled) return false;

    final lastBackup = prefs.getString('last_auto_drive_backup_date');
    if (lastBackup == null) return true;

    final lastBackupDate = DateTime.parse(lastBackup);
    final now = DateTime.now();

    // Check if it's a new day
    return now.difference(lastBackupDate).inDays >= 1;
  }

  // Perform auto server backup (silently)
  Future<void> performAutoServerBackup(BuildContext context) async {
    try {
      final shouldBackup = await shouldPerformAutoServerBackup();
      if (!shouldBackup) return;

      final backupData = await _collectAllDatabaseData();
      final jsonString = jsonEncode(backupData);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) return;

      final response = await http.post(
        Uri.parse('$baseUrl/api/uploadBackupFile.php'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'data': jsonString,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 1 || result['success'] == true) {
          await prefs.setString('last_backup_date', DateTime.now().toString());
          await prefs.setString('last_auto_server_backup_date', DateTime.now().toString());
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Auto Server backup completed'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Auto server backup error: $e');
    }
  }

  // Perform auto drive backup (silently)
  Future<void> performAutoDriveBackup(BuildContext context) async {
    try {
      final shouldBackup = await shouldPerformAutoDriveBackup();
      if (!shouldBackup) return;

      final backupData = await _collectAllDatabaseData();
      final jsonString = jsonEncode(backupData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'MySaving_AutoBackup_$timestamp.json';

      // Save to app's documents directory (accessible to user)
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/AutoBackups';
      final backupDir = Directory(filePath);
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final file = File('$filePath/$fileName');
      await file.writeAsString(jsonString);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_drive_backup_date', DateTime.now().toString());
      await prefs.setString('last_auto_drive_backup_date', DateTime.now().toString());
      await prefs.setString('last_auto_drive_backup_path', file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Auto Drive backup saved to:\n${file.path}')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print('Auto drive backup error: $e');
    }
  }

  // Main auto backup check - call this daily at 12:00 AM
  Future<void> performDailyAutoBackups(BuildContext context) async {
    // Check and perform both types of auto backups
    await performAutoServerBackup(context);
    await performAutoDriveBackup(context);
  }

  // ============================ UI DIALOGS ============================
  void _showLoadingDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF00897B)),
              SizedBox(height: 20),
              Text(msg, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _updateLoadingMessage(BuildContext context, String msg) {
    Navigator.pop(context);
    _showLoadingDialog(context, msg);
  }

  void _showSuccessDialog(BuildContext c, String t, String m) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Flexible(child: Text(t)),
          ],
        ),
        content: Text(m),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            child: Text("OK"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext c, String m) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("Error"),
          ],
        ),
        content: Text(m),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            child: Text("OK"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext c, String m) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Text("Info"),
          ],
        ),
        content: Text(m),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(c),
            child: Text("OK"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext c) {
    return showDialog<bool>(
      context: c,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Restore Backup?"),
        content: Text("This will replace ALL current data.\nContinue?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text("Restore"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}