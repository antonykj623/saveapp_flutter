import 'package:flutter/material.dart';
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

  void _navigateToScreen(BuildContext context, String title) {
    // You can match title and navigate to different screens
    Widget screen;
    switch (title) {
      // case "How to use":
      //   screen = const HowToUseScreen();
      //   break;
      // case "Help on Whatsapp":
      //   screen = const HelpOnWhatsappScreen();
      //   break;
      // case "Mail Us":
      //   screen = const MailUsScreen();
      //   break;
      // case "About Us":
      //   screen = const AboutUsScreen();
      //   break;
      // case "Privacy Policy":
      //   screen = const PrivacyPolicyScreen();
      //   break;
      // case "Terms and Conditions For Use":
      //   screen = const TermsScreen();
      //   break;
      // case "FeedBack":
      //   screen = const FeedbackScreen();
      //   break;
      // case "Share":
      //   screen = const ShareScreen();
      //   break;
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
