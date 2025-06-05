import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/Emergency_screen.dart';

class AddContactDialog extends StatefulWidget {
  final Function(EmergencyContact) onContactAdded;

  AddContactDialog({required this.onContactAdded});

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _saveContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      final contact = EmergencyContact(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      widget.onContactAdded(contact);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 600,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 32),
            GestureDetector(
              onTap: _saveContact,
              child: Container(
                width: 120,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Color(0xFF2E8B7A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF096868),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

  class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Numbers',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
      home: EmergencyNumbersScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
