import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/password_manger/password_manger/password_list_screen/password_details/password_details.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import '../Edit_password/EditPasswordManager.dart';

class listpasswordData extends StatefulWidget {
  const listpasswordData({super.key});

  @override
  State<listpasswordData> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<listpasswordData>
    with TickerProviderStateMixin {
  bool isLoading = false;
  List<passwordModel> docLinks = [];
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _headerAnimationController.forward();
    _loadData();
  }

  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllpassData();
    List<passwordModel> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];
      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId;
        loadedLinks.add(passwordModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }
    setState(() {
      docLinks = loadedLinks;
    });
    _listAnimationController.forward();
  }

  Future<void> _handleDelete(int keyid) async {
    setState(() => isLoading = true);
    await DatabaseHelper().deleteByFieldId('TABLE_PASSWORD', keyid);
    _loadData();
    await Future.delayed(Duration(milliseconds: 300));
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedGradientBackground(),

          Column(
            children: [
              // Enhanced header with animation
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - _headerAnimation.value)),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: _buildEnhancedHeader(),
                    ),
                  );
                },
              ),

              // Content area with cards
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getAllData('TABLE_PASSWORD'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: ShimmerLoadingEffect());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return _buildEmptyState();
                    }

                    return AnimatedList(
                      key: GlobalKey<AnimatedListState>(),
                      padding: EdgeInsets.all(16),
                      initialItemCount: items.length,
                      itemBuilder: (context, index, animation) {
                        final item = items[index];
                        final keyId = item['keyid'];
                        final dataJson = jsonDecode(item['data'] ?? '{}');

                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: _buildEnhancedPasswordCard(
                              context,
                              keyId,
                              dataJson,
                              index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulsingCircularProgress(),
                    SizedBox(height: 20),
                    Text(
                      'Deleting...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPasswordPage()),
          );
        },
        backgroundColor: Color(0xFF667eea),
        elevation: 8,
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: Text(
          'Add Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SaveApp()),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Secure your passwords',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPasswordCard(
    BuildContext context,
    int keyId,
    Map<String, dynamic> dataJson,
    int index,
  ) {
    final colors = [
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFf5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
      [Color(0xFFfa709a), Color(0xFFfee140)],
    ];
    final colorPair = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final passwordItem = passwordModel.fromMap({
              'keyid': keyId,
              'title': dataJson['title'] ?? '',
              'uname': dataJson['uname'] ?? '',
              'passwd': dataJson['passwd'] ?? '',
              'website': dataJson['website'] ?? '',
              'remarks': dataJson['remarks'] ?? '',
            });

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPasswordPage(entry: passwordItem),
              ),
            );

            if (result == true) {
              _loadData();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPair[0], colorPair[1]],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPair[0].withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataJson['title'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    dataJson['uname'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          if (keyId != null) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => _buildDeleteDialog(),
                            );
                            if (confirm == true) {
                              await _handleDelete(keyId);
                            }
                          }
                        },
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('Confirm Delete'),
        ],
      ),
      content: Text('Are you sure you want to delete this password?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_open_rounded, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'No passwords saved yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the button below to add your first password',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  Color(0xFFF5F7FA),
                  Color(0xFFE8EAF6),
                  _controller.value,
                )!,
                Color.lerp(
                  Color(0xFFE8EAF6),
                  Color(0xFFF5F7FA),
                  _controller.value,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Pulsing circular progress indicator
class PulsingCircularProgress extends StatefulWidget {
  @override
  _PulsingCircularProgressState createState() =>
      _PulsingCircularProgressState();
}

class _PulsingCircularProgressState extends State<PulsingCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4,
          ),
        );
      },
    );
  }
}

// Shimmer loading effect
class ShimmerLoadingEffect extends StatefulWidget {
  @override
  _ShimmerLoadingEffectState createState() => _ShimmerLoadingEffectState();
}

class _ShimmerLoadingEffectState extends State<ShimmerLoadingEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + _controller.value * 2, 0),
                    end: Alignment(1.0 + _controller.value * 2, 0),
                    colors: [
                      Colors.grey[300]!,
                      Colors.grey[100]!,
                      Colors.grey[300]!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Models (keep your existing models)
class passwordModel {
  final int? keyid;
  final String title;
  final String uname;
  final String passwd;
  final String website;
  final String remarks;

  passwordModel({
    required this.keyid,
    required this.title,
    required this.uname,
    required this.passwd,
    required this.website,
    required this.remarks,
  });

  factory passwordModel.fromMap(Map<String, dynamic> map) {
    return passwordModel(
      keyid: map['keyid'] ?? '',
      title: map['title'] ?? '',
      uname: map['uname'] ?? '',
      passwd: map['passwd'] ?? '',
      website: map['website'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyid': keyid,
      'title': title,
      'uname': uname,
      'passwd': passwd,
      'website': website,
      'remarks': remarks,
    };
  }
}
