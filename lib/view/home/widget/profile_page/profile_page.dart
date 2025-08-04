import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:new_project_2025/app/routes/app_routes.dart';
import 'package:new_project_2025/view/home/widget/Invoice_page/Invoice_page.dart';
import 'package:new_project_2025/view/home/widget/profile_page/profilemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/API_services/API_services.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScreen()),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  String? stateid;
  String? countryid;

  String phone = '';
  String name = '';
  String email = '';
  String img = '';
  UserProfileResponse? userProfile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedLanguage = "English";
  late String _phoneNumber = "";
  String imageUrl = "";
  String _token = "";
  bool _isLoading = false;

  String? timestamp;
  final List<String> _languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Chinese",
  ];

  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _waveController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;

  var apidata = ApiHelper();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    profileUser();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _particleController.repeat();
    _waveController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void ProfileUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stateid = prefs.getString('stateId');
    String? countryid = prefs.getString('countryId');
    print("stateid is $stateid");
    print("Countryid is $countryid");
  }

  void profileUser() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;

    print("Token is $_token");

    timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    ApiHelper api = ApiHelper();

    try {
      String logresponse = await api.postApiResponse("getUserDetails.php", {});
      debugPrint("Response1: $logresponse");
      var res = json.decode(logresponse);
      debugPrint("res is...$res");

      var data = res['data'];
      stateid = data['state_id'];
      countryid = data['country_id'];
      print("stateid is $stateid");
      print("Countryid is $countryid");
      setState(() {
        _nameController.text = data['full_name'] ?? '';
        _emailController.text = data['email_id'] ?? '';
        _phoneNumber = data['mobile'].toString() ?? 'no data';

        String baseUrl = "https://mysaving.in/uploads/profile/";
        String profileImage = data['profile_image'] ?? '';

        if (profileImage.isNotEmpty) {
          imageUrl = baseUrl + profileImage;
          print("Complete Image URL: $imageUrl");
        } else {
          imageUrl = "";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
  }

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await uploadProfilePicture(_profileImage!);
    }
  }

  void updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        _buildQuantumSnackBar('Token not found. Please login again.', false),
      );
      return;
    }

    Map<String, String> profiledata = {
      "name": _nameController.text.trim(),
      "user_email": _emailController.text.trim(),
      "language": _selectedLanguage,
      "timestamp": timestamp!,
      "country_id": countryid!,
      "state_id": stateid!,
      "token": token,
    };

    try {
      String response = await apidata.postApiResponse(
        "UserProfileUpdate.php",
        profiledata,
      );
      debugPrint("Update response: $response");

      var res = json.decode(response);
      debugPrint("Updated Profile Data: $res ");

      setState(() {
        _isLoading = false;
      });

      if (res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildQuantumSnackBar("Profile updated successfully", true),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildQuantumSnackBar(res['message'] ?? "Update failed", false),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error updating profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildQuantumSnackBar("Something went wrong", false));
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    final url = Uri.parse(
      'https://mysaving.in/IntegraAccount/api/uploadUserProfile.php',
    );

    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    final timestamp = DateTime.now().toUtc().toIso8601String();

    print('File path: ${imageFile.path}');
    print('File exists: ${await imageFile.exists()}');
    print('File size: ${await imageFile.length()}');

    final request =
        http.MultipartRequest('POST', url)
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'x-timestamp': timestamp,
          })
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        final json = jsonDecode(response.body);
        print('Decoded JSON: $json');
      } catch (e) {
        print('Could not decode response as JSON: $e');
      }
    } catch (e) {
      print('Error uploading: $e');
    }
  }

  SnackBar _buildQuantumSnackBar(String message, bool isSuccess) {
    return SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isSuccess
                          ? [const Color(0xFF00FF87), const Color(0xFF60EFFF)]
                          : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildQuantumAppBar(),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: _isLoading ? _buildQuantumLoader() : _buildProfileContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildQuantumAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      leading: _buildHolographicButton(
        Icons.arrow_back_ios_new,
        () => Navigator.pop(context),
      ),
      actions: [
        _buildHolographicButton(
          Icons.assignment_outlined,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvoiceApp()),
          ),
        ),
      ],
    );
  }

  Widget _buildHolographicButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * 0.1 + 0.9,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF87).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F23),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                Color.lerp(
                  const Color(0xFF0F4C75),
                  const Color(0xFF00897B),
                  (math.sin(_waveAnimation.value) + 1) / 2,
                )!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: WavePainter(_waveAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildQuantumLoader() {
    return Center(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFF00FF87),
                    Color(0xFF60EFFF),
                    Color(0xFFFF6B6B),
                    Color(0xFFFFD93D),
                    Color(0xFF00FF87),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildQuantumProfileImage(),
              const SizedBox(height: 40),
              _buildHologramCard(),
              const SizedBox(height: 24),
              _buildNeuralField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildNeuralField(
                controller: _emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$",
                  ).hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildHolographicDropdown(),
              const SizedBox(height: 40),
              _buildQuantumButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumProfileImage() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _floatAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating outer ring
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFF00FF87),
                        Color(0xFF60EFFF),
                        Color(0xFFFF6B6B),
                        Color(0xFFFFD93D),
                        Color(0xFF00FF87),
                      ],
                    ),
                  ),
                ),
              ),
              // Pulsing middle ring
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF00FF87).withOpacity(0.3),
                        const Color(0xFF60EFFF).withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Profile image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
                  ),
                  border: Border.all(color: const Color(0xFF00FF87), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF87).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      _profileImage != null
                          ? Image.file(_profileImage!, fit: BoxFit.cover)
                          : (imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Color(0xFF00FF87),
                                    ),
                              )
                              : const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF00FF87),
                              )),
                ),
              ),
              // Floating camera button
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHologramCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.05,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FF87).withOpacity(0.1),
                  const Color(0xFF60EFFF).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFF00FF87).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60EFFF), Color(0xFF00FF87)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF60EFFF).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _phoneNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeuralField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00FF87).withOpacity(0.1),
                const Color(0xFF60EFFF).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF00FF87),
                const Color(0xFF60EFFF),
                (_pulseAnimation.value - 0.8) / 0.4,
              )!.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF87).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: const Color(0xFF00FF87).withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF87).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              border: InputBorder.none,
              errorStyle: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildHolographicDropdown() {
    return FormField<String>(
      initialValue: _selectedLanguage,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a language';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00FF87).withOpacity(0.1),
                        const Color(0xFF60EFFF).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.lerp(
                        const Color(0xFF00FF87),
                        const Color(0xFF60EFFF),
                        (_pulseAnimation.value - 0.8) / 0.4,
                      )!.withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF87).withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      labelStyle: TextStyle(
                        color: const Color(0xFF00FF87).withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF87), Color(0xFF60EFFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF87).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      border: InputBorder.none,
                      errorStyle: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dropdownColor: const Color(0xFF0F0F23),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF00FF87),
                    ),
                    items:
                        _languages.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ShaderMask(
                                shaderCallback:
                                    (bounds) => const LinearGradient(
                                      colors: [
                                        Color(0xFF00FF87),
                                        Color(0xFF60EFFF),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                        state.didChange(newValue);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantum language protocol required';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantumButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Transform.scale(
            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
            child: Container(
              width: double.infinity,
              height: 65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00FF87),
                    Color(0xFF60EFFF),
                    Color(0xFFFF6B6B),
                    Color(0xFFFFD93D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF87).withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF60EFFF).withOpacity(0.4),
                    blurRadius: 35,
                    spreadRadius: 8,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
                onPressed: _isLoading ? null : updateProfile,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 3,
                          ),
                        )
                        : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
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

// Custom Painter for Wave Effects
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF00FF87).withOpacity(0.1),
              const Color(0xFF60EFFF).withOpacity(0.05),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height * 0.8 +
          waveHeight *
              math.sin((x / waveLength * 2 * math.pi) + animationValue);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Custom Painter for Floating Particles
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = baseY + (math.sin(animationValue * 2 + i) * 20);

      final opacity = (math.sin(animationValue + i) + 1) / 2;

      paint.color = [
        const Color(0xFF00FF87),
        const Color(0xFF60EFFF),
        const Color(0xFFFF6B6B),
        const Color(0xFFFFD93D),
      ][i % 4].withOpacity(opacity * 0.6);

      canvas.drawCircle(
        Offset(x, y),
        2.0 + (math.sin(animationValue + i) * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
