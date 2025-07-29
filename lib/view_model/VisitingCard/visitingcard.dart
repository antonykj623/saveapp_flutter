import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_project_2025/view_model/VisitingCard/addVisitingcard.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class VisitingCard extends StatefulWidget {
  final Map<String, dynamic>? cardData;
  final int? cardId;
  final Uint8List? logoImage;
  final Uint8List? cardImage;

  const VisitingCard({
    super.key,
    this.cardData,
    this.cardId,
    this.logoImage,
    this.cardImage,
  });

  @override
  _VisitingCardFormState createState() => _VisitingCardFormState();
}

class _VisitingCardFormState extends State<VisitingCard>
    with TickerProviderStateMixin {
  Uint8List? _image;
  Uint8List? _logoImage;
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  List<dynamic> _images = [];
  int _currentIndex = 0;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController whatsapnumber = TextEditingController();
  final TextEditingController landphone = TextEditingController();
  final TextEditingController companyName = TextEditingController();
  final TextEditingController desig = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController saveapplink = TextEditingController();
  final TextEditingController couponcode = TextEditingController();
  final TextEditingController fblink = TextEditingController();
  final TextEditingController instalink = TextEditingController();
  final TextEditingController youtubelink = TextEditingController();
  final TextEditingController companyaddress = TextEditingController();

  final List<String> _defaultImageAssets = [
    "assets/1.jpg",
    "assets/2.jpg",
    "assets/3.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);

    if (widget.cardData != null) {
      name.text = widget.cardData!['name'] ?? '';
      email.text = widget.cardData!['email'] ?? '';
      phone.text = widget.cardData!['phone'] ?? '';
      whatsapnumber.text = widget.cardData!['whatsapnumber'] ?? '';
      landphone.text = widget.cardData!['landphone'] ?? '';
      companyName.text = widget.cardData!['companyName'] ?? '';
      desig.text = widget.cardData!['designation'] ?? '';
      website.text = widget.cardData!['website'] ?? '';
      saveapplink.text = widget.cardData!['saveapplink'] ?? '';
      couponcode.text = widget.cardData!['couponcode'] ?? '';
      fblink.text = widget.cardData!['fblink'] ?? '';
      instalink.text = widget.cardData!['instalink'] ?? '';
      youtubelink.text = widget.cardData!['youtubelink'] ?? '';
      companyaddress.text = widget.cardData!['companyaddress'] ?? '';
      _logoImage = widget.logoImage;
      _image = widget.cardImage;
    }

    _loadCarouselImages();
  }

  Future<void> _loadCarouselImages() async {
    try {
      List<dynamic> loadedImages = [];
      int selectedIndex = 0;

      if (widget.cardId != null && widget.cardId! > 0) {
        final images = await _dbHelper.getCarouselImagesByVisitCardId(
          widget.cardId!,
        );
        if (images.isNotEmpty) {
          loadedImages =
              images.map((img) => img['image_data'] as Uint8List).toList();
          final selectedIndexResult = images.indexWhere(
            (img) => img['is_selected'] == 1,
          );
          selectedIndex = selectedIndexResult != -1 ? selectedIndexResult : 0;
        }
      }

      setState(() {
        _images = loadedImages.isNotEmpty ? loadedImages : _defaultImageAssets;
        _currentIndex = loadedImages.isNotEmpty ? selectedIndex : 0;
        if (_images.isNotEmpty && _currentIndex >= _images.length) {
          _currentIndex = 0;
        }
      });
    } catch (e) {
      print("Error loading carousel images: $e");
      setState(() {
        _images = _defaultImageAssets;
        _currentIndex = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load carousel images")),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    whatsapnumber.dispose();
    landphone.dispose();
    companyName.dispose();
    desig.dispose();
    website.dispose();
    saveapplink.dispose();
    couponcode.dispose();
    fblink.dispose();
    instalink.dispose();
    youtubelink.dispose();
    companyaddress.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool isLogo = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isLogo) {
            _logoImage = bytes;
          } else {
            List<dynamic> newImages = List.from(_images);
            newImages.add(bytes);
            _images = newImages;
            _currentIndex = _images.length - 1;
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to pick image")));
      }
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
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.cardId == null
                            ? 'Create Visiting Card'
                            : 'Edit Visiting Card',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            "Choose Background Template",
                            Icons.palette,
                          ),
                          const SizedBox(height: 15),
                          _buildCarouselSection(),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            "Personal Information",
                            Icons.person,
                          ),
                          const SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: name,
                            hint: "Full Name",
                            icon: Icons.person_outline,
                            color: const Color(0xFF667eea),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: phone,
                                  hint: "Phone Number",
                                  icon: Icons.phone_outlined,
                                  color: const Color(0xFF764ba2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: whatsapnumber,
                                  hint: "WhatsApp",
                                  icon: Icons.chat_outlined,
                                  color: const Color(0xFF25D366),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: landphone,
                            hint: "Land Phone Number",
                            icon: Icons.phone_callback_outlined,
                            color: const Color(0xFFF093fb),
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: email,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                            color: const Color(0xFFFF6B6B),
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            "Company Information",
                            Icons.business,
                          ),
                          const SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: companyName,
                            hint: "Company Name",
                            icon: Icons.business_outlined,
                            color: const Color(0xFF4ECDC4),
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: desig,
                            hint: "Designation/Profession",
                            icon: Icons.work_outline,
                            color: const Color(0xFF45B7D1),
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: website,
                            hint: "Website URL",
                            icon: Icons.language_outlined,
                            color: const Color(0xFF96CEB4),
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: companyaddress,
                            hint: "Company Address",
                            icon: Icons.location_on_outlined,
                            color: const Color(0xFFFECEA8),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Social Media Links", Icons.share),
                          const SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: fblink,
                            hint: "Facebook Profile",
                            icon: Icons.facebook_outlined,
                            color: const Color(0xFF3B5998),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: instalink,
                                  hint: "Instagram",
                                  icon: Icons.camera_alt_outlined,
                                  color: const Color(0xFFE4405F),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: youtubelink,
                                  hint: "YouTube",
                                  icon: Icons.play_circle_outline,
                                  color: const Color(0xFFFF0000),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            "Additional Information",
                            Icons.info_outline,
                          ),
                          const SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: saveapplink,
                            hint: "App Download Link",
                            icon: Icons.download_outlined,
                            color: const Color(0xFF9B59B6),
                          ),
                          const SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: couponcode,
                            hint: "Coupon Code",
                            icon: Icons.local_offer_outlined,
                            color: const Color(0xFFE67E22),
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            "Company Logo",
                            Icons.business_center,
                          ),
                          const SizedBox(height: 15),
                          _buildLogoSection(),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
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
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSection() {
    if (_images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 200,
              child: CarouselSlider(
                items:
                    _images.map((img) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _buildImageWidget(img),
                        ),
                      );
                    }).toList(),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(milliseconds: 1200),
                  viewportFraction: 0.85,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400]!, Colors.pink[600]!],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => _pickImage(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 20,
            child: Row(
              children:
                  _images.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Container(
                      width: _currentIndex == index ? 12 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            _currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(dynamic img) {
    try {
      if (img is String) {
        return Image.asset(
          img,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } else if (img is Uint8List) {
        return Image.memory(
          img,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } else {
        return _buildPlaceholderImage();
      }
    } catch (e) {
      print("Error building image widget: $e");
      return _buildPlaceholderImage();
    }
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: color, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(isLogo: true),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child:
              _logoImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(_logoImage!, fit: BoxFit.cover),
                  )
                  : widget.logoImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(widget.logoImage!, fit: BoxFit.cover),
                  )
                  : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.add_photo_alternate,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Add Company Logo",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Tap to upload",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
            if (name.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter a name"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (_images.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please select or upload at least one background image",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final cardData = {
              'name': name.text,
              'email': email.text,
              'phone': phone.text,
              'whatsapnumber': whatsapnumber.text,
              'landphone': landphone.text,
              'companyName': companyName.text,
              'designation': desig.text,
              'website': website.text,
              'companyaddress': companyaddress.text,
              'fblink': fblink.text,
              'instalink': instalink.text,
              'youtubelink': youtubelink.text,
              'saveapplink': saveapplink.text,
              'couponcode': couponcode.text,
            };

            try {
              Uint8List? selectedCardImage;
              if (_currentIndex >= 0 && _currentIndex < _images.length) {
                if (_images[_currentIndex] is String) {
                  selectedCardImage = await _dbHelper.loadAssetImage(
                    _images[_currentIndex],
                  );
                  if (selectedCardImage.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Failed to load selected background image",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else if (_images[_currentIndex] is Uint8List) {
                  selectedCardImage = _images[_currentIndex] as Uint8List;
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid background image selection"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final result = await _dbHelper.insertOrUpdateVisitingCard(
                cardData: cardData,
                logoImage: _logoImage ?? widget.logoImage,
                cardImage: selectedCardImage,
                id: widget.cardId,
                selectedBackgroundId: _currentIndex,
                defaultImageAssets:
                    _images.every((img) => img is String)
                        ? _defaultImageAssets
                        : null,
              );

              final int finalVisitingCardId = widget.cardId ?? result;
              if (finalVisitingCardId <= 0) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to save visiting card"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              try {
                await _dbHelper.deleteCarouselImagesByVisitCardId(
                  finalVisitingCardId,
                );
                for (int i = 0; i < _images.length; i++) {
                  Uint8List? imageBytes;
                  if (_images[i] is String) {
                    imageBytes = await _dbHelper.loadAssetImage(_images[i]);
                    if (imageBytes.isEmpty) {
                      print(
                        "Failed to load asset image at index $i: ${_images[i]}",
                      );
                      continue; // Skip invalid images
                    }
                  } else if (_images[i] is Uint8List) {
                    imageBytes = _images[i] as Uint8List;
                  }

                  if (imageBytes != null && imageBytes.isNotEmpty) {
                    final int? carouselImageId = await _dbHelper
                        .insertCarouselImage(
                          imageData: imageBytes,
                          visitCardId: finalVisitingCardId,
                          order: i,
                          isSelected: i == _currentIndex,
                        );

                    if (i == _currentIndex &&
                        carouselImageId != null &&
                        carouselImageId > 0) {
                      await _dbHelper.setSelectedCarouselImage(
                        finalVisitingCardId,
                        carouselImageId,
                      );
                    }
                  }
                }
              } catch (dbError) {
                print("Error saving carousel images: $dbError");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to save carousel images"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              _showSuccessDialog();

              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop(); // Dismiss dialog
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              VisitingCardPage(
                                cardData: cardData,
                                visitingCardId: finalVisitingCardId,
                              ),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  ).then((_) => Navigator.pop(context, true)); // Signal refresh
                }
              });
            } catch (e) {
              print("Error saving visiting card: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Error occurred while saving: ${e.toString()}",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.cardId == null
                    ? 'Create Visiting Card'
                    : 'Update Visiting Card',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.cardId == null
                      ? 'Your visiting card is being created...'
                      : 'Your visiting card is being updated...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
