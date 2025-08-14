import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/API_services/API_services.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  List<dynamic> notifications = [];
  bool isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    fetchNotifications();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  Future<void> fetchNotifications() async {
    ApiHelper api = ApiHelper();

    try {
      List<dynamic> fetchedNotifications = await api.getNotifications();

      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });

      // Start entrance animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: List.generate(15, (index) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            double angle =
                (_rotationAnimation.value + (index * 0.2)) * 2 * math.pi;
            double radius = 100 + (index * 20);
            double x = math.cos(angle) * radius;
            double y = math.sin(angle) * radius;

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x,
              top: MediaQuery.of(context).size.height / 2 + y,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        _buildFloatingParticles(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.teal.withOpacity(0.3),
                            Colors.teal.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/appicon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 30),
                      child: Column(
                        children: [
                          Text(
                            "All Caught Up! 🎉",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No new notifications to show",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(painter: LoadingPainter()),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value * 0.6,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/appicon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: (math.sin(value * math.pi * 4) + 1) / 2,
                child: Text(
                  "Loading Notifications...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[700],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 300, 0),
            child: Opacity(
              opacity: value,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.teal.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.teal.withOpacity(0.05)],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Hero(
                        tag: 'notification_$index',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal[400]!, Colors.teal[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/appicon.png',
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.teal.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        notification["title"] ?? "No title",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            notification["message"] ?? "No message",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.1),
                                  Colors.teal.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.teal.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _formatDate(notification["created_date"]),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.withOpacity(0.1),
                              Colors.teal.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.teal[600],
                          size: 24,
                        ),
                      ),
                      onTap: () {
                        _showNotificationDetails(notification, index);
                      },
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Unknown date";

    try {
      DateTime date = DateTime.parse(dateString);
      Duration difference = DateTime.now().difference(date);

      if (difference.inDays > 7) {
        return DateFormat('MMM dd, yyyy').format(date);
      } else if (difference.inDays > 0) {
        return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return dateString.split(" ").first;
    }
  }

  void _showNotificationDetails(dynamic notification, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.teal.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    SizedBox(height: 20),
                    Hero(
                      tag: 'notification_$index',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal[400]!, Colors.teal[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/appicon.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.teal.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        notification["title"] ?? "No title",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Text(
                            notification["message"] ?? "No message",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal[400]!, Colors.teal[600]!],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                "Got it! ✨",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal[400]!, Colors.teal[600]!, Colors.teal[800]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated wave background
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(_rotationAnimation.value),
                    child: Container(),
                  );
                },
              ),
              // Floating particles constellation
              ...List.generate(12, (index) {
                return AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    double angle =
                        (_rotationAnimation.value + (index * 0.3)) *
                        2 *
                        math.pi;
                    double radius = 40 + (index * 12);
                    double x = math.cos(angle) * radius;
                    double y = math.sin(angle) * radius;

                    return Positioned(
                      left: MediaQuery.of(context).size.width * 0.8 + x,
                      top: 25 + y,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 2 + (index % 3),
                            height: 2 + (index % 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.4 * _pulseAnimation.value,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }),
              // Animated gradient orbs
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    double angle =
                        (_rotationAnimation.value + (index * 2)) * math.pi;
                    double x = math.cos(angle) * (50 + index * 30);
                    double y = math.sin(angle) * 20;

                    return Positioned(
                      right: 60 + x,
                      top: 30 + y,
                      child: Container(
                        width: 20 + (index * 5),
                        height: 20 + (index * 5),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
              // Main AppBar content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back button with glow effect
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.9 + (0.1 * _pulseAnimation.value),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 16),
                      // Title section with enhanced animations
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    // Animated app icon with multiple effects
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale:
                                              0.85 +
                                              (0.15 * _pulseAnimation.value),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            margin: EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.9),
                                                  Colors.white.withOpacity(0.7),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  blurRadius: 12,
                                                  spreadRadius: 3,
                                                ),
                                                BoxShadow(
                                                  color: Colors.teal
                                                      .withOpacity(0.3),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/appicon.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Title with typewriter effect
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Notifications",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 5,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        AnimatedBuilder(
                                          animation: _rotationController,
                                          builder: (context, child) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.2,
                                                    ),
                                                    Colors.white.withOpacity(
                                                      0.1,
                                                    ),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          notifications.isEmpty
                                                              ? Colors.grey[300]
                                                              : Colors
                                                                  .greenAccent,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              notifications
                                                                      .isEmpty
                                                                  ? Colors.grey
                                                                      .withOpacity(
                                                                        0.3,
                                                                      )
                                                                  : Colors
                                                                      .greenAccent
                                                                      .withOpacity(
                                                                        0.6,
                                                                      ),
                                                          blurRadius: 4,
                                                          spreadRadius: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    notifications.isEmpty
                                                        ? "All clear"
                                                        : "${notifications.length} new",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Enhanced refresh button with ripple effect
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  setState(() {
                                    notifications.clear();
                                    isLoading = true;
                                  });
                                  fetchNotifications();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Transform.rotate(
                                    angle: _rotationAnimation.value * 2,
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.withOpacity(0.1), Colors.grey[50]!],
          ),
        ),
        child:
            isLoading
                ? _buildLoadingState()
                : notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                  onRefresh: fetchNotifications,
                  color: Colors.teal,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        notifications[index],
                        index,
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw animated arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 15;
    final waveLength = size.width / 2;

    // Create animated wave path
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height -
          40 +
          math.sin((x / waveLength + animationValue * 2) * 2 * math.pi) *
              waveHeight +
          math.sin(
                (x / (waveLength * 0.5) + animationValue * 3) * 2 * math.pi,
              ) *
              (waveHeight * 0.5);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw second wave
    final paint2 =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height -
          30 +
          math.sin((x / waveLength - animationValue * 1.5) * 2 * math.pi) *
              (waveHeight * 0.8);

      if (x == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
