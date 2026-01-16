import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Common utility class for internet connectivity checks
/// Use this in any page/widget
class ConnectivityUtils {
  static final Connectivity _connectivity = Connectivity();

  /// ✅ MAIN FUNCTION: Check if internet is connected
  /// Returns: true if connected, false if not
  static Future<bool> isConnected() async {
    try {
      // Check connectivity status
      final results = await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.none)) {
        return false;
      }

      // Verify actual internet access by making a request
      return await hasInternetAccess();
    } catch (e) {
      debugPrint('❌ Connectivity check error: $e');
      return false;
    }
  }

  /// Check actual internet access
  static Future<bool> hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Show "No Internet" dialog
  static void showNoInternetDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'No Internet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Please check your internet connection and try again.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  bool connected = await isConnected();
                  if (dialogContext.mounted) {
                    if (connected) {
                      Navigator.pop(dialogContext);
                      if (context.mounted) {
                        showSuccessSnackbar(context, 'Connection restored!');
                      }
                    } else {
                      showErrorSnackbar(
                        dialogContext,
                        'Still no internet connection',
                      );
                    }
                  }
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Show "No Internet" snackbar
  static void showNoInternetSnackbar(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No internet connection',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () async {
            await isConnected();
          },
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Execute API call with connectivity check
  /// Usage: await ConnectivityUtils.executeWithConnectivity(context, () => apiCall());
  static Future<T?> executeWithConnectivity<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    bool showDialog = true,
    bool showSnackbar = false,
  }) async {
    // Check connectivity first
    bool connected = await isConnected();

    if (!connected) {
      if (context.mounted) {
        if (showDialog) {
          showNoInternetDialog(context);
        } else if (showSnackbar) {
          showNoInternetSnackbar(context);
        }
      }
      return null;
    }

    // Execute API call
    try {
      return await apiCall();
    } catch (e) {
      debugPrint('❌ API call error: $e');
      if (context.mounted) {
        showErrorSnackbar(context, 'Something went wrong. Please try again.');
      }
      return null;
    }
  }

  /// Listen to connectivity changes
  static Stream<bool> connectivityStream() {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (results.contains(ConnectivityResult.none)) {
        return false;
      }
      return await hasInternetAccess();
    });
  }
}

/// Extension to make connectivity check easier
extension ConnectivityExtension on BuildContext {
  /// Check internet and show dialog if not connected
  Future<bool> checkInternet({bool showDialog = true}) async {
    bool connected = await ConnectivityUtils.isConnected();

    if (!connected && mounted) {
      if (showDialog) {
        ConnectivityUtils.showNoInternetDialog(this);
      } else {
        ConnectivityUtils.showNoInternetSnackbar(this);
      }
    }

    return connected;
  }
}
