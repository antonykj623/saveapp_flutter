import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_project_2025/view/home/widget/More_page/how_to_use/how_to_use_page.dart';
import 'package:new_project_2025/view/home/widget/More_page/share_page/share_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final List<String> item = [
    "How to use",
    "Help on Whatsapp",
    "Mail Us",
    "About Us",
    'Privacy Policy',
    "Terms and Conditions For Use",
    "FeedBack",
    'Share',
  ];

  // URLs for web pages
  final Map<String, String> _webUrls = {
    "About Us": "https://mysaveapp.com/web/about",
    "Privacy Policy": "https://mysaveapp.com/web/privacy_policy",
    "Terms and Conditions For Use":
        "https://mysaveapp.com/web/terms_conditions",
  };

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
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
    );
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = "919846290789";
    
    // Try different WhatsApp URL formats
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
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WhatsApp is not installed or could not be opened"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _launchWebUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // First try to launch with platformDefault mode
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } else {
        // If platformDefault fails, try externalApplication
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print("Error launching $url: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open the page. Please check your internet connection."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    const String email = 'ramanpalissery@gmail.com';
    const String subject = 'Support Request from Save App';
    
    // Try different email launch methods
    final List<String> emailUrls = [
      'mailto:$email?subject=${Uri.encodeComponent(subject)}',
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=${Uri.encodeComponent(subject)}',
    ];

    bool launched = false;
    
    for (String urlString in emailUrls) {
      try {
        final Uri uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No email client found. Please install an email app."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToScreen(BuildContext context, String title) {
    // Check if the title corresponds to a web URL
    if (_webUrls.containsKey(title)) {
      _launchWebUrl(_webUrls[title]!);
      return;
    }

    // Handle WhatsApp and Email separately
    if (title == "Help on Whatsapp") {
      _launchWhatsApp();
      return;
    }

    if (title == "Mail Us") {
      _launchEmail();
      return;
    }

    // Navigate to other screens
    Widget screen;
    switch (title) {
      case "How to use":
        screen = HowtouseScreen();
        break;
      case "FeedBack":
        screen = const Scaffold(
          body: Center(child: Text("Feedback Screen")),
        ); // Placeholder
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