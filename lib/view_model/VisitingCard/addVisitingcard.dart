import 'dart:typed_data' show Uint8List, ByteData;
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class VisitingCardPage extends StatefulWidget {
  final String? imageUrl;
  final Map<String, dynamic>? cardData;
  final int? visitingCardId;

  const VisitingCardPage({
    Key? key,
    this.imageUrl,
    this.cardData,
    this.visitingCardId,
  }) : super(key: key);

  @override
  State<VisitingCardPage> createState() => _VisitingCardPageState();
}

class _VisitingCardPageState extends State<VisitingCardPage>
    with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? visitingCardData;
  Uint8List? selectedImageData;
  Uint8List? logoImageData;
  String qrData = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    _loadVisitingCardData();
  }

  Future<void> _loadVisitingCardData() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (widget.cardData != null) {
        visitingCardData = widget.cardData;
        logoImageData = visitingCardData!['logoimage'] as Uint8List?;
      } else if (widget.visitingCardId != null) {
        final cardFromDb = await _dbHelper.getVisitingCardById(
          widget.visitingCardId!,
        );
        if (cardFromDb != null) {
          visitingCardData = {
            ...?cardFromDb['parsed_data'] as Map<String, dynamic>?,
            'logoimage': cardFromDb['logoimage'] as Uint8List?,
          };
          logoImageData = cardFromDb['logoimage'] as Uint8List?;
        }
      } else {
        final cards = await _dbHelper.getVisitingCards();
        if (cards.isNotEmpty) {
          visitingCardData = {
            ...?cards.first['parsed_data'] as Map<String, dynamic>?,
            'logoimage': cards.first['logoimage'] as Uint8List?,
          };
          logoImageData = cards.first['logoimage'] as Uint8List?;
        }
      }

      if (logoImageData != null && logoImageData!.isEmpty) {
        print("Warning: logoimage is empty in database");
        logoImageData = null;
      }

      if (widget.visitingCardId != null) {
        final selectedImage = await _dbHelper.getSelectedCarouselImage(
          widget.visitingCardId!,
        );
        if (selectedImage != null && selectedImage['image_data'] != null) {
          selectedImageData = selectedImage['image_data'] as Uint8List;
          if (selectedImageData!.isEmpty) {
            print("Warning: selected carousel image is empty");
            selectedImageData = null;
          }
        }
      }

      if (visitingCardData != null) {
        _generateQRData();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading visiting card data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading card data: ${e.toString()}")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _generateQRData() {
    if (visitingCardData == null) return;

    String website = visitingCardData!['website'] ?? '';
    if (website.isNotEmpty) {
      if (!website.startsWith('http://') && !website.startsWith('https://')) {
        website = 'https://$website';
      }
      qrData = website;
    } else {
      qrData = _createVCard();
    }
  }

  String _createVCard() {
    if (visitingCardData == null) return '';

    String vCard = 'BEGIN:VCARD\n';
    vCard += 'VERSION:3.0\n';
    vCard += 'FN:${visitingCardData!['name'] ?? ''}\n';
    vCard += 'ORG:${visitingCardData!['companyName'] ?? ''}\n';
    vCard += 'TITLE:${visitingCardData!['designation'] ?? ''}\n';

    if (visitingCardData!['phone']?.isNotEmpty == true) {
      vCard += 'TEL;TYPE=CELL:${visitingCardData!['phone']}\n';
    }
    if (visitingCardData!['landphone']?.isNotEmpty == true) {
      vCard += 'TEL;TYPE=WORK:${visitingCardData!['landphone']}\n';
    }
    if (visitingCardData!['email']?.isNotEmpty == true) {
      vCard += 'EMAIL:${visitingCardData!['email']}\n';
    }
    if (visitingCardData!['website']?.isNotEmpty == true) {
      String website = visitingCardData!['website'];
      if (!website.startsWith('http://') && !website.startsWith('https://')) {
        website = 'https://$website';
      }
      vCard += 'URL:$website\n';
    }
    if (visitingCardData!['companyaddress']?.isNotEmpty == true) {
      vCard += 'ADR:;;${visitingCardData!['companyaddress']};;;;\n';
    }

    vCard += 'END:VCARD';
    return vCard;
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    } catch (e) {
      print("Error launching URL: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
    }
  }

  Future<void> _shareCard() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/business_card.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My Premium Business Card ✨');
    } catch (e) {
      print("Error sharing card: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing card: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Premium Business Card',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              RepaintBoundary(
                                key: _globalKey,
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, -5),
                                            ),
                                          ],
                                          image:
                                              selectedImageData != null
                                                  ? DecorationImage(
                                                    image: MemoryImage(
                                                      selectedImageData!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    opacity: 0.3,
                                                  )
                                                  : null,
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF667eea),
                                                  Color(0xFF764ba2),
                                                  Color(0xFF667eea),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.1),
                                                          Colors.transparent,
                                                          Colors.black
                                                              .withOpacity(0.1),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildHeaderSection(),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      _buildContactSection(),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      _buildSocialMediaSection(),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildShareButton(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "✨ PREMIUM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                visitingCardData?['name']?.toUpperCase() ?? "YOUR NAME",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitingCardData?['designation'] ?? "Your Designation",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visitingCardData?['companyName'] ?? "Your Company",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                isLoading
                    ? Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : logoImageData != null && logoImageData!.isNotEmpty
                    ? Image.memory(
                      logoImageData!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading logo image from memory: $error");
                        return _buildDefaultLogoImage();
                      },
                    )
                    : _buildDefaultLogoImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogoImage() {
    return Image.asset(
      'assets/placeholder_logo.png',
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print("Error loading placeholder logo: $error");
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.red),
        );
      },
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                if (visitingCardData?['phone']?.isNotEmpty == true)
                  _buildContactItem(
                    Icons.phone_android,
                    visitingCardData!['phone'],
                  ),
                if (visitingCardData?['landphone']?.isNotEmpty == true)
                  _buildContactItem(
                    Icons.phone,
                    visitingCardData!['landphone'],
                  ),
                if (visitingCardData?['whatsapnumber']?.isNotEmpty == true)
                  _buildContactItem(
                    Icons.chat,
                    visitingCardData!['whatsapnumber'],
                  ),
                if (visitingCardData?['email']?.isNotEmpty == true)
                  _buildContactItem(
                    Icons.email_outlined,
                    visitingCardData!['email'],
                  ),
                if (visitingCardData?['website']?.isNotEmpty == true)
                  _buildContactItem(
                    Icons.language,
                    visitingCardData!['website'],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (qrData.isNotEmpty)
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 70.0,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667eea),
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  "Scan QR",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    List<Widget> socialButtons = [];

    if (visitingCardData?['fblink']?.isNotEmpty == true) {
      socialButtons.add(
        GestureDetector(
          onTap: () => _launchURL(visitingCardData!['fblink']),
          child: _buildSocialButton(
            Icons.facebook,
            "Facebook",
            const Color(0xFF1877F2),
          ),
        ),
      );
    }
    if (visitingCardData?['youtubelink']?.isNotEmpty == true) {
      socialButtons.add(
        GestureDetector(
          onTap: () => _launchURL(visitingCardData!['youtubelink']),
          child: _buildSocialButton(
            Icons.play_circle_fill,
            "YouTube",
            const Color(0xFFFF0000),
          ),
        ),
      );
    }
    if (visitingCardData?['instalink']?.isNotEmpty == true) {
      socialButtons.add(
        GestureDetector(
          onTap: () => _launchURL(visitingCardData!['instalink']),
          child: _buildSocialButton(
            Icons.camera_alt,
            "Instagram",
            const Color(0xFFE4405F),
          ),
        ),
      );
    }

    if (socialButtons.isEmpty) {
      socialButtons = [
        _buildSocialButton(Icons.facebook, "Facebook", const Color(0xFF1877F2)),
        _buildSocialButton(
          Icons.play_circle_fill,
          "YouTube",
          const Color(0xFFFF0000),
        ),
        _buildSocialButton(
          Icons.camera_alt,
          "Instagram",
          const Color(0xFFE4405F),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: socialButtons,
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _shareCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Share Card",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
