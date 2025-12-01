import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage>
    with SingleTickerProviderStateMixin {
  final String referralLink =
      "http://mysaveapp.com/signup?sponserid=qwertyuiop";

  String? timestamp;
  ApiHelper api = ApiHelper();
  List<String> imageList = [];
  String description = '';
  bool isDownloading = false;
  bool _linkCopied = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    imageData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> downloadShareImage(String imageName, String token) async {
    setState(() {
      isDownloading = true;
    });

    try {
      final imageUrl = 'https://mysaving.in/images/$imageName';

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) throw Exception("Image download failed");

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$imageName';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final referralLink = "http://mysaveapp.com/signup?sponserid=qwertyuiop";
      final fullLink = "$referralLink&token=$token";

      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: "Join this platform:\n$fullLink");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Image shared successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Failed to download image."),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  String extractFileName(String url) {
    return url.split('/').last;
  }

  void imageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      String response = await api.getApiResponse(
        "getSettingsSlider.php?&timestamp=$timestamp",
      );
      debugPrint("Response: $response");

      final jsonData = json.decode(response);
      if (jsonData["status"] == 1) {
        List<dynamic> data = jsonData['data'];
        print("Data is $data");
        List<String> tempImages =
            data
                .map<String>(
                  (item) => 'https://mysaving.in/images/${item['image']}',
                )
                .toList();
        String tempDescription = data.isNotEmpty ? data[0]['description'] : '';
        print("Listofiamge  is $tempImages");
        setState(() {
          imageList = tempImages;
          description = tempDescription;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight =
        screenWidth * 0.6; // Responsive height based on screen width

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC), Color(0xFF00C9FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "Share & Earn",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Invite friends and get rewards",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.card_giftcard, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30),

                        // Carousel Section with Fixed Height
                        imageList.isNotEmpty
                            ? Column(
                              children: [
                                Container(
                                  height: carouselHeight.clamp(
                                    200.0,
                                    320.0,
                                  ), // Min 200, Max 320
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      height: carouselHeight.clamp(
                                        200.0,
                                        320.0,
                                      ),
                                      autoPlay: true,
                                      enlargeCenterPage: true,
                                      viewportFraction: 0.85,
                                      autoPlayInterval: Duration(seconds: 4),
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentCarouselIndex = index;
                                        });
                                      },
                                    ),
                                    items:
                                        imageList.map((imagePath) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return Container(
                                                width: screenWidth * 0.85,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(
                                                        0xFF6A11CB,
                                                      ).withOpacity(0.3),
                                                      blurRadius: 20,
                                                      offset: Offset(0, 10),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  child: Image.network(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null)
                                                        return child;
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                                colors: [
                                                                  Colors
                                                                      .grey
                                                                      .shade200,
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                                ],
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(
                                                                  Color(
                                                                    0xFF6A11CB,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                                    Colors
                                                                        .grey
                                                                        .shade400,
                                                                  ],
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .broken_image_rounded,
                                                                  size: 60,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade600,
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Image not available',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Carousel Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      imageList.asMap().entries.map((entry) {
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          width:
                                              _currentCarouselIndex == entry.key
                                                  ? 28
                                                  : 8,
                                          height: 8,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            gradient:
                                                _currentCarouselIndex ==
                                                        entry.key
                                                    ? LinearGradient(
                                                      colors: [
                                                        Color(0xFF6A11CB),
                                                        Color(0xFF2575FC),
                                                      ],
                                                    )
                                                    : null,
                                            color:
                                                _currentCarouselIndex ==
                                                        entry.key
                                                    ? null
                                                    : Colors.grey.shade400,
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            )
                            : Container(
                              height: 260,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6A11CB).withOpacity(0.1),
                                    Color(0xFF2575FC).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6A11CB),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Loading images...',
                                      style: TextStyle(
                                        color: Color(0xFF6A11CB),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                        SizedBox(height: 30),

                        // Description Card
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.blue.shade50],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6A11CB),
                                      Color(0xFF2575FC),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.card_giftcard,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Referral Link Card
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6A11CB).withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF6A11CB),
                                              Color(0xFF2575FC),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.link_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Your Referral Link",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              referralLink,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1, thickness: 1),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            await Clipboard.setData(
                                              ClipboardData(text: referralLink),
                                            );
                                            setState(() {
                                              _linkCopied = true;
                                            });
                                            Future.delayed(
                                              Duration(seconds: 2),
                                              () {
                                                if (mounted) {
                                                  setState(() {
                                                    _linkCopied = false;
                                                  });
                                                }
                                              },
                                            );
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
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "Link copied to clipboard!",
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                margin: EdgeInsets.all(16),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(18),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  _linkCopied
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons
                                                          .content_copy_rounded,
                                                  color: Color(0xFF6A11CB),
                                                  size: 22,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  _linkCopied
                                                      ? "Copied!"
                                                      : "Copy Link",
                                                  style: TextStyle(
                                                    color: Color(0xFF6A11CB),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 56,
                                      color: Colors.grey.shade300,
                                    ),
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            await Share.share(
                                              'Join this amazing platform using my referral link:\n$referralLink',
                                              subject: 'Join & Earn Together!',
                                            );
                                          },
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(18),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.share_rounded,
                                                  color: Color(0xFF2575FC),
                                                  size: 22,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Share",
                                                  style: TextStyle(
                                                    color: Color(0xFF2575FC),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // Share Image Button
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: () {
                            if (imageList.isNotEmpty) {
                              const token =
                                  'qwertyuioplkjhgfvbnmlkjiou.OTc0NzQ5Nzk2Nw==.MjVkNTVhZDI4M2FhNDAwYWY0NjRjNzZkNzEzYzA3YWQ=.qwertyuioplkjhgfvbnmlkjiou';
                              String imageUrl = imageList[0];
                              String imageName = extractFileName(imageUrl);
                              downloadShareImage(imageName, token);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text("No image available to share"),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00C9FF),
                                    Color(0xFF92FE9D),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00C9FF).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  SizedBox(width: 14),
                                  Text(
                                    "Share Image with Token",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (isDownloading)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6A11CB).withOpacity(0.1),
                                        Color(0xFF2575FC).withOpacity(0.1),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6A11CB),
                                    ),
                                    strokeWidth: 3,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Preparing image...",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 50),
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
}
