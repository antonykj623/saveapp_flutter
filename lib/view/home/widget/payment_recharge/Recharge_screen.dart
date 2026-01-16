import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Contact.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Rechargeapiclass.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/payment_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobileRechargeScreen extends StatefulWidget {
  @override
  _MobileRechargeScreenState createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _mobileController = TextEditingController();
  String? _selectedCircle;
  String? _selectedOperator;
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  bool _isLoadingPlans = false;
  bool _isPickingContact = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _operatorController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _operatorAnimation;

  static const platform = MethodChannel('com.example.contactpicker/channel');
  String? contactInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _mobileController.addListener(_onMobileNumberChanged);
    checkPermission();
  }

  checkPermission() async {
    await Permission.contacts.request();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mobileController.removeListener(_onMobileNumberChanged);
    _mobileController.dispose();
    if (_fadeController.isAnimating) _fadeController.stop();
    if (_slideController.isAnimating) _slideController.stop();
    if (_pulseController.isAnimating) _pulseController.stop();
    if (_operatorController.isAnimating) _operatorController.stop();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _operatorController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('📱 App lifecycle state: $state');

    if (state == AppLifecycleState.resumed) {
      debugPrint('✅ App resumed - contact picker returned');
      setState(() {
        _isPickingContact = false;
      });
    } else if (state == AppLifecycleState.paused) {
      if (_isPickingContact) {
        debugPrint('⏸️ App paused - contact picker opened');
      }
    }
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _operatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _operatorController, curve: Curves.elasticOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _operatorController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  // ✅ UPDATED: Only detect circle, NOT operator
  void _onMobileNumberChanged() {
    final number = _mobileController.text;
    if (number.length == 10) {
      _fetchCircleOnly(number);
    } else {
      if (mounted) {
        setState(() {
          _selectedCircle = null;
          // ✅ Don't reset operator - let user keep their selection
        });
      }
    }
  }

  // ✅ NEW: Only fetch circle, operator must be selected manually
  Future<void> _fetchCircleOnly(String mobile) async {
    try {
      final data = await MobilePlansApiService.fetchCircleAndOperator(mobile);
      if (data != null && mounted) {
        final circleCode = data['circle'];
        if (circleCode != null) {
          final index = operatorCircleCodes.indexOf(circleCode);
          if (index != -1) {
            final circleName = operatorCircles[index];
            setState(() {
              _selectedCircle = circleName;
            });
            _showSuccessSnackBar('Circle auto-detected: $circleName');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching circle: $e');
      // Don't show error message - circle can be selected manually
    }
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
      'description': "India's fastest network",
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
    } catch (e) {
      debugPrint('Permission error: $e');
      _showErrorSnackBar('Failed to request permission: ${e.toString()}');
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
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _isLoadingContacts = false;
          });
          _showPermissionDeniedMessage();
        }
        return;
      }
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );
      final contactsWithPhones =
          contacts.where((contact) {
            try {
              return contact.phones.isNotEmpty;
            } catch (e) {
              debugPrint('Error checking contact phones: $e');
              return false;
            }
          }).toList();

      contactsWithPhones.sort((a, b) {
        try {
          final nameA = a.displayName.toLowerCase();
          final nameB = b.displayName.toLowerCase();
          return nameA.compareTo(nameB);
        } catch (e) {
          debugPrint('Error sorting contacts: $e');
          return 0;
        }
      });

      if (mounted) {
        setState(() {
          _contacts = contactsWithPhones;
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
          _contacts = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Error loading contacts: ${e.toString()}'),
                ),
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
    if (_isPermissionRequesting || _isPickingContact) return;

    try {
      setState(() {
        _isPickingContact = true;
      });

      debugPrint('🔵 Opening native contact picker...');

      final result = await platform.invokeMethod('pickContact');

      debugPrint('🟢 Contact picker returned with result: $result');

      if (!mounted) return;

      setState(() {
        _isPickingContact = false;
      });

      if (result != null && result.toString().isNotEmpty) {
        String contactInfo = result.toString();
        debugPrint('📞 Contact info: $contactInfo');

        if (contactInfo.toLowerCase() == 'cancelled' ||
            contactInfo.toLowerCase().contains('no contact')) {
          debugPrint('⚠️ User cancelled or no contact selected');
          return;
        }

        String cleanNumber = '';

        List<RegExp> patterns = [
          RegExp(r'Phone:\s*([+\d\s\-()]+)'),
          RegExp(r'phone:\s*([+\d\s\-()]+)'),
          RegExp(r'Number:\s*([+\d\s\-()]+)'),
          RegExp(r'number:\s*([+\d\s\-()]+)'),
          RegExp(r',\s*([+\d\s\-()]{10,})'),
          RegExp(r'([+\d\s\-()]{10,})'),
        ];

        for (var pattern in patterns) {
          Match? match = pattern.firstMatch(contactInfo);
          if (match != null) {
            String phoneNumber = match.group(1) ?? '';
            cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

            if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
              cleanNumber = cleanNumber.substring(2);
            } else if (cleanNumber.startsWith('0') &&
                cleanNumber.length == 11) {
              cleanNumber = cleanNumber.substring(1);
            }

            if (cleanNumber.length == 10) {
              break;
            }
          }
        }

        if (cleanNumber.length == 10 &&
            RegExp(r'^[6-9]\d{9}$').hasMatch(cleanNumber)) {
          setState(() {
            _mobileController.text = cleanNumber;
          });

          String? contactName;
          final nameMatch = RegExp(r'Name:\s*([^,]+)').firstMatch(contactInfo);
          if (nameMatch != null) {
            contactName = nameMatch.group(1)?.trim();
          }

          _showSuccessSnackBar(
            contactName != null
                ? 'Selected: $contactName ($cleanNumber)'
                : 'Number selected: $cleanNumber',
          );
        } else if (cleanNumber.isNotEmpty) {
          debugPrint(
            '❌ Invalid number length or format: $cleanNumber (${cleanNumber.length} digits)',
          );
          _showErrorSnackBar(
            'Invalid phone number format. Please enter manually.',
          );
        } else {
          debugPrint('❌ Could not extract phone number from: $contactInfo');
          _showErrorSnackBar(
            'Could not extract phone number. Please try again.',
          );
        }
      } else {
        debugPrint('⚠️ No contact selected or result is empty');
      }
    } on PlatformException catch (e) {
      debugPrint(
        '❌ Platform exception in contact picker: ${e.code} - ${e.message}',
      );

      if (mounted) {
        setState(() {
          _isPickingContact = false;
        });

        if (e.code != 'cancelled' &&
            e.code != 'CANCEL' &&
            !e.message.toString().toLowerCase().contains('cancel')) {
          _showErrorSnackBar('Failed to access contacts: ${e.message}');
        }
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout exception: $e');

      if (mounted) {
        setState(() {
          _isPickingContact = false;
        });
        _showErrorSnackBar('Contact picker timed out. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in contact picker: $e');

      if (mounted) {
        setState(() {
          _isPickingContact = false;
        });

        if (!e.toString().toLowerCase().contains('cancel')) {
          _showErrorSnackBar('Unexpected error. Please try again.');
        }
      }
    }
  }

  void _showSuccessSnackBar(String message) {
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
      debugPrint('Error fetching plans: $e');
    }
  }

  void _showErrorSnackBar(String message) {
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
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value.clamp(0.0, 1.0),
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
                                              onTap:
                                                  _isPickingContact
                                                      ? null
                                                      : _showContactPicker,
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
                                                    _isPickingContact
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
                                                  child: Text(
                                                    circle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
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
                                    _buildSectionTitle('Select Operator'),
                                    SizedBox(height: 16),
                                    AnimatedBuilder(
                                      animation: _operatorAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _operatorAnimation.value.clamp(
                                            0.1,
                                            1.0,
                                          ),
                                          child: Opacity(
                                            opacity: _operatorAnimation.value
                                                .clamp(0.0, 1.0),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final screenWidth =
                                                    constraints.maxWidth;
                                                final crossAxisCount =
                                                    screenWidth > 600 ? 4 : 2;
                                                final childAspectRatio =
                                                    screenWidth > 600
                                                        ? 1.1
                                                        : 1.0;
                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount:
                                                            crossAxisCount,
                                                        childAspectRatio:
                                                            childAspectRatio,
                                                        crossAxisSpacing: 12,
                                                        mainAxisSpacing: 12,
                                                      ),
                                                  itemCount:
                                                      mobileOperators.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final operator =
                                                        mobileOperators[index];
                                                    final isSelected =
                                                        _selectedOperator ==
                                                        operator['code'];
                                                    return GestureDetector(
                                                      onTap:
                                                          () =>
                                                              _onOperatorSelected(
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
                                                                      Colors
                                                                          .white,
                                                                      Color(
                                                                        0xFFF8F9FA,
                                                                      ),
                                                                    ],
                                                                  ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
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
                                                                isSelected
                                                                    ? 2
                                                                    : 1,
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
                                                                      : Colors
                                                                          .black
                                                                          .withOpacity(
                                                                            0.05,
                                                                          ),
                                                              blurRadius:
                                                                  isSelected
                                                                      ? 15
                                                                      : 8,
                                                              offset: Offset(
                                                                0,
                                                                isSelected
                                                                    ? 6
                                                                    : 3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                12,
                                                              ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Flexible(
                                                                flex: 3,
                                                                child: Container(
                                                                  constraints:
                                                                      BoxConstraints(
                                                                        maxWidth:
                                                                            50,
                                                                        maxHeight:
                                                                            50,
                                                                        minWidth:
                                                                            35,
                                                                        minHeight:
                                                                            35,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                              0.1,
                                                                            ),
                                                                        blurRadius:
                                                                            6,
                                                                        offset:
                                                                            Offset(
                                                                              0,
                                                                              3,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          12,
                                                                        ),
                                                                    child: Image.asset(
                                                                      operator['asset']
                                                                          as String,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
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
                                                                            borderRadius: BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                          ),
                                                                          child: Center(
                                                                            child: Text(
                                                                              operator['name'].toString()[0],
                                                                              style: TextStyle(
                                                                                color:
                                                                                    Colors.white,
                                                                                fontSize:
                                                                                    18,
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
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Flexible(
                                                                flex: 2,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      operator['name']
                                                                          as String,
                                                                      style: TextStyle(
                                                                        color:
                                                                            isSelected
                                                                                ? Colors.white
                                                                                : Color(
                                                                                  0xFF1A202C,
                                                                                ),
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    SizedBox(
                                                                      height: 2,
                                                                    ),
                                                                    Text(
                                                                      operator['description']
                                                                          as String,
                                                                      style: TextStyle(
                                                                        color:
                                                                            isSelected
                                                                                ? Colors.white.withOpacity(
                                                                                  0.9,
                                                                                )
                                                                                : Color(
                                                                                  0xFF718096,
                                                                                ),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (isSelected) ...[
                                                                SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.2,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
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
                                                                            Colors.white,
                                                                        size:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      Text(
                                                                        'SELECTED',
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              8,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 40),
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
                                                  ? _pulseAnimation.value.clamp(
                                                    0.95,
                                                    1.05,
                                                  )
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
                                                          Flexible(
                                                            child: Text(
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
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
