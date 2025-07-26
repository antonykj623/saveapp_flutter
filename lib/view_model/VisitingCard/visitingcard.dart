import 'dart:io';
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

class _VisitingCardFormState extends State<VisitingCard> with TickerProviderStateMixin {
  File? _image;
  File? _logoImage;
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
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

    // Prefill form if editing
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
    }

    _loadCarouselImages();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final defaultImages = [
        "assets/1.jpg",
        "assets/2.jpg",
        "assets/3.jpg",
      ];
      if (widget.cardId != null) {
        final images = await _dbHelper.getCarouselImagesByVisitCardId(widget.cardId!);
        setState(() {
          _images = images.isNotEmpty
              ? images.map((img) => img['image_data'] as Uint8List).toList()
              : defaultImages;
          _currentIndex = images.isNotEmpty && images.any((img) => img['is_selected'] == 1)
              ? images.indexWhere((img) => img['is_selected'] == 1)
              : 0;
        });
      } else {
        setState(() {
          _images = defaultImages;
        });
      }
    } catch (e) {
      print("Error loading carousel images: $e");
      setState(() {
        _images = ["assets/1.jpg", "assets/2.jpg", "assets/3.jpg"];
      });
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
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoImage = File(pickedFile.path);
        } else {
          _image = File(pickedFile.path);
          _images.add(_image);
          _currentIndex = _images.length - 1;
        }
      });
    }
  }

  Future<Uint8List?> _fileToBytes(File? file) async {
    if (file == null) return null;
    return await file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.cardId == null ? 'Create Visiting Card' : 'Edit Visiting Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Icon(Icons.business_center, color: Colors.white, size: 24),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
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
                          SizedBox(height: 30),
                          _buildSectionTitle("Choose Background Template", Icons.palette),
                          SizedBox(height: 15),
                          _buildCarouselSection(),
                          SizedBox(height: 30),
                          _buildSectionTitle("Personal Information", Icons.person),
                          SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: name,
                            hint: "Full Name",
                            icon: Icons.person_outline,
                            color: Color(0xFF667eea),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: phone,
                                  hint: "Phone Number",
                                  icon: Icons.phone_outlined,
                                  color: Color(0xFF764ba2),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: whatsapnumber,
                                  hint: "WhatsApp",
                                  icon: Icons.chat_outlined,
                                  color: Color(0xFF25D366),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: landphone,
                            hint: "Land Phone Number",
                            icon: Icons.phone_callback_outlined,
                            color: Color(0xFFF093fb),
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: email,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                            color: Color(0xFFFF6B6B),
                          ),
                          SizedBox(height: 30),
                          _buildSectionTitle("Company Information", Icons.business),
                          SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: companyName,
                            hint: "Company Name",
                            icon: Icons.business_outlined,
                            color: Color(0xFF4ECDC4),
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: desig,
                            hint: "Designation/Profession",
                            icon: Icons.work_outline,
                            color: Color(0xFF45B7D1),
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: website,
                            hint: "Website URL",
                            icon: Icons.language_outlined,
                            color: Color(0xFF96CEB4),
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: companyaddress,
                            hint: "Company Address",
                            icon: Icons.location_on_outlined,
                            color: Color(0xFFFECEA8),
                            maxLines: 3,
                          ),
                          SizedBox(height: 30),
                          _buildSectionTitle("Social Media Links", Icons.share),
                          SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: fblink,
                            hint: "Facebook Profile",
                            icon: Icons.facebook_outlined,
                            color: Color(0xFF3B5998),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: instalink,
                                  hint: "Instagram",
                                  icon: Icons.camera_alt_outlined,
                                  color: Color(0xFFE4405F),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedTextField(
                                  controller: youtubelink,
                                  hint: "YouTube",
                                  icon: Icons.play_circle_outline,
                                  color: Color(0xFFFF0000),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          _buildSectionTitle("Additional Information", Icons.info_outline),
                          SizedBox(height: 15),
                          _buildEnhancedTextField(
                            controller: saveapplink,
                            hint: "App Download Link",
                            icon: Icons.download_outlined,
                            color: Color(0xFF9B59B6),
                          ),
                          SizedBox(height: 16),
                          _buildEnhancedTextField(
                            controller: couponcode,
                            hint: "Coupon Code",
                            icon: Icons.local_offer_outlined,
                            color: Color(0xFFE67E22),
                          ),
                          SizedBox(height: 30),
                          _buildSectionTitle("Company Logo", Icons.business_center),
                          SizedBox(height: 15),
                          _buildLogoSection(),
                          SizedBox(height: 40),
                          _buildSubmitButton(),
                          SizedBox(height: 20),
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 12),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
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
                items: _images.map((img) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      image: DecorationImage(
                        image: img is String ? AssetImage(img) : MemoryImage(img as Uint8List),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 4),
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: Duration(milliseconds: 1200),
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
                  gradient: LinearGradient(colors: [Colors.pink[400]!, Colors.pink[600]!]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => _pickImage(),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.add_photo_alternate, color: Colors.white, size: 24),
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
              children: _images.asMap().entries.map((entry) {
                return Container(
                  width: _currentIndex == entry.key ? 12 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
            offset: Offset(0, 3),
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
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: _logoImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(_logoImage!, fit: BoxFit.cover),
                )
              : widget.logoImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(widget.logoImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(Icons.add_photo_alternate, color: Colors.white, size: 30),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Add Company Logo",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Tap to upload",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
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
              Uint8List? logoBytes = await _fileToBytes(_logoImage);
              Uint8List? cardBytes = _image != null ? await _fileToBytes(_image) : widget.cardImage;

              int visitingCardId = await _dbHelper.insertOrUpdateVisitingCard(
                cardData: cardData,
                logoImage: logoBytes ?? widget.logoImage,
                cardImage: cardBytes,
                id: widget.cardId,
                selectedBackgroundId: _currentIndex,
              );

              int finalVisitingCardId = widget.cardId ?? visitingCardId;

              if (finalVisitingCardId > 0) {
                final existingImages = await _dbHelper.getCarouselImagesByVisitCardId(finalVisitingCardId);
                bool imageExists = false;
                int? existingImageId;
                int? carouselImageId;

                if (_image != null) {
                  Uint8List? carouselBytes = await _fileToBytes(_image);
                  if (carouselBytes != null) {
                    for (var img in existingImages) {
                      if (img['image_order'] == _currentIndex) {
                        imageExists = true;
                        existingImageId = img['keyid'];
                        break;
                      }
                    }

                    if (imageExists && existingImageId != null) {
                      await _dbHelper.updateCarouselImage(
                        imageId: existingImageId,
                        imageData: carouselBytes,
                        order: _currentIndex,
                        isSelected: true,
                      );
                    } else {
                      carouselImageId = await _dbHelper.insertCarouselImage(
                        imageData: carouselBytes,
                        visitCardId: finalVisitingCardId,
                        order: _currentIndex,
                        isSelected: true,
                      );
                    }

                    if (existingImageId != null || carouselImageId != null) {
                      await _dbHelper.setSelectedCarouselImage(
                        finalVisitingCardId,
                        existingImageId ?? carouselImageId!,
                      );
                    }
                  }
                } else if (existingImages.isNotEmpty) {
                  for (var img in existingImages) {
                    if (img['image_order'] == _currentIndex) {
                      await _dbHelper.setSelectedCarouselImage(
                        finalVisitingCardId,
                        img['keyid'],
                      );
                      break;
                    }
                  }
                }

                _showSuccessDialog();

                Future.delayed(Duration(seconds: 2), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => VisitingCardPage(
                        imageUrl: _images[_currentIndex] is String ? _images[_currentIndex] : 'memory',
                        cardData: cardData,
                        visitingCardId: finalVisitingCardId,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to save visiting card"), backgroundColor: Colors.red),
                );
              }
            } catch (e) {
              print("Error saving visiting card: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error occurred while saving: ${e.toString()}"), backgroundColor: Colors.red),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                widget.cardId == null ? 'Create Visiting Card' : 'Update Visiting Card',
                style: TextStyle(
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
                SizedBox(height: 20),
                Text(
                  'Success!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                Text(
                  widget.cardId == null ? 'Your visiting card is being created...' : 'Your visiting card is being updated...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea))),
              ],
            ),
          ),
        );
      },
    );
  }
}