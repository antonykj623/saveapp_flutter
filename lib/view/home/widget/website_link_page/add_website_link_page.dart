import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/Website_link_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class AddEditWebLinkPage extends StatefulWidget {
  final WebLink? webLink;
  final bool isEdit;
  final Function(WebLink) onSave;

  AddEditWebLinkPage({this.webLink, this.isEdit = false, required this.onSave});

  @override
  _AddEditWebLinkPageState createState() => _AddEditWebLinkPageState();
}

class _AddEditWebLinkPageState extends State<AddEditWebLinkPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _websiteLinkController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _descriptionController;

  // Animation controllers for modern effects
  late AnimationController _buttonHoverController;
  late AnimationController _backgroundController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _websiteLinkController = TextEditingController(
      text: widget.webLink?.websiteLink ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.webLink?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.webLink?.password ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.webLink?.description ?? '',
    );

  
    _buttonHoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonHoverController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _websiteLinkController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _buttonHoverController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  // Map original border types to new border types
  String _mapBorderType(String originalType) {
    switch (originalType) {
      case 'cyber':
        return 'electric';
      case 'aurora':
        return 'rainbow';
      case 'matrix':
        return 'neon'; // Matrix maps to neon for green digital effect
      case 'galaxy':
        return 'ocean'; // Galaxy maps to ocean for a cosmic feel
      case 'plasma':
        return 'fire';
      case 'neon':
        return 'neon';
      default:
        return 'electric';
    }
  }

  // Define custom colors to match original ModernAnimatedBorderWidget
  List<Color> _getCustomColors(String borderType) {
    switch (borderType) {
      case 'cyber':
        return [
          Colors.transparent,
          Color(0xFF00D4FF).withOpacity(0.3),
          Color(0xFF0099FF),
          Color(0xFF00FFFF),
          Color(0xFF39FF14),
          Color(0xFF00FFFF),
          Color(0xFF0099FF),
          Colors.transparent,
        ];
      case 'aurora':
        return [
          Colors.transparent,
          Color(0xFF00FF87).withOpacity(0.4),
          Color(0xFF60EFFF),
          Color(0xFF00FF87),
          Color(0xFFFFE66D),
          Color(0xFF00FF87),
          Color(0xFF60EFFF),
          Colors.transparent,
        ];
      case 'matrix':
        return [
          Colors.transparent,
          Color(0xFF39FF14).withOpacity(0.3),
          Color(0xFF39FF14),
          Color(0xFF00FF00),
          Color(0xFF32CD32),
          Color(0xFF00FF00),
          Color(0xFF39FF14),
          Colors.transparent,
        ];
      case 'galaxy':
        return [
          Colors.transparent,
          Color(0xFF9B59B6).withOpacity(0.4),
          Color(0xFF8E44AD),
          Color(0xFFE74C3C),
          Color(0xFFF39C12),
          Color(0xFFE74C3C),
          Color(0xFF8E44AD),
          Colors.transparent,
        ];
      case 'plasma':
        return [
          Colors.transparent,
          Color(0xFFFF6B6B).withOpacity(0.4),
          Color(0xFFFF8E8E),
          Color(0xFFFFB347),
          Color(0xFFFFD93D),
          Color(0xFFFFB347),
          Color(0xFFFF8E8E),
          Colors.transparent,
        ];
      case 'neon':
        return [
          Colors.transparent,
          Color(0xFF667eea).withOpacity(0.4),
          Color(0xFF764ba2),
          Color(0xFF89f7fe),
          Color(0xFF66a6ff),
          Color(0xFF89f7fe),
          Color(0xFF764ba2),
          Colors.transparent,
        ];
      default:
        return [Colors.grey.shade300];
    }
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    required String borderType,
    bool isDestructive = false,
  }) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: AnimatedBorderWidget(
            borderType: _mapBorderType(borderType),
            customColors: _getCustomColors(borderType),
            borderWidth: 2.0,
            glowSize: 6.0,
            borderRadius: BorderRadius.circular(25),
            isActive: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: onPressed,
                  onTapDown: (_) => _buttonHoverController.forward(),
                  onTapUp: (_) => _buttonHoverController.reverse(),
                  onTapCancel: () => _buttonHoverController.reverse(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    Colors.grey[100]!,
                    Colors.purple[50]!,
                    _backgroundAnimation.value * 0.3,
                  )!,
                  Color.lerp(
                    Colors.grey[100]!,
                    Colors.blue[50]!,
                    _backgroundAnimation.value * 0.2,
                  )!,
                  Colors.grey[100]!,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Modern Header with glassmorphism
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                  Color(0xFFf093fb),
                                ],
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.isEdit
                                        ? 'Edit WebLink'
                                        : 'Add WebLink',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Form fields with animated borders
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: [
                                // Website Link Field
                                AnimatedTextField(
                                  controller: _websiteLinkController,
                                  labelText: "Website Link",
                                  borderType: _mapBorderType("cyber"),
                                  customColors: _getCustomColors("cyber"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a website link';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.language_rounded,
                                    color: Colors.cyan[400],
                                    size: 26,
                                  ),
                                  borderRadius: 20,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.92,
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Username Field
                                AnimatedTextField(
                                  controller: _usernameController,
                                  labelText: "Username",
                                  borderType: _mapBorderType("aurora"),
                                  customColors: _getCustomColors("aurora"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.person_rounded,
                                    color: Colors.green[400],
                                    size: 26,
                                  ),
                                  borderRadius: 20,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.92,
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Password Field
                                AnimatedTextField(
                                  controller: _passwordController,
                                  labelText: "Password",
                                  borderType: _mapBorderType("matrix"),
                                  customColors: _getCustomColors("matrix"),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.lock_rounded,
                                    color: Colors.green[500],
                                    size: 26,
                                  ),
                                  borderRadius: 20,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.92,
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Description Field
                                AnimatedTextField(
                                  controller: _descriptionController,
                                  labelText: "Description",
                                  borderType: _mapBorderType("galaxy"),
                                  customColors: _getCustomColors("galaxy"),
                                  maxLines: 4,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a description';
                                    }
                                    return null;
                                  },
                                  prefixIcon: Icon(
                                    Icons.description_rounded,
                                    color: Colors.purple[400],
                                    size: 26,
                                  ),
                                  borderRadius: 20,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.92,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Modern Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                              vertical: 20.0,
                            ),
                            child: Row(
                              children: [
                                // Cancel Button
                                Expanded(
                                  child: _buildModernButton(
                                    text: 'Cancel',
                                    borderType: "plasma",
                                    gradientColors: [
                                      Color(0xFFFF6B6B),
                                      Color(0xFFEE5A52),
                                      Color(0xFFFF8E8E),
                                    ],
                                    onPressed: () => Navigator.pop(context),
                                    isDestructive: true,
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Save/Update Button
                                Expanded(
                                  child: _buildModernButton(
                                    text: widget.isEdit ? 'Update' : 'Add',
                                    borderType: "neon",
                                    gradientColors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                      Color(0xFF89f7fe),
                                    ],
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Text('Processing Data...'),
                                                ],
                                              ),
                                              backgroundColor:
                                                  Colors.blueGrey[800],
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              margin: EdgeInsets.all(16),
                                            ),
                                          );

                                          final webdata =
                                              _websiteLinkController.text;
                                          final uname =
                                              _usernameController.text;
                                          final passw =
                                              _passwordController.text;
                                          final des =
                                              _descriptionController.text;
                                          final keyId = widget.webLink?.keyId;

                                          Map<String, dynamic> weblinkData = {
                                            "weblink": webdata,
                                            "username": uname,
                                            "password": passw,
                                            "desc": des,
                                          };

                                          if (widget.isEdit && keyId != null) {
                                            await DatabaseHelper().updateData(
                                              "TABLE_WEBLINKS",
                                              {'data': jsonEncode(weblinkData)},
                                              keyId,
                                            );
                                          } else {
                                            await DatabaseHelper().addData(
                                              "TABLE_WEBLINKS",
                                              jsonEncode(weblinkData),
                                            );
                                          }

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Weblink ${widget.isEdit ? 'updated' : 'added'} successfully!',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor:
                                                    Colors.green[600],
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                            Navigator.of(context).pop(true);
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Error: $e',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor:
                                                    Colors.red[600],
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBorderWidget extends StatefulWidget {
  final Widget child;
  final String
  borderType; // 'electric', 'rainbow', 'fire', 'ocean', 'neon', 'custom'
  final List<Color>? customColors;
  final double borderWidth;
  final double glowSize;
  final int animationDuration; // in milliseconds
  final BorderRadius? borderRadius;
  final bool isActive; // Controls when animation starts/stops

  const AnimatedBorderWidget({
    Key? key,
    required this.child,
    this.borderType = 'electric',
    this.customColors,
    this.borderWidth = 3.0,
    this.glowSize = 20.0,
    this.animationDuration = 2500,
    this.borderRadius,
    this.isActive = true,
  }) : super(key: key);

  @override
  _AnimatedBorderWidgetState createState() => _AnimatedBorderWidgetState();
}

class _AnimatedBorderWidgetState extends State<AnimatedBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );

    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedBorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors() {
    if (widget.customColors != null) {
      return widget.customColors!;
    }

    switch (widget.borderType) {
      case 'electric':
        return [
          Colors.transparent,
          Color(0xFF00D4FF).withOpacity(0.3),
          Color(0xFF0099FF).withOpacity(0.6),
          Color(0xFF0066FF),
          Color(0xFF3366FF),
          Color(0xFF6633FF),
          Color(0xFF9933FF),
          Color(0xFFCC33FF),
          Color(0xFF9933FF),
          Color(0xFF6633FF),
          Color(0xFF3366FF),
          Color(0xFF0066FF),
          Colors.transparent,
        ];
      case 'rainbow':
        return [
          Colors.transparent,
          Colors.red.withOpacity(0.3),
          Colors.orange.withOpacity(0.6),
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
          Colors.pink,
          Colors.purple,
          Colors.indigo,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange.withOpacity(0.6),
          Colors.red.withOpacity(0.3),
          Colors.transparent,
        ];
      case 'fire':
        return [
          Colors.transparent,
          Color(0xFFFF6B35).withOpacity(0.3),
          Color(0xFFFF8C42).withOpacity(0.6),
          Color(0xFFFFA500),
          Color(0xFFFFD700),
          Color(0xFFFF6347),
          Color(0xFFFF4500),
          Color(0xFFDC143C),
          Color(0xFFB22222),
          Color(0xFFDC143C),
          Color(0xFFFF4500),
          Color(0xFFFF6347),
          Color(0xFFFFD700),
          Color(0xFFFFA500),
          Colors.transparent,
        ];
      case 'ocean':
        return [
          Colors.transparent,
          Color(0xFF00CED1).withOpacity(0.3),
          Color(0xFF20B2AA).withOpacity(0.6),
          Color(0xFF008B8B),
          Color(0xFF00FFFF),
          Color(0xFF40E0D0),
          Color(0xFF48D1CC),
          Color(0xFF00CED1),
          Color(0xFF5F9EA0),
          Color(0xFF00CED1),
          Color(0xFF48D1CC),
          Color(0xFF40E0D0),
          Color(0xFF00FFFF),
          Color(0xFF008B8B),
          Colors.transparent,
        ];
      case 'neon':
        return [
          Colors.transparent,
          Color(0xFFFF073A).withOpacity(0.3),
          Color(0xFFFF073A).withOpacity(0.6),
          Color(0xFFFF073A),
          Color(0xFF39FF14),
          Color(0xFF00FFFF),
          Color(0xFFFF1493),
          Color(0xFFFFFF00),
          Color(0xFF9400D3),
          Color(0xFFFFFF00),
          Color(0xFFFF1493),
          Color(0xFF00FFFF),
          Color(0xFF39FF14),
          Color(0xFFFF073A),
          Colors.transparent,
        ];
      default:
        return [Colors.grey.shade300];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomAnimatedBorder(
          borderSize: widget.isActive ? widget.borderWidth : 1.0,
          glowSize: widget.isActive ? widget.glowSize : 0.0,
          gradientColors:
              widget.isActive ? _getGradientColors() : [Colors.grey.shade300],
          animationProgress: _animationController.value,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          child: widget.child,
        );
      },
    );
  }
}

