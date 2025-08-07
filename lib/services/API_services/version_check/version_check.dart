import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/services/API_services/version_check/version_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_update/app_update_class.dart';

// Assuming you have an ApiHelper instance or you can create one
// You'll need to import your ApiHelper class
// import 'package:new_project_2025/path/to/your/api_helper.dart';

class VersionCheckService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Check for app updates using your existing API
  static Future<void> checkForAppUpdate(BuildContext context) async {
    try {
      debugPrint('Starting app version check...');

      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String currentBuildNumber = packageInfo.buildNumber;

      debugPrint('Current app version: $currentVersion ($currentBuildNumber)');

      // Create ApiHelper instance (adjust this based on your implementation)
      final apiHelper = ApiHelper();
      
      // Call your API with timeout handling
      final AppVersionModel1 versionData = await _callApiWithTimeout(
        () => apiHelper.checkAppVersion1()
      );

      await _handleVersionResponse(context, versionData, currentVersion);

    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      _showOfflineMessage(context);
    } on TimeoutException catch (e) {
      debugPrint('Request timeout: $e');
      _showTimeoutMessage(context);
    } on FormatException catch (e) {
      debugPrint('JSON parsing error: $e');
      _showUpdateCheckError(context, 'Invalid server response');
    } catch (e) {
      debugPrint('Error during update check: $e');
      
      // Check if it's a server error (contains HTML like your GoDaddy error)
      if (e.toString().contains('html') || e.toString().contains('GoDaddy') || e.toString().contains('Origin server')) {
        _showServerDownMessage(context);
      } else {
        _showUpdateCheckError(context, e.toString());
      }
    }
  }

  /// Call API method with timeout
  static Future<T> _callApiWithTimeout<T>(Future<T> Function() apiCall) async {
    return await apiCall().timeout(
      _timeoutDuration,
      onTimeout: () {
        throw TimeoutException('Request timed out', _timeoutDuration);
      },
    );
  }

  /// Handle the version response from your API
  static Future<void> _handleVersionResponse(
    BuildContext context,
    AppVersionModel1 versionData,
    String currentVersion,
  ) async {
    try {
      // Extract version information based on your AppVersionModel structure
      // You'll need to adjust these based on your actual model properties
      String latestVersion = versionData.latestVersion ?? currentVersion;
      bool updateAvailable = versionData.updateAvailable ?? false;
      bool forceUpdate = versionData.forceUpdate ?? false;
      String updateUrl = versionData.updateUrl ?? '';
      String releaseNotes = versionData.releaseNotes ?? 'Bug fixes and improvements';

      debugPrint('Latest version: $latestVersion');
      debugPrint('Update available: $updateAvailable');
      debugPrint('Force update: $forceUpdate');

      if (updateAvailable || isNewerVersion(currentVersion, latestVersion)) {
        await _showUpdateDialog(
          context,
          latestVersion,
          currentVersion,
          forceUpdate,
          updateUrl,
          releaseNotes,
        );
      } else {
        _showNoUpdateDialog(context, currentVersion);
      }

    } catch (e) {
      debugPrint('Error processing version data: $e');
      _showUpdateCheckError(context, 'Error processing update information');
    }
  }

  /// Show server down message (specifically for your GoDaddy error)
  static void _showServerDownMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dns_outlined, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Server Unavailable',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The update server is currently unavailable. This might be due to:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                '• Server maintenance\n• Network connectivity issues\n• Firewall restrictions',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                'Please try again in a few minutes.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Retry Later',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry Now', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                checkForAppUpdate(context); // Retry
              },
            ),
          ],
        );
      },
    );
  }

  /// Show timeout message
  static void _showTimeoutMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer_off, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Timeout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'The server is taking too long to respond. Please check your internet connection and try again.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                checkForAppUpdate(context); // Retry
              },
            ),
          ],
        );
      },
    );
  }

  /// Show update available dialog
  static Future<void> _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String currentVersion,
    bool forceUpdate,
    String updateUrl,
    String releaseNotes,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.system_update, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  forceUpdate ? 'Required Update' : 'Update Available',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version ($latestVersion) is available.\nCurrent version: $currentVersion',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'What\'s new:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                releaseNotes,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (forceUpdate) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This update is required to continue using the app.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            if (!forceUpdate)
              TextButton(
                child: const Text(
                  'Later',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Update Now',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _launchUpdateUrl(updateUrl);
              },
            ),
          ],
        );
      },
    );
  }

  /// Show no update available dialog
  static void _showNoUpdateDialog(BuildContext context, String currentVersion) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'You\'re Up to Date!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'You have the latest version ($currentVersion) of the app.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show offline/network error message
  static void _showOfflineMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wifi_off, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Connection Issue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Unable to check for updates. Please check your internet connection and try again.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                checkForAppUpdate(context); // Retry
              },
            ),
          ],
        );
      },
    );
  }

  /// Show update check error dialog
  static void _showUpdateCheckError(BuildContext context, String errorMessage) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error_outline, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Update Check Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Failed to check for updates.\n\nError: $errorMessage\n\nPlease try again later.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Launch the update URL (Play Store, App Store, or direct APK)
  static Future<void> _launchUpdateUrl(String updateUrl) async {
    if (updateUrl.isEmpty) {
      debugPrint('Update URL is empty');
      return;
    }

    try {
      final Uri uri = Uri.parse(updateUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch update URL: $updateUrl');
      }
    } catch (e) {
      debugPrint('Error launching update URL: $e');
    }
  }

  /// Simple version comparison (returns true if newVersion > currentVersion)
  static bool isNewerVersion(String currentVersion, String newVersion) {
    try {
      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> newer = newVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < current.length && i < newer.length; i++) {
        if (newer[i] > current[i]) return true;
        if (newer[i] < current[i]) return false;
      }

      return newer.length > current.length;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
}

// Add this import to your settings screen
