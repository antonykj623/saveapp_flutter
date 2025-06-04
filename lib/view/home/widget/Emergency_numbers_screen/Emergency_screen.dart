import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/Add_contact_dailoge_box.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContact {
  final String name;
  final String phoneNumber;

  EmergencyContact({required this.name, required this.phoneNumber});
}

class EmergencyNumbersScreen extends StatefulWidget {
  @override
  _EmergencyNumbersScreenState createState() => _EmergencyNumbersScreenState();
}

class _EmergencyNumbersScreenState extends State<EmergencyNumbersScreen> {
  List<EmergencyContact> emergencyContacts = [
    EmergencyContact(name: "Disaster Management Services", phoneNumber: "108"),
    EmergencyContact(name: "Women Helpline", phoneNumber: "1091"),
    EmergencyContact(
      name: "Women Helpline(Domestic Abuse)",
      phoneNumber: "181",
    ),
  ];

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddContactDialog(
          onContactAdded: (contact) {
            setState(() {
              emergencyContacts.add(contact);
            });
          },
        );
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  void _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E8B7A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Emergency Numbers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      ' : ',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Expanded(
                      child: Text(
                        contact.name,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Phone No.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      ' : ',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _makePhoneCall(contact.phoneNumber),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E8B7A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.phone, color: Colors.white, size: 24),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => _sendWhatsApp(contact.phoneNumber),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chat, color: Colors.white, size: 24),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => _sendSMS(contact.phoneNumber),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Color(0xFFE91E63),
        child: Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 4,
      ),
    );
  }
}

