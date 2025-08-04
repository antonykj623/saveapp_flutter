import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show listEquals;

class SetPattern extends StatefulWidget {
  @override
  _SetPatternState createState() => _SetPatternState();
}

class _SetPatternState extends State<SetPattern>
    with TickerProviderStateMixin {
  bool isConfirm = false;
  bool isVerifyingOldPattern = false;
  List<int>? pattern;
  List<int>? savedPattern;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadSavedPattern();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> loadSavedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final patternString = prefs.getString('lock_pattern');
    if (patternString != null) {
      setState(() {
        savedPattern = patternString.split(',').map((e) => int.parse(e)).toList();
        isVerifyingOldPattern = true;
      });
    }
  }

  Future<void> savePatternToPrefs(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final patternString = pattern.join(',');
    await prefs.setString('lock_pattern', patternString);
    print("Saved pattern: $patternString");
  }

  String get _getTitle {
    if (isVerifyingOldPattern) return "Verify Current Pattern";
    if (isConfirm) return "Confirm New Pattern";
    return "Create New Pattern";
  }

  String get _getSubtitle {
    if (isVerifyingOldPattern) return "Draw your existing pattern to continue";
    if (isConfirm) return "Draw the same pattern again";
    return "Connect at least 3 dots to create your pattern";
  }

  IconData get _getCurrentIcon {
    if (isVerifyingOldPattern) return Icons.verified_user_rounded;
    if (isConfirm) return Icons.check_circle_outline_rounded;
    return Icons.gesture_rounded;
  }

  Color get _getAccentColor {
    if (isVerifyingOldPattern) return const Color(0xFF0EA5E9);
    if (isConfirm) return const Color(0xFF10B981);
    return const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final patternSize = screenSize.width * 0.75;

    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    const Color(0xFF334155),
                  ]
                : [
                    _getAccentColor.withOpacity(0.1),
                    _getAccentColor.withOpacity(0.05),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Modern Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.06,
                    vertical: screenSize.height * 0.02,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : _getAccentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : _getAccentColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? Colors.white : _getAccentColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pattern Setup',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                fontSize: screenSize.width * 0.055,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Secure your application',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF6B7280),
                                fontSize: screenSize.width * 0.035,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.only(top: screenSize.height * 0.02),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.06),
                        child: Column(
                          children: [
                            // Drag Indicator
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            SizedBox(height: screenSize.height * 0.04),

                            // Status Icon & Title
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getAccentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _getAccentColor.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _getCurrentIcon,
                                  size: 40,
                                  color: _getAccentColor,
                                ),
                              ),
                            ),

                            SizedBox(height: screenSize.height * 0.03),

                            // Title & Subtitle
                            Text(
                              _getTitle,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.065,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: screenSize.height * 0.01),

                            Text(
                              _getSubtitle,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04,
                                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const Spacer(),

                            // Pattern Lock
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: patternSize,
                                    maxHeight: patternSize,
                                  ),
                                  child: PatternLock(
                                    selectedColor: _getAccentColor,
                                    notSelectedColor: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    pointRadius: screenSize.width * 0.035,
                                    showInput: true,
                                    dimension: 3,
                                    relativePadding: 0.7,
                                    selectThreshold: 25,
                                    fillPoints: true,
                                    onInputComplete: _handlePatternInput,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Progress Indicator
                            if (!isVerifyingOldPattern) _buildProgressIndicator(isDark),

                            SizedBox(height: screenSize.height * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(1, !isConfirm, isDark),
        Container(
          width: 40,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isConfirm
                ? _getAccentColor
                : isDark
                    ? Colors.grey[700]
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        _buildStepIndicator(2, isConfirm, isDark),
      ],
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? _getAccentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? _getAccentColor
              : isDark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: isActive
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
            : Text(
                '$step',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePatternInput(List<int> input) async {
    if (input.length < 3) {
      _showCustomSnackbar(
        "Pattern too short",
        "Connect at least 3 dots to create a secure pattern",
        Colors.red,
        Icons.error_outline_rounded,
      );
      return;
    }

    if (isVerifyingOldPattern) {
      if (listEquals<int>(input, savedPattern)) {
        setState(() {
          isVerifyingOldPattern = false;
          pattern = null;
          isConfirm = false;
        });
        _showCustomSnackbar(
          "Pattern Verified",
          "You can now create a new pattern",
          Colors.green,
          Icons.check_circle_outline_rounded,
        );
      } else {
        _showCustomSnackbar(
          "Incorrect Pattern",
          "Please try again with your current pattern",
          Colors.red,
          Icons.lock_outline_rounded,
        );
      }
    } else if (isConfirm) {
      if (listEquals<int>(input, pattern)) {
        await savePatternToPrefs(pattern!);
        _showCustomSnackbar(
          "Pattern Saved Successfully",
          "Your app is now secured with the new pattern",
          Colors.green,
          Icons.shield_rounded,
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(pattern);
        });
      } else {
        _showCustomSnackbar(
          "Patterns Don't Match",
          "Please draw the same pattern again",
          Colors.red,
          Icons.refresh_rounded,
        );
        setState(() {
          pattern = null;
          isConfirm = false;
        });
      }
    } else {
      setState(() {
        pattern = input;
        isConfirm = true;
      });
      _showCustomSnackbar(
        "Pattern Created",
        "Now confirm your pattern by drawing it again",
        _getAccentColor,
        Icons.repeat_rounded,
      );
    }
  }

  void _showCustomSnackbar(String title, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}