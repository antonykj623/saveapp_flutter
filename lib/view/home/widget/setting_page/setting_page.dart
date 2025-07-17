import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/profile_page/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF00897B),
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool appLockEnabled = false;

  // Function to show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _handleLogout(); // Proceed with logout
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle logout
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token from SharedPreferences
    print('Logout tapped, token removed');

    // Navigate to LoginScreen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        child: ListView(
          children: [
            _buildSettingItem(
              title: 'Profile',
              hasToggle: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            _buildSettingItem(
              title: 'Bill Header',
              hasToggle: false,
              onTap: () {
                print('Bill Header tapped');
              },
            ),
            _buildSettingItem(
              title: 'App Lock',
              hasToggle: true,
              isToggled: appLockEnabled,
              onToggle: (value) {
                setState(() {
                  appLockEnabled = value;
                });
                print('App Lock toggled: $value');
              },
              onTap: () {},
            ),
            _buildSettingItem(
              title: 'Data Backup',
              textColor: Colors.grey[600],
              hasToggle: false,
              onTap: () {
                print('Data Backup tapped');
              },
            ),
            _buildSettingItem(
              title: 'Restore Your Data',
              textColor: Colors.grey[600],
              hasToggle: false,
              onTap: () {
                print('Restore Your Data tapped');
              },
            ),
            _buildSettingItem(
              title: 'App Update',
              hasToggle: false,
              onTap: () {
                print('App Update tapped');
              },
            ),
            _buildSettingItem(
              title: 'Purchase or Renewal',
              hasToggle: false,
              onTap: () {
                print('Purchase or Renewal tapped');
              },
            ),
            _buildSettingItem(
              title: 'Logout',

              hasToggle: false,
              onTap: _showLogoutDialog,
            ),
            _buildSettingItem(
              title: 'Delete Account',
              hasToggle: false,
              onTap: () {
                print('Delete Account tapped');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    Color? textColor,
    required bool hasToggle,
    bool isToggled = false,
    Function(bool)? onToggle,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.black,
          ),
        ),
        trailing:
            hasToggle
                ? Switch(
                  value: isToggled,
                  onChanged: onToggle,
                  activeTrackColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                  activeColor: Colors.white,
                )
                : const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
