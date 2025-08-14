import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Contact.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Rechargeapiclass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobileRechargeScreen extends StatefulWidget {
  @override
  _MobileRechargeScreenState createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _mobileController = TextEditingController();
  String? _selectedCircle;
  String? _selectedOperator;
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  bool _isLoadingPlans = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _operatorController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _operatorAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _mobileController.addListener(_onMobileNumberChanged);
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );
    _operatorController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _operatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _operatorController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _operatorController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _onMobileNumberChanged() {
    final number = _mobileController.text;
    if (number.length == 10) {
      _fetchCircleAndOperator(number);
    }
  }

  Future<void> _fetchCircleAndOperator(String mobile) async {
    try {
      final data = await MobilePlansApiService.fetchCircleAndOperator(mobile);
      if (data != null) {
        final circleCode = data['circle'];
        final index = operatorCircleCodes.indexOf(circleCode);
        if (index != -1) {
          final circleName = operatorCircles[index];
          setState(() {
            _selectedCircle = circleName;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to fetch circle details');
    }
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileNumberChanged);
    _mobileController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _operatorController.dispose();
    super.dispose();
  }

  static const List<String> operatorCircleCodes = [
    "AP",
    "AS",
    "BR",
    "DL",
    "GJ",
    "HP",
    "HR",
    "JK",
    "KL",
    "KA",
    "KO",
    "MH",
    "MP",
    "MU",
    "NE",
    "OR",
    "PB",
    "RJ",
    "TN",
    "UE",
    "UW",
    "WB",
  ];

  static const List<String> operatorCircles = [
    "Andhra Pradesh",
    "Assam",
    "Bihar and Jharkhand",
    "Delhi Metro",
    "Gujarat",
    "Himachal Pradesh",
    "Haryana",
    "Jammu and Kashmir",
    "Kerala",
    "Karnataka",
    "Kolkata Metro",
    "Maharashtra",
    "Madhya Pradesh and Chhattisgarh",
    "Mumbai Metro",
    "North East India",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Uttar Pradesh(East)",
    "Uttar Pradesh (West) and Uttarakhand",
    "West Bengal",
  ];

  final List<Map<String, dynamic>> mobileOperators = [
    {
      'name': 'Airtel',
      'asset': 'assets/Airtel.jpg',
      'code': 'AIRTEL',
      'color': Colors.red,
      'gradient': [Color(0xFFE53E3E), Color(0xFFC53030)],
      'description': 'India\'s fastest network',
    },
    {
      'name': 'BSNL',
      'asset': 'assets/bsl.jpg',
      'code': 'BSNL',
      'color': Colors.blue,
      'gradient': [Color(0xFF3182CE), Color(0xFF2B6CB0)],
      'description': 'Connecting India',
    },
    {
      'name': 'Vi',
      'asset': 'assets/vi.jpg',
      'code': 'VI',
      'color': Colors.purple,
      'gradient': [Color(0xFF805AD5), Color(0xFF6B46C1)],
      'description': 'Be limitless',
    },
    {
      'name': 'Jio',
      'asset': 'assets/jio.jpg',
      'code': 'JIO',
      'color': Colors.indigo,
      'gradient': [Color(0xFF4C51BF), Color(0xFF3730A3)],
      'description': 'Digital India',
    },
  ];

  bool _isPermissionRequesting = false;

  Future<void> _requestContactPermission() async {
    if (_isPermissionRequesting) return;

    _isPermissionRequesting = true;

    try {
      final permission = await Permission.contacts.status;

      if (permission == PermissionStatus.granted) {
        await _loadContacts();
      } else if (permission == PermissionStatus.denied) {
        final result = await Permission.contacts.request();
        if (result == PermissionStatus.granted) {
          await _loadContacts();
        } else {
          _showPermissionDeniedMessage();
        }
      } else if (permission == PermissionStatus.permanentlyDenied) {
        _showPermissionPermanentlyDeniedMessage();
      } else {
        final result = await Permission.contacts.request();
        if (result == PermissionStatus.granted) {
          await _loadContacts();
        } else {
          _showPermissionDeniedMessage();
        }
      }
    } finally {
      _isPermissionRequesting = false;
    }
  }

  void _showPermissionDeniedMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact permission denied. Please enable it in settings.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showPermissionPermanentlyDeniedMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact permission permanently denied. Please enable it in settings.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _loadContacts() async {
    if (_isLoadingContacts) return;

    setState(() {
      _isLoadingContacts = true;
    });

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      final contactsWithPhones =
          contacts.where((contact) => contact.phones.isNotEmpty).toList();
      contactsWithPhones.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

      if (mounted) {
        setState(() {
          _contacts = contactsWithPhones;
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('Error loading contacts: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showContactPicker() async {
    if (_isPermissionRequesting) return;

    if (_contacts.isEmpty && !_isLoadingContacts) {
      final permission = await Permission.contacts.status;

      if (permission == PermissionStatus.granted) {
        await _loadContacts();
      } else {
        await _requestContactPermission();
        return;
      }
    }

    if (_contacts.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => ContactPickerBottomSheet(
              contacts: _contacts,
              isLoading: _isLoadingContacts,
              onContactSelected: (contact, phoneNumber) {
                setState(() {
                  String cleanNumber = phoneNumber.replaceAll(
                    RegExp(r'[^\d]'),
                    '',
                  );
                  if (cleanNumber.startsWith('91') &&
                      cleanNumber.length == 12) {
                    cleanNumber = cleanNumber.substring(2);
                  }
                  _mobileController.text = cleanNumber;
                });
                Navigator.pop(context);
                _showSuccessSnackBar(
                  'Selected: ${contact.displayName} - $phoneNumber',
                );
              },
            ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _onOperatorSelected(String code) {
    setState(() {
      _selectedOperator = code;
    });
    HapticFeedback.lightImpact();

    final operator = mobileOperators.firstWhere((op) => op['code'] == code);
    _showSuccessSnackBar(
      'Selected ${operator['name']} - ${operator['description']}',
    );
  }

  void _onRecharge() async {
    if (_mobileController.text.isEmpty ||
        _selectedCircle == null ||
        _selectedOperator == null) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    setState(() {
      _isLoadingPlans = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final planResponse = await MobilePlansApiService.fetchMobilePlans(
        mobileNumber: _mobileController.text,
        circle: _selectedCircle!,
        operatorCode: _selectedOperator!,
      );

      setState(() {
        _isLoadingPlans = false;
      });

      if (planResponse != null && planResponse.status == 'OK') {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => RechargePlansScreen(
                  mobileNumber: _mobileController.text,
                  operator: _selectedOperator!,
                  circle: _selectedCircle!,
                  operatorData: mobileOperators.firstWhere(
                    (op) => op['code'] == _selectedOperator,
                  ),
                  planResponse: planResponse,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 600),
          ),
        );
      } else {
        _showErrorSnackBar('Failed to fetch recharge plans. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoadingPlans = false;
      });
      _showErrorSnackBar('Network error. Please check your connection.');
      print('Error fetching plans: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFf093fb)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Mobile Recharge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
              ),

              // Main Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Handle
                            Container(
                              width: 50,
                              height: 5,
                              margin: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),

                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),

                                    // Mobile Number Section
                                    _buildSectionTitle('Mobile Number'),
                                    SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFF8F9FA),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(0xFFE2E8F0),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 15,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _mobileController,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                              decoration: InputDecoration(
                                                hintText: 'Enter mobile number',
                                                hintStyle: TextStyle(
                                                  color: Color(0xFF718096),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                prefixIcon: Container(
                                                  padding: EdgeInsets.all(16),
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF667EEA),
                                                          Color(0xFF764BA2),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.phone_android,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 18,
                                                    ),
                                                counterText: '',
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A202C),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(right: 12),
                                            child: GestureDetector(
                                              onTap: _showContactPicker,
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF4CAF50),
                                                      Color(0xFF45A049),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(
                                                        0xFF4CAF50,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child:
                                                    _isLoadingContacts
                                                        ? SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                        : Icon(
                                                          Icons.contacts,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 32),

                                    // Circle Selection Section
                                    _buildSectionTitle('Select Circle'),
                                    SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFF8F9FA),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(0xFFE2E8F0),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 15,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCircle,
                                          hint: Text(
                                            'Choose your circle',
                                            style: TextStyle(
                                              color: Color(0xFF718096),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF667EEA),
                                                  Color(0xFF764BA2),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A202C),
                                          ),
                                          items:
                                              operatorCircles.map((circle) {
                                                return DropdownMenuItem<String>(
                                                  value: circle,
                                                  child: Text(circle),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCircle = value;
                                            });
                                            if (value != null) {
                                              HapticFeedback.lightImpact();
                                              _showSuccessSnackBar(
                                                'Selected circle: $value',
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 32),

                                    // Operator Selection Section
                                    _buildSectionTitle('Select Operator'),
                                    SizedBox(height: 16),
                                    AnimatedBuilder(
                                      animation: _operatorAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _operatorAnimation.value,
                                          child: Opacity(
                                            opacity: _operatorAnimation.value,
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    childAspectRatio: 1.2,
                                                    crossAxisSpacing: 16,
                                                    mainAxisSpacing: 16,
                                                  ),
                                              itemCount: mobileOperators.length,
                                              itemBuilder: (context, index) {
                                                final operator =
                                                    mobileOperators[index];
                                                final isSelected =
                                                    _selectedOperator ==
                                                    operator['code'];

                                                return GestureDetector(
                                                  onTap:
                                                      () => _onOperatorSelected(
                                                        operator['code'],
                                                      ),
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          isSelected
                                                              ? LinearGradient(
                                                                colors:
                                                                    operator['gradient']
                                                                        as List<
                                                                          Color
                                                                        >,
                                                              )
                                                              : LinearGradient(
                                                                colors: [
                                                                  Colors.white,
                                                                  Color(
                                                                    0xFFF8F9FA,
                                                                  ),
                                                                ],
                                                              ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            isSelected
                                                                ? operator['color']
                                                                    as Color
                                                                : Color(
                                                                  0xFFE2E8F0,
                                                                ),
                                                        width:
                                                            isSelected ? 3 : 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              isSelected
                                                                  ? (operator['color']
                                                                          as Color)
                                                                      .withOpacity(
                                                                        0.3,
                                                                      )
                                                                  : Colors.black
                                                                      .withOpacity(
                                                                        0.08,
                                                                      ),
                                                          blurRadius:
                                                              isSelected
                                                                  ? 20
                                                                  : 10,
                                                          offset: Offset(
                                                            0,
                                                            isSelected ? 8 : 4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset: Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            child: Image.asset(
                                                              operator['asset']
                                                                  as String,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  decoration: BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                      colors:
                                                                          operator['gradient']
                                                                              as List<
                                                                                Color
                                                                              >,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          16,
                                                                        ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      operator['name']
                                                                          .toString()[0],
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            24,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(
                                                          operator['name']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : Color(
                                                                      0xFF1A202C,
                                                                    ),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          operator['description']
                                                              as String,
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.9,
                                                                        )
                                                                    : Color(
                                                                      0xFF718096,
                                                                    ),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        if (isSelected) ...[
                                                          SizedBox(height: 8),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  size: 14,
                                                                ),
                                                                SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  'SELECTED',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 40),

                                    // Recharge Button
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) {
                                        final canRecharge =
                                            _mobileController.text.length ==
                                                10 &&
                                            _selectedCircle != null &&
                                            _selectedOperator != null;

                                        return Transform.scale(
                                          scale:
                                              canRecharge
                                                  ? _pulseAnimation.value
                                                  : 1.0,
                                          child: Container(
                                            width: double.infinity,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  canRecharge
                                                      ? LinearGradient(
                                                        colors: [
                                                          Color(0xFF4CAF50),
                                                          Color(0xFF45A049),
                                                        ],
                                                      )
                                                      : LinearGradient(
                                                        colors: [
                                                          Color(0xFFE2E8F0),
                                                          Color(0xFFCBD5E0),
                                                        ],
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow:
                                                  canRecharge
                                                      ? [
                                                        BoxShadow(
                                                          color: Color(
                                                            0xFF4CAF50,
                                                          ).withOpacity(0.4),
                                                          blurRadius: 20,
                                                          offset: Offset(0, 8),
                                                        ),
                                                      ]
                                                      : [],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed:
                                                  canRecharge &&
                                                          !_isLoadingPlans
                                                      ? _onRecharge
                                                      : null,
                                              child:
                                                  _isLoadingPlans
                                                      ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            'Loading Plans...',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.shopping_cart,
                                                            size: 24,
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            'View Plans & Recharge',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  canRecharge
                                                                      ? Colors
                                                                          .white
                                                                      : Color(
                                                                        0xFF718096,
                                                                      ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 20),

                                    // Info Card
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF667EEA).withOpacity(0.1),
                                            Color(0xFF764BA2).withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(
                                            0xFF667EEA,
                                          ).withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF667EEA),
                                                      Color(0xFF764BA2),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.info_outline,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Quick Tips',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A202C),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          _buildTipRow(
                                            '✓',
                                            'Instant recharge with 100% success rate',
                                          ),
                                          _buildTipRow(
                                            '✓',
                                            'Secure payment gateway protected',
                                          ),
                                          _buildTipRow(
                                            '✓',
                                            'Best prices with exclusive offers',
                                          ),
                                          _buildTipRow(
                                            '✓',
                                            '24/7 customer support available',
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A202C),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTipRow(String icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactPickerBottomSheet extends StatefulWidget {
  final List<Contact> contacts;
  final bool isLoading;
  final Function(Contact, String) onContactSelected;

  const ContactPickerBottomSheet({
    Key? key,
    required this.contacts,
    required this.isLoading,
    required this.onContactSelected,
  }) : super(key: key);

  @override
  _ContactPickerBottomSheetState createState() =>
      _ContactPickerBottomSheetState();
}

class _ContactPickerBottomSheetState extends State<ContactPickerBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> filteredContacts = [];
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = widget.contacts;
      } else {
        filteredContacts =
            widget.contacts.where((contact) {
              final name = contact.displayName.toLowerCase();
              final phones = contact.phones
                  .map((phone) => phone.number)
                  .join(' ');
              return name.contains(query.toLowerCase()) ||
                  phones.contains(query);
            }).toList();
      }
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value.clamp(0.0, 1.0)) * 400),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFAFBFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Contact',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                          if (!widget.isLoading)
                            Text(
                              '${filteredContacts.length} contacts available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Color(0xFF718096),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8F9FA), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search contacts or numbers...',
                      hintStyle: TextStyle(
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Color(0xFF718096),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterContacts('');
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: _filterContacts,
                  ),
                ),
                Expanded(
                  child:
                      widget.isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFF34A853),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF4285F4,
                                        ).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Loading contacts...',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF1A202C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please wait while we fetch your contacts',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : filteredContacts.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF7FAFC),
                                        Color(0xFFEDF2F7),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_search,
                                    size: 48,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'No contacts found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF1A202C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search terms',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              final phones = contact.phones;

                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.only(bottom: 12),
                                child:
                                    phones.isEmpty
                                        ? SizedBox.shrink()
                                        : phones.length == 1
                                        ? _buildGooglePayContactTile(
                                          contact,
                                          phones[0].number,
                                        )
                                        : _buildExpandableContactTile(
                                          contact,
                                          phones,
                                        ),
                              );
                            },
                          ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF4285F4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4285F4).withOpacity(0.15),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4285F4),
                                      Color(0xFF1a73e8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.keyboard,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Enter Number Manually',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGooglePayContactTile(Contact contact, String phoneNumber) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFFAFBFC)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onContactSelected(contact, phoneNumber),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildGooglePayAvatar(contact),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4285F4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContactTile(Contact contact, List<Phone> phones) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFFAFBFC)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: _buildGooglePayAvatar(contact),
        title: Text(
          contact.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        subtitle: Text(
          '${phones.length} numbers available',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        children:
            phones.map((phone) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap:
                        () => widget.onContactSelected(contact, phone.number),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(width: 56), // Space for avatar alignment
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phone.number,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A202C),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  phone.label.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF718096),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF4285F4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.phone,
                              color: Color(0xFF4285F4),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildGooglePayAvatar(Contact contact) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4285F4).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(contact.displayName),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
