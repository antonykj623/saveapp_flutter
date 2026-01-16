import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BBSServicePage extends StatefulWidget {
  const BBSServicePage({super.key});

  @override
  State<BBSServicePage> createState() => _BBSServicePageState();
}

class _BBSServicePageState extends State<BBSServicePage> {
  String userName = '';
  String regCode = '';
  String profileImageUrl = '';
  bool isLoading = true;
  final ApiHelper apiHelper = ApiHelper();
  int a = 1;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      setState(() => isLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      String response = await apiHelper.postApiResponse(
        "getUserDetails.php",
        {},
      );

      debugPrint("Profile Response: $response");

      var jsonResponse = json.decode(response);

      if (jsonResponse['status'] == 1) {
        var data = jsonResponse['data'];

        String baseUrl = "https://mysaving.in/uploads/profile/";
        String profileImage = data['profile_image'] ?? '';

        setState(() {
          userName = data['full_name'] ?? 'User';
          regCode = data['reg_code'] ?? ''; // Added reg_code
          profileImageUrl =
              profileImage.isNotEmpty ? baseUrl + profileImage : '';
          isLoading = false;
        });
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() {
        isLoading = false;
        userName = 'User';
        regCode = '';
        profileImageUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Logo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section with Profile
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  'HELLO!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Picture
                isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to profile page if needed
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  profileImageUrl.isNotEmpty
                                      ? Image.network(
                                        profileImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            'assets/nonprofileimage.png',
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey[400],
                                              );
                                            },
                                          );
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                      )
                                      : Image.asset(
                                        'assets/nonprofileimage.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[400],
                                          );
                                        },
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // User Name
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Registration Code
                        if (regCode.isNotEmpty)
                          Text(
                            regCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Service Categories Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // First Row - Bill Payments, Credit Card, Loan, FD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildServiceButton(
                      icon: Icons.receipt_long,
                      label: 'Bill\nPayments',
                      color: Colors.blue,
                    ),
                    _buildServiceButton(
                      icon: Icons.credit_card,
                      label: 'Credit\nCard',
                      color: Colors.orange,
                    ),
                    _buildServiceButton(
                      icon: Icons.account_balance,
                      label: 'Loan',
                      color: Colors.green,
                    ),
                    _buildServiceButton(
                      icon: Icons.savings,
                      label: 'FD',
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Services Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Second Row - Shopping, Travel, Offers, Property
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildServiceButton(
                      icon: Icons.shopping_bag,
                      label: 'Shopping',
                      color: Colors.pink,
                    ),
                    _buildServiceButton(
                      icon: Icons.flight,
                      label: 'Travel',
                      color: Colors.teal,
                    ),
                    _buildServiceButton(
                      icon: Icons.local_offer,
                      label: 'Offers',
                      color: Colors.red,
                    ),
                    _buildServiceButton(
                      icon: Icons.home,
                      label: 'Property',
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
