import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/delete_account/delete_account.dart';
import 'package:new_project_2025/view/home/widget/profile_page/profile_page.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/App_lock.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_lock/set_pattern.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_update/version_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool appLockEnabled = false;
  String applock = "";

  Future<void> saveAppLockState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', value);
    debugPrint("Saved App Lock state: $value");
  }

  Future<void> loadAppLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      applock = prefs.getString('lock_pattern') ?? "no value";
    });
    debugPrint(
      "Loaded App Lock state: $appLockEnabled, lock_pattern: $applock",
    );
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    loadAppLockState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? The app will close after logout.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout & Exit',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check current app lock settings before logout
      bool appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      String? lockPattern = prefs.getString('lock_pattern');

      // Remove token
      await prefs.remove('token');

      // Set flags for next launch
      if (appLockEnabled && lockPattern != null && lockPattern.isNotEmpty) {
        await prefs.setBool('needs_pattern_verification', true);
        await prefs.setBool('app_was_closed_after_logout', true);
        debugPrint(
          'App lock is enabled - pattern will be required on next launch',
        );
      } else {
        await prefs.setBool('needs_pattern_verification', false);
        await prefs.setBool('app_was_closed_after_logout', false);
      }

      debugPrint('Logout completed, app will now exit');

      // Show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully. App will close.'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Delay to show snackbar, then exit
      await Future.delayed(const Duration(milliseconds: 1500));
      SystemNavigator.pop();
    } catch (e) {
      debugPrint('Error during logout: $e');
      SystemNavigator.pop();
    }
  }

  Future<void> _checkForUpdates() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00897B),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Checking for updates...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      Navigator.of(context).pop();
      await VersionCheckService.checkForAppUpdate(context);
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00897B), Color(0xFF00796B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 10),
                        _buildSectionTitle('Account'),
                        _buildSettingCard(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          subtitle: 'Manage your profile information',
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSectionTitle('App Settings'),
                        _buildSettingCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Bill Header',
                          subtitle: 'Configure bill header settings',
                          iconColor: Colors.orange,
                          onTap: () {
                            debugPrint('Bill Header tapped');
                          },
                        ),
                        _buildToggleSettingCard(
                          icon: Icons.lock_outline,
                          title: 'App Lock',
                          subtitle: 'Secure your app with lock',
                          iconColor: Colors.purple,
                          isToggled: appLockEnabled,
                          onToggle: (value) {
                            setState(() {
                              appLockEnabled = value;
                            });
                            saveAppLockState(value);
                            debugPrint('App Lock toggled: $value');
                          },
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              applock =
                                  prefs.getString('lock_pattern') ?? "no value";
                            });
                            if (appLockEnabled || applock.isEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LockPatternPage(),
                                ),
                              );
                            } else {
                              debugPrint('App Lock is disabled');
                            }
                          },
                        ),
                        _buildSectionTitle('Data Management'),
                        _buildSettingCard(
                          icon: Icons.cloud_upload_outlined,
                          title: 'Data Backup',
                          subtitle: 'Backup your data to cloud',
                          iconColor: Colors.green,
                          isDisabled: true,
                          onTap: () {
                            debugPrint('Data Backup tapped');
                          },
                        ),
                        _buildSettingCard(
                          icon: Icons.cloud_download_outlined,
                          title: 'Restore Your Data',
                          subtitle: 'Restore data from backup',
                          iconColor: Colors.teal,
                          isDisabled: true,
                          onTap: () {
                            debugPrint('Restore Your Data tapped');
                          },
                        ),
                        _buildSectionTitle('App Management'),
                        _buildSettingCard(
                          icon: Icons.system_update_outlined,
                          title: 'App Update',
                          subtitle: 'Check for latest updates',
                          iconColor: Colors.indigo,
                          onTap: _checkForUpdates,
                        ),
                        _buildSettingCard(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Purchase or Renewal',
                          subtitle: 'Manage your subscriptions',
                          iconColor: Colors.amber,
                          onTap: () {
                            debugPrint('Purchase or Renewal tapped');
                          },
                        ),
                        _buildSectionTitle('Account Actions'),
                        _buildSettingCard(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out and close app',
                          iconColor: Colors.red,
                          onTap: _showLogoutDialog,
                        ),
                        _buildSettingCard(
                          icon: Icons.delete_forever_outlined,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          iconColor: Colors.red[700]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlertToConfirmScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled ? Colors.grey : iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? Colors.grey[500] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDisabled ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDisabled ? Colors.grey[300] : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isToggled,
    required Function(bool) onToggle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isToggled,
                    onChanged: onToggle,
                    activeColor: const Color(0xFF00897B),
                    activeTrackColor: const Color(0xFF00897B).withOpacity(0.3),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
