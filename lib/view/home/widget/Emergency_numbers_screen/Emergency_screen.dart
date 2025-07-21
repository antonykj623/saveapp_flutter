import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/model_class_emergency.dart';
import 'package:url_launcher/url_launcher.dart';
import '../save_DB/Budegt_database_helper/Save_DB.dart';

class EmergencyNumbersScreen extends StatefulWidget {
  @override
  _EmergencyNumbersScreenState createState() => _EmergencyNumbersScreenState();
}

class _EmergencyNumbersScreenState extends State<EmergencyNumbersScreen>
    with TickerProviderStateMixin {
  List<EmergencyContact> emergencyContacts = [];
  List<EmergencyContact> filteredContacts = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  bool isLoading = true;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    'All',
    'Emergency Services',
    'Medical Emergency',
    'Support Services',
    'Custom',
  ];

  final Map<String, IconData> categoryIcons = {
    'Emergency Services': Icons.local_police,
    'Medical Emergency': Icons.medical_services,
    'Support Services': Icons.support_agent,
    'Custom': Icons.person_add,
  };

  final Map<String, Color> categoryColors = {
    'Emergency Services': Color(0xFFE53E3E),
    'Medical Emergency': Color(0xFF38A169),
    'Support Services': Color(0xFF3182CE),
    'Custom': Color(0xFF805AD5),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadContacts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => isLoading = true);
    try {
      final contacts = await _databaseHelper.getAllEmergencyContacts();
      setState(() {
        emergencyContacts = contacts;
        filteredContacts = contacts;
        isLoading = false;
      });
      _filterContacts();
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterContacts() {
    setState(() {
      filteredContacts =
          emergencyContacts.where((contact) {
            bool categoryMatch =
                selectedCategory == 'All' ||
                contact.category == selectedCategory ||
                (selectedCategory == 'Custom' && contact.isCustom);

            bool searchMatch =
                searchQuery.isEmpty ||
                contact.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                contact.phoneNumber.contains(searchQuery);

            return categoryMatch && searchMatch;
          }).toList();
    });
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddContactDialog(
          onContactAdded: (contact) async {
            final id = await _databaseHelper.insertEmergencyContact(contact);
            if (id > 0) {
              _loadContacts();
              _showSuccessSnackBar('Contact added successfully!');
            }
          },
        );
      },
    );
  }

  void _showEditContactDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddContactDialog(
          contact: contact,
          onContactAdded: (updatedContact) async {
            final result = await _databaseHelper.updateEmergencyContact(
              updatedContact,
            );
            if (result > 0) {
              _loadContacts();
              _showSuccessSnackBar('Contact updated successfully!');
            }
          },
        );
      },
    );
  }

  void _deleteContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete "${contact.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await _databaseHelper.deleteEmergencyContact(
                  contact.id!,
                );
                if (result > 0) {
                  _loadContacts();
                  _showSuccessSnackBar('Contact deleted successfully!');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(launchUri);
    } catch (e) {
      _showErrorSnackBar('Could not make phone call');
    }
  }

  void _sendWhatsApp(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } catch (e) {
      _showErrorSnackBar('Could not open WhatsApp');
    }
  }

  void _sendSMS(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
      await launchUrl(launchUri);
    } catch (e) {
      _showErrorSnackBar('Could not send SMS');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child:
                    isLoading
                        ? _buildLoadingWidget()
                        : filteredContacts.isEmpty
                        ? _buildEmptyWidget()
                        : _buildContactsList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quick access to help',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${filteredContacts.length}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
          _filterContacts();
        },
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        searchQuery = '';
                      });
                      _filterContacts();
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return Container(
            margin: EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.9),
              selectedColor: Color(0xFF667eea),
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
                _filterContacts();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Loading contacts...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            SizedBox(height: 16),
            Text(
              'No contacts found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or category filter',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          return _buildContactCard(contact, index);
        },
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    final categoryColor = categoryColors[contact.category] ?? Color(0xFF667eea);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _makePhoneCall(contact.phoneNumber),
              onLongPress:
                  contact.isCustom
                      ? () => _showEditContactDialog(contact)
                      : null,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            categoryIcons[contact.category] ?? Icons.phone,
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                contact.phoneNumber,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (contact.isCustom)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditContactDialog(contact);
                              } else if (value == 'delete') {
                                _deleteContact(contact);
                              }
                            },
                            itemBuilder:
                                (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                            child: Icon(Icons.more_vert, color: Colors.grey),
                          ),
                      ],
                    ),
                    if (contact.category != null) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contact.category!,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.phone,
                          label: 'Call',
                          color: Color(0xFF4CAF50),
                          onTap: () => _makePhoneCall(contact.phoneNumber),
                        ),
                        _buildActionButton(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: Color(0xFF25D366),
                          onTap: () => _sendWhatsApp(contact.phoneNumber),
                        ),
                        _buildActionButton(
                          icon: Icons.message,
                          label: 'SMS',
                          color: Color(0xFF2196F3),
                          onTap: () => _sendSMS(contact.phoneNumber),
                        ),
                        _buildActionButton(
                          icon: Icons.copy,
                          label: 'Copy',
                          color: Color(0xFF9C27B0),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: contact.phoneNumber),
                            );
                            _showSuccessSnackBar('Phone number copied!');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// Add Contact Dialog Widget
class _AddContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onContactAdded;

  const _AddContactDialog({
    Key? key,
    this.contact,
    required this.onContactAdded,
  }) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String selectedCategory = 'Custom';

  final List<String> categories = [
    'Emergency Services',
    'Medical Emergency',
    'Support Services',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      selectedCategory = widget.contact!.category ?? 'Custom';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.contact == null ? Icons.person_add : Icons.edit,
                  color: Color(0xFF667eea),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  widget.contact == null ? 'Add Contact' : 'Edit Contact',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Contact Name',
              icon: Icons.person,
              hint: 'Enter contact name',
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items:
                      categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _phoneController.text.isNotEmpty) {
                        final contact = EmergencyContact(
                          id: widget.contact?.id,
                          name: _nameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                          category: selectedCategory,
                          isCustom: true,
                        );
                        widget.onContactAdded(contact);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.contact == null ? 'Add' : 'Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF667eea)),
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