class CustomAnimatedBorder extends StatelessWidget {
  final Widget child;
  final double borderSize;
  final double glowSize;
  final List<Color> gradientColors;
  final double animationProgress;
  final BorderRadius borderRadius;

  const CustomAnimatedBorder({
    Key? key,
    required this.child,
    required this.borderSize,
    required this.glowSize,
    required this.gradientColors,
    required this.animationProgress,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow:
            glowSize > 0
                ? [
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 2]
                                .withOpacity(0.8)
                            : Colors.blue.withOpacity(0.8),
                    blurRadius: glowSize,
                    spreadRadius: glowSize / 4,
                  ),
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 3]
                                .withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                    blurRadius: glowSize * 1.5,
                    spreadRadius: glowSize / 3,
                  ),
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 4]
                                .withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                    blurRadius: glowSize * 2,
                    spreadRadius: glowSize / 2,
                  ),
                ]
                : null,
      ),
      child: CustomPaint(
        painter: AnimatedBorderPainter(
          borderSize: borderSize,
          gradientColors: gradientColors,
          animationProgress: animationProgress,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class AnimatedBorderPainter extends CustomPainter {
  final double borderSize;
  final List<Color> gradientColors;
  final double animationProgress;
  final BorderRadius borderRadius;

  AnimatedBorderPainter({
    required this.borderSize,
    required this.gradientColors,
    required this.animationProgress,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gradientColors.length <= 1) {
      // Static border for inactive state
      final paint =
          Paint()
            ..color =
                gradientColors.isNotEmpty ? gradientColors.first : Colors.grey
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderSize;

      final rect = Rect.fromLTWH(
        borderSize / 2,
        borderSize / 2,
        size.width - borderSize,
        size.height - borderSize,
      );
      final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
      canvas.drawRRect(rrect, paint);
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
    final path = Path()..addRRect(rrect);
    final pathMetrics =
        path.computeMetrics().toList(); // Fixed typo: toockedList -> toList

    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final totalLength = pathMetric.length;

      if (totalLength > 0) {
        final trainLength = totalLength * 0.4;
        final trainPosition = (animationProgress * totalLength) % totalLength;

        // Draw main gradient train
        _drawGradientTrain(
          canvas,
          pathMetric,
          totalLength,
          trainLength,
          trainPosition,
        );

        // Draw sparkle effects
        _drawSparkleEffects(
          canvas,
          pathMetric,
          totalLength,
          trainPosition,
          trainLength,
        );

        // Draw trailing glow
        _drawTrailingGlow(
          canvas,
          pathMetric,
          totalLength,
          trainPosition,
          trainLength,
        );
      }
    }
  }

  void _drawGradientTrain(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainLength,
    double trainPosition,
  ) {
    for (int i = 0; i < gradientColors.length; i++) {
      final segmentLength = trainLength / gradientColors.length;
      final segmentStart =
          (trainPosition - trainLength / 2 + i * segmentLength) % totalLength;
      final segmentEnd = (segmentStart + segmentLength) % totalLength;

      final paint =
          Paint()
            ..color = gradientColors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderSize
            ..strokeCap = StrokeCap.round;

      try {
        if (segmentStart < segmentEnd && segmentEnd <= totalLength) {
          final segmentPath = pathMetric.extractPath(segmentStart, segmentEnd);
          canvas.drawPath(segmentPath, paint);
        } else if (segmentStart >= 0 && segmentStart < totalLength) {
          if (segmentStart < totalLength) {
            final segmentPath1 = pathMetric.extractPath(
              segmentStart,
              totalLength,
            );
            canvas.drawPath(segmentPath1, paint);
          }
          if (segmentEnd > 0) {
            final segmentPath2 = pathMetric.extractPath(
              0,
              math.min(segmentEnd, totalLength),
            );
            canvas.drawPath(segmentPath2, paint);
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  void _drawSparkleEffects(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainPosition,
    double trainLength,
  ) {
    final sparklePositions = [
      (trainPosition + trainLength * 0.2) % totalLength,
      (trainPosition + trainLength * 0.5) % totalLength,
      (trainPosition + trainLength * 0.8) % totalLength,
    ];

    final sparklePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill;

    final sparkleGlowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      try {
        if (pos >= 0 && pos <= totalLength) {
          final tangent = pathMetric.getTangentForOffset(pos);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5, sparkleGlowPaint);
            canvas.drawCircle(tangent.position, 2, sparklePaint);
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  void _drawTrailingGlow(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainPosition,
    double trainLength,
  ) {
    final trailStart = (trainPosition - trainLength * 0.6) % totalLength;
    final trailEnd = (trainPosition - trainLength * 0.3) % totalLength;

    final trailPaint =
        Paint()
          ..color =
              gradientColors.isNotEmpty
                  ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.3)
                  : Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderSize * 1.5
          ..strokeCap = StrokeCap.round;

    try {
      if (trailStart < trailEnd && trailEnd <= totalLength) {
        final trailPath = pathMetric.extractPath(trailStart, trailEnd);
        canvas.drawPath(trailPath, trailPaint);
      }
    } catch (e) {
      // Continue if there's an error
    }
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.borderSize != borderSize ||
        oldDelegate.gradientColors != gradientColors;
  }
}

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String borderType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final int borderRadius;
  final Color backgroundColor;
  final List<Color>? customColors;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.borderType = 'electric',
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.customColors,
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBorderWidget(
      borderType: widget.borderType,
      customColors: widget.customColors,
      isActive: _isFocused,
      borderWidth: _isFocused ? 3.0 : 1.5,
      glowSize: _isFocused ? 12.0 : 0.0,
      borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius.toDouble()),
          color:
              _isFocused
                  ? widget.backgroundColor.withOpacity(0.95)
                  : widget.backgroundColor.withOpacity(0.92),
          boxShadow:
              _isFocused
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _isFocused ? Colors.blue[700] : Colors.grey[600],
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
            ),
            prefixIcon:
                widget.prefixIcon != null
                    ? Padding(
                      padding: EdgeInsets.only(left: 8, right: 12),
                      child: widget.prefixIcon,
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 8 : 24,
              vertical: widget.maxLines > 1 ? 20 : 18,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
