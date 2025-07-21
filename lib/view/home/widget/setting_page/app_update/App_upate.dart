import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionChecker {
  
  // Method 1: Using package_info_plus (Recommended)
  static Future<String> getCurrentVersionUsingPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      
      print('App Name: $appName');
      print('Package Name: $packageName');
      print('Version: $version');
      print('Build Number: $buildNumber');
      
      return version; // Returns version like "1.0.0"
    } catch (e) {
      print('Error getting package info: $e');
      return "1.0.0"; // Fallback version
    }
  }
  
  // Method 2: Using package_info_plus with full info
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
        'appName': 'Unknown',
        'packageName': 'com.example.app',
        'version': '1.0.0',
        'buildNumber': '1',
        'versionWithBuild': '1.0.0+1',
      };
    }
  }
  
  // Method 3: Using Platform Channel (Your current method)
  static Future<String> getCurrentVersionUsingPlatformChannel() async {
    try {
      const platform = MethodChannel('app_version_channel');
      final String version = await platform.invokeMethod('getAppVersion');
      return version;
    } catch (e) {
      print('Platform channel error: $e');
      return "1.0.0"; // Fallback version
    }
  }
  
  // Method 4: Reading from pubspec.yaml (Build time only - not recommended for runtime)
  // This method requires adding pubspec.yaml as an asset and is not practical for runtime
  
  // Method 5: Combined approach with multiple fallbacks
  static Future<String> getCurrentVersionWithFallbacks() async {
    // Try package_info_plus first (most reliable)
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty) {
        return packageInfo.version;
      }
    } catch (e) {
      print('Package info failed: $e');
    }
    
    // Try platform channel as fallback
    try {
      const platform = MethodChannel('app_version_channel');
      final String version = await platform.invokeMethod('getAppVersion');
      if (version.isNotEmpty) {
        return version;
      }
    } catch (e) {
      print('Platform channel failed: $e');
    }
    
    // Final fallback
    return "1.0.0";
  }
}

// Example usage widget
class VersionDisplayWidget extends StatefulWidget {
  @override
  _VersionDisplayWidgetState createState() => _VersionDisplayWidgetState();
}

class _VersionDisplayWidgetState extends State<VersionDisplayWidget> {
  String currentVersion = "Loading...";
  Map<String, String> fullAppInfo = {};
  
  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }
  
  Future<void> _loadVersionInfo() async {
    // Get current version
    String version = await VersionChecker.getCurrentVersionUsingPackageInfo();
    
    // Get full app info
    Map<String, String> appInfo = await VersionChecker.getFullAppInfo();
    
    setState(() {
      currentVersion = version;
      fullAppInfo = appInfo;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Version Info'),
        backgroundColor: Color(0xFF00897B),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Version Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('App Name: ${fullAppInfo['appName'] ?? 'Loading...'}'),
                    Text('Package: ${fullAppInfo['packageName'] ?? 'Loading...'}'),
                    Text('Version: ${fullAppInfo['version'] ?? 'Loading...'}'),
                    Text('Build: ${fullAppInfo['buildNumber'] ?? 'Loading...'}'),
                    Text('Full Version: ${fullAppInfo['versionWithBuild'] ?? 'Loading...'}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Test different methods
                String method1 = await VersionChecker.getCurrentVersionUsingPackageInfo();
                String method2 = await VersionChecker.getCurrentVersionUsingPlatformChannel();
                String method3 = await VersionChecker.getCurrentVersionWithFallbacks();
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Version Check Results'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Package Info: $method1'),
                        Text('Platform Channel: $method2'),
                        Text('With Fallbacks: $method3'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Test All Methods'),
            ),
          ],
        ),
      ),
    );
  }
}