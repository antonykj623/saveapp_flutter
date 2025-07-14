import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    const MaterialApp(
      home: WhatsAppLauncherPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class WhatsAppLauncherPage extends StatefulWidget {
  const WhatsAppLauncherPage({super.key});

  @override
  State<WhatsAppLauncherPage> createState() => _WhatsAppLauncherPageState();
}

class _WhatsAppLauncherPageState extends State<WhatsAppLauncherPage> {
  bool _isLoading = false;

  Future<void> _launchWhatsApp() async {
    setState(() {
      _isLoading = true;
    });

    const phoneNumber = "919846290789";

    // Try WhatsApp app first
    final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber");
    final Uri webUri = Uri.parse("https://wa.me/$phoneNumber");

    try {
      // Check if WhatsApp app can be launched
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web version
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If both fail, try web version as last resort
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print("Error launching WhatsApp: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp Launcher"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child:
            _isLoading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Opening WhatsApp...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 30,
                    ),
                  ),
                  onPressed: _launchWhatsApp,
                  child: const Text(
                    "Help On WhatsApp",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
      ),
    );
  }
}
