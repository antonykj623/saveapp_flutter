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
  bool _isSaving = false;
  bool _isLoadingCarousel = true; // New loading state for carousel
  double _saveProgress = 0.0; // Progress indicator

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
    _initAnimations();
    _initializeData();
    _loadCarouselImagesOptimized();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Reduced from 1000ms
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Reduced from 2000ms
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeData() {
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

      _logoImage =
          widget.logoImage ?? widget.cardData!['logoimage'] as Uint8List?;
      _image = widget.cardImage ?? widget.cardData!['cardimg'] as Uint8List?;
    } else {
      _logoImage = widget.logoImage;
      _image = widget.cardImage;
    }
  }

  // Optimized carousel loading with progress indication
  Future<void> _loadCarouselImagesOptimized() async {
    try {
      List<dynamic> loadedImages = [];
      int selectedIndex = 0;

      if (widget.cardId != null && widget.cardId! > 0) {
        // Show loading immediately
        setState(() {
          _isLoadingCarousel = true;
        });

        final images = await _dbHelper.getCarouselImagesByVisitCardId(
          widget.cardId!,
        );
        if (images.isNotEmpty) {
          // Load images in batches to prevent blocking
          for (int i = 0; i < images.length; i++) {
            loadedImages.add(images[i]['image_data'] as Uint8List);

            // Update UI every few images
            if (i % 2 == 0 && mounted) {
              setState(() {
                _images = List.from(loadedImages);
              });
            }
          }

          final selectedIndexResult = images.indexWhere(
            (img) => img['is_selected'] == 1,
          );
          selectedIndex = selectedIndexResult != -1 ? selectedIndexResult : 0;
        }
      }

      if (mounted) {
        setState(() {
          _images =
              loadedImages.isNotEmpty ? loadedImages : _defaultImageAssets;
          _currentIndex = loadedImages.isNotEmpty ? selectedIndex : 0;
          if (_images.isNotEmpty && _currentIndex >= _images.length) {
            _currentIndex = 0;
          }
          _isLoadingCarousel = false;
        });
      }
    } catch (e) {
      print("Error loading carousel images: $e");
      if (mounted) {
        setState(() {
          _images = _defaultImageAssets;
          _currentIndex = 0;
          _isLoadingCarousel = false;
        });
        _showSnackBar("Failed to load carousel images");
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
        imageQuality: 60, // Reduced from 70 for faster processing
        maxWidth: isLogo ? 400 : 800, // Reduced dimensions
        maxHeight: isLogo ? 400 : 800,
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
        _showSnackBar("Failed to pick image");
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
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
                            hint: "Facebook Profile URL",
                            icon: Icons.facebook_outlined,
                            color: const Color(0xFF3B5998),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: instalink,
                                  hint: "Instagram URL",
                                  icon: Icons.camera_alt_outlined,
                                  color: const Color(0xFFE4405F),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: youtubelink,
                                  hint: "YouTube URL",
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
    if (_isLoadingCarousel) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading templates...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Text(
            'No templates available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
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
                  autoPlay: false, // Disabled to improve performance
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: true,
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
              _logoImage != null && _logoImage!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      _logoImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error displaying logo: $error");
                        return _buildPlaceholderImage();
                      },
                    ),
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
          onTap: _isSaving ? null : _handleSubmit,
          child:
              _isSaving
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                          value: _saveProgress > 0 ? _saveProgress : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _saveProgress > 0
                            ? '${(_saveProgress * 100).toInt()}%'
                            : 'Saving...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 24,
                      ),
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

  // Optimized submit handler with progress indication
  Future<void> _handleSubmit() async {
    if (_isSaving) return;

    // Validation
    if (name.text.trim().isEmpty) {
      _showSnackBar("Please enter a name");
      return;
    }

    if (_images.isEmpty) {
      _showSnackBar("Please select or upload at least one background image");
      return;
    }

    setState(() {
      _isSaving = true;
      _saveProgress = 0.0;
    });

    try {
  
      setState(() => _saveProgress = 0.2);

      final cardData = {
        'name': name.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'whatsapnumber': whatsapnumber.text.trim(),
        'landphone': landphone.text.trim(),
        'companyName': companyName.text.trim(),
        'designation': desig.text.trim(),
        'website': website.text.trim(),
        'companyaddress': companyaddress.text.trim(),
        'fblink': fblink.text.trim(),
        'instalink': instalink.text.trim(),
        'youtubelink': youtubelink.text.trim(),
        'saveapplink': saveapplink.text.trim(),
        'couponcode': couponcode.text.trim(),
      };

      setState(() => _saveProgress = 0.4);

      Uint8List? selectedCardImage;
      if (_currentIndex >= 0 && _currentIndex < _images.length) {
        if (_images[_currentIndex] is String) {
          selectedCardImage = await _dbHelper.loadAssetImage(
            _images[_currentIndex],
          );
          if (selectedCardImage.isEmpty) {
            throw Exception("Failed to load selected background image");
          }
        } else if (_images[_currentIndex] is Uint8List) {
          selectedCardImage = _images[_currentIndex] as Uint8List;
        }
      }

      if (selectedCardImage == null) {
        throw Exception("Invalid background image selection");
      }

      // Step 3: Save visiting card
      setState(() => _saveProgress = 0.6);

      final result = await _dbHelper.insertOrUpdateVisitingCard(
        cardData: cardData,
        logoImage: _logoImage,
        cardImage: selectedCardImage,
        id: widget.cardId,
        selectedBackgroundId: _currentIndex,
        defaultImageAssets:
            _images.every((img) => img is String) ? _defaultImageAssets : null,
      );

      final int finalVisitingCardId = widget.cardId ?? result;
      if (finalVisitingCardId <= 0) {
        throw Exception('Failed to save visiting card');
      }

      // Step 4: Save carousel images
      setState(() => _saveProgress = 0.8);

      await _saveCarouselImagesOptimized(finalVisitingCardId);

      // Step 5: Complete
      setState(() => _saveProgress = 1.0);

      if (mounted) {
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Show 100% briefly
        _showSuccessDialog();

        // Navigate to VisitingCardPage and then pop back with result
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop(); // Dismiss dialog
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        VisitingCardPage(
                          cardData: {...cardData, 'logoimage': _logoImage},
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
            ).then((_) {
              // Pop back to AddVisitingCard with result true
              Navigator.pop(context, true);
            });
          }
        });
      }
    } catch (e) {
      print("Error saving visiting card: $e");
      if (mounted) {
        _showSnackBar("Error occurred while saving: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveProgress = 0.0;
        });
      }
    }
  }

  // Optimized carousel image saving with batching
  Future<void> _saveCarouselImagesOptimized(int visitingCardId) async {
    try {
      // Delete existing carousel images
      await _dbHelper.deleteCarouselImagesByVisitCardId(visitingCardId);

      // Save new carousel images in smaller batches
      for (int i = 0; i < _images.length; i++) {
        Uint8List? imageBytes;

        if (_images[i] is String) {
          imageBytes = await _dbHelper.loadAssetImage(_images[i]);
          if (imageBytes.isEmpty) {
            print("Failed to load asset image at index $i: ${_images[i]}");
            continue;
          }
        } else if (_images[i] is Uint8List) {
          imageBytes = _images[i] as Uint8List;
        }

        if (imageBytes != null && imageBytes.isNotEmpty) {
          final int? carouselImageId = await _dbHelper.insertCarouselImage(
            imageData: imageBytes,
            visitCardId: visitingCardId,
            order: i,
            isSelected: i == _currentIndex,
          );

          // Set selected image
          if (i == _currentIndex &&
              carouselImageId != null &&
              carouselImageId > 0) {
            await _dbHelper.setSelectedCarouselImage(
              visitingCardId,
              carouselImageId,
            );
          }
        }

        // Smaller delay to prevent blocking
        if (i % 2 == 0) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }
    } catch (e) {
      print("Error saving carousel images: $e");
      throw Exception("Failed to save carousel images: $e");
    }
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
                      ? 'Your visiting card has been created successfully!'
                      : 'Your visiting card has been updated successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
