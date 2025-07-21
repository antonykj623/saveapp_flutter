import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_update/app_update_class.dart';

class VersionCheckService {
  static final ApiHelper _apiHelper = ApiHelper();

  // Your specific Play Store URL
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.mysaving.integraaccounts';

  // Method 1: Get current app version using package_info_plus (Recommended)
  static Future<String> getCurrentAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version; // Returns version like "1.0.0"
    } catch (e) {
      print('Package info error: $e');

      // Fallback to platform channel
      try {
        const platform = MethodChannel('app_version_channel');
        final String version = await platform.invokeMethod('getAppVersion');
        return version;
      } catch (e2) {
        print('Platform channel error: $e2');
        // Final fallback
        return "1.0.0";
      }
    }
  }

  // Method 2: Get full app information
  static Future<Map<String, String>> getFullAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'versionWithBuild': '${packageInfo.version}+${packageInfo.buildNumber}',
      };
    } catch (e) {
      print('Error getting full app info: $e');
      return {
        'appName': 'IntegraAccounts',
        'packageName': 'com.mysaving.integraaccounts',
        'version': '1.0.0',
        'buildNumber': '1',
        'versionWithBuild': '1.0.0+1',
      };
    }
  }

  // Method 3: Alternative version check with build number
  static Future<String> getCurrentVersionWithBuild() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      print('Error getting version with build: $e');
      return "1.0.0+1";
    }
  }

  static Future<void> checkForAppUpdate(BuildContext context) async {
    try {
      // Get current app version dynamically using package_info_plus
      String currentAppVersion = await getCurrentAppVersion();

      // Get full app info for debugging
      Map<String, String> appInfo = await getFullAppInfo();
      print('App Info: $appInfo');

      // Check server version
      AppVersionModel versionResponse = await _apiHelper.checkAppVersion();

      if (versionResponse.status == 1) {
        String serverVersion = versionResponse.data.appVersion;

        print('Current Version: $currentAppVersion');
        print('Server Version: $serverVersion');

        // Always show version comparison dialog
        _showVersionComparisonDialog(
          context,
          currentAppVersion,
          serverVersion,
          versionResponse.data.filepath,
        );
      } else {
        _showErrorDialog(context, "Failed to fetch version information");
      }
    } catch (e) {
      print('Version check failed: $e');
      _showErrorDialog(context, e.toString());
    }
  }

  static void _showVersionComparisonDialog(
    BuildContext context,
    String currentVersion,
    String serverVersion,
    String updateUrl,
  ) {
    bool updateAvailable = _isUpdateRequired(currentVersion, serverVersion);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and animation
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        updateAvailable
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    updateAvailable ? Icons.system_update : Icons.verified,
                    color: updateAvailable ? Colors.orange : Colors.blue,
                    size: 48,
                  ),
                ),

                SizedBox(height: 20),

                // Title
                Text(
                  updateAvailable ? 'Update Available!' : 'You\'re Up to Date!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Version info card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Version:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            currentVersion,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Latest Version:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  updateAvailable
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              serverVersion,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Description
                Text(
                  updateAvailable
                      ? 'A new version is available with exciting features and improvements. Update now to enjoy the latest experience!'
                      : 'Great! You have the latest version of the app with all the newest features.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    if (updateAvailable) ...[
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _launchPlayStore();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00897B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Update Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00897B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Great!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _isUpdateRequired(String currentVersion, String serverVersion) {
    try {
      // Clean version strings (remove any build numbers)
      String cleanCurrent = currentVersion.split('+')[0];
      String cleanServer = serverVersion.split('+')[0];

      List<int> current = cleanCurrent.split('.').map(int.parse).toList();
      List<int> server = cleanServer.split('.').map(int.parse).toList();

      // Ensure both lists have the same length by padding with zeros
      while (current.length < server.length) current.add(0);
      while (server.length < current.length) server.add(0);

      for (int i = 0; i < current.length; i++) {
        if (server[i] > current[i]) return true;
        if (server[i] < current[i]) return false;
      }
      return false;
    } catch (e) {
      print('Version comparison error: $e');
      return false;
    }
  }

  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                ),
                SizedBox(height: 20),
                Text(
                  'Update Check Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to check for updates at the moment. Please check your internet connection and try again later.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _launchPlayStore() async {
    try {
      final Uri playStoreUri = Uri.parse(_playStoreUrl);

      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Try to launch using platform channel
        try {
          const platform = MethodChannel('app_update_channel');
          await platform.invokeMethod('launchURL', {'url': _playStoreUrl});
        } catch (e) {
          print('Could not launch Play Store: $e');
          // Final fallback: copy URL to clipboard
          Clipboard.setData(ClipboardData(text: _playStoreUrl));
          print('Play Store URL copied to clipboard: $_playStoreUrl');
        }
      }
    } catch (e) {
      print('Error launching Play Store: $e');
      // Copy URL to clipboard as fallback
      Clipboard.setData(ClipboardData(text: _playStoreUrl));
      print('Play Store URL copied to clipboard: $_playStoreUrl');
    }
  }

  // Utility method to show current version info (for debugging)
  static Future<void> showCurrentVersionInfo(BuildContext context) async {
    Map<String, String> appInfo = await getFullAppInfo();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF00897B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Color(0xFF00897B),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'App Version Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildInfoRow('App Name', appInfo['appName'] ?? 'Unknown'),
                _buildInfoRow('Package', appInfo['packageName'] ?? 'Unknown'),
                _buildInfoRow('Version', appInfo['version'] ?? 'Unknown'),
                _buildInfoRow(
                  'Build Number',
                  appInfo['buildNumber'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  'Full Version',
                  appInfo['versionWithBuild'] ?? 'Unknown',
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
