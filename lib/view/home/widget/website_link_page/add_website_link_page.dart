import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/Website_link_page.dart';

class AddEditWebLinkPage extends StatefulWidget {
  final WebLink? webLink;
  final bool isEdit;
  final Function(WebLink) onSave;

  AddEditWebLinkPage({this.webLink, this.isEdit = false, required this.onSave});

  @override
  _AddEditWebLinkPageState createState() => _AddEditWebLinkPageState();
}

class _AddEditWebLinkPageState extends State<AddEditWebLinkPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _websiteLinkController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _websiteLinkController = TextEditingController(
      text: widget.webLink?.websiteLink ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.webLink?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.webLink?.password ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.webLink?.description ?? '',
    );
  }

  @override
  void dispose() {
    _websiteLinkController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.teal[600],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Web Links',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(24),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: _websiteLinkController,
                    label: 'WebLink',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'User Name',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveWebLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        widget.isEdit ? 'Update' : 'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.pink[600],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  void _saveWebLink() {
    if (_formKey.currentState!.validate()) {
      final webLink = WebLink(
        websiteLink: _websiteLinkController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        description: _descriptionController.text,
      );

      widget.onSave(webLink);
      Navigator.pop(context);
    }
  }
}