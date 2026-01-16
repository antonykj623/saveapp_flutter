import 'package:flutter/material.dart';
import 'package:new_project_2025/services/connectivity_service/connectivity_service.dart';
import 'package:new_project_2025/view/home/widget/More_page/feedback/feed_back.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_project_2025/view/home/widget/More_page/how_to_use/how_to_use_page.dart';
import 'package:new_project_2025/view/home/widget/More_page/share_page/share_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'dart:async';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  // ✅ ADD: Stream subscription for connectivity
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true;

  final List<String> item = [
    "How to use",
    "Help on Whatsapp",
    "Mail Us",
    "About Us",
    'Privacy Policy',
    "Terms and Conditions For Use",
    "FeedBack",
    'Share',
    'Cancellation and Refund policy',
  ];

  final Map<String, String> _webUrls = {
    "About Us": "https://mysaveapp.com/web/about",
    "Privacy Policy": "https://mysaveapp.com/web/privacy_policy",
    "Terms and Conditions For Use":
        "https://mysaveapp.com/web/terms_conditions",
    "Cancellation and Refund policy":
        "https://mysaveapp.com/web/cancellation_refund",
  };

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // ✅ NEW: Check initial connection status
  Future<void> _checkInitialConnection() async {
    bool connected = await ConnectivityUtils.isConnected();
    setState(() {
      _isConnected = connected;
    });
  }

  // ✅ NEW: Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = ConnectivityUtils.connectivityStream().listen((
      isConnected,
    ) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        // Show message when connection changes
        if (isConnected) {
          ConnectivityUtils.showSuccessSnackbar(
            context,
            '✓ Internet connection restored',
          );
        } else {
          ConnectivityUtils.showNoInternetSnackbar(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ✅ NEW: Connection status indicator
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.shade600,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _checkInitialConnection,
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
            ),
          Expanded(
            child: SizedBox(
              height: screenSize.height,
              width: screenSize.width,
              child: ListView.builder(
                itemCount: item.length,
                itemBuilder: (context, index) {
                  return _buildReportItem1(
                    title: item[index],
                    onTap: () {
                      _navigateToScreen(context, item[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    if (!await context.checkInternet(showDialog: false)) {
      return;
    }

    const phoneNumber = "919846290789";

    final List<String> whatsappUrls = [
      "whatsapp://send?phone=$phoneNumber",
      "https://wa.me/$phoneNumber",
      "https://api.whatsapp.com/send?phone=$phoneNumber",
    ];

    bool launched = false;

    for (String urlString in whatsappUrls) {
      try {
        final Uri uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        print("Failed to launch $urlString: $e");
        continue;
      }
    }

    if (!launched) {
      if (mounted) {
        ConnectivityUtils.showErrorSnackbar(
          context,
          "WhatsApp is not installed or could not be opened",
        );
      }
    }
  }

  Future<void> _launchWebUrl(String url) async {
    if (!await context.checkInternet(showDialog: false)) {
      return;
    }

    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error launching $url: $e");
      if (mounted) {
        bool stillConnected = await ConnectivityUtils.isConnected();

        if (!stillConnected) {
          ConnectivityUtils.showNoInternetSnackbar(context);
        } else {
          ConnectivityUtils.showErrorSnackbar(
            context,
            "Could not open the page. Please try again.",
          );
        }
      }
    }
  }

  Future<void> _launchEmail() async {
    if (!await context.checkInternet(showDialog: false)) {
      return;
    }

    const String email = 'ramanpalissery@gmail.com';
    const String subject = 'Support Request from Save App';

    final List<String> emailUrls = [
      'mailto:$email?subject=${Uri.encodeComponent(subject)}',
      'intent://compose?to=$email&subject=${Uri.encodeComponent(subject)}#Intent;scheme=mailto;package=com.google.android.gm;end',
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=${Uri.encodeComponent(subject)}',
    ];

    bool launched = false;

    for (String urlString in emailUrls) {
      try {
        final Uri uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (e) {
        print("Failed to launch $urlString: $e");
        continue;
      }
    }

    if (!launched) {
      if (mounted) {
        ConnectivityUtils.showErrorSnackbar(
          context,
          "Could not open Gmail. Please install Gmail app or check your email settings.",
        );
      }
    }
  }

  void _navigateToScreen(BuildContext context, String title) {
    if (_webUrls.containsKey(title)) {
      _launchWebUrl(_webUrls[title]!);
      return;
    }

    if (title == "Help on Whatsapp") {
      _launchWhatsApp();
      return;
    }

    if (title == "Mail Us") {
      _launchEmail();
      return;
    }

    Widget screen;
    switch (title) {
      case "How to use":
        screen = HowtouseScreen();
        break;
      case "FeedBack":
        screen = const FeedbackPage();
        break;
      case "Share":
        screen = const SharePage();
        break;
      default:
        screen = SaveApp();
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildReportItem1({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 10,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
