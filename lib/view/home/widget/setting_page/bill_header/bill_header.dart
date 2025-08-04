import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/view/home/widget/setting_page/bill_header/bill_class.dart';

import '../../save_DB/Budegt_database_helper/Save_DB.dart';

// Bill Details Screen with Attractive UI
class BillDetailsScreen extends StatefulWidget {
  @override
  _BillDetailsScreenState createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _searchController = TextEditingController();

  List<BillDetails> billDetailsList = [];
  List<BillDetails> filteredBillDetails = [];
  bool isLoading = false;
  bool showForm = false;
  BillDetails? editingBill;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fabController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _loadBillDetails();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // Load all bill details from database
  Future<void> _loadBillDetails() async {
    setState(() => isLoading = true);
    try {
      final bills = await DatabaseHelper().getAllBillDetails();
      setState(() {
        billDetailsList = bills;
        filteredBillDetails = bills;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Error loading bill details: $e', isError: true);
    }
  }

  // Search functionality
  void _searchBillDetails(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBillDetails = billDetailsList;
      } else {
        filteredBillDetails = billDetailsList
            .where((bill) =>
                bill.companyName.toLowerCase().contains(query.toLowerCase()) ||
                bill.mobile.contains(query))
            .toList();
      }
    });
  }

  // Save or update bill details
  Future<void> _saveBillDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final billDetails = BillDetails(
        id: editingBill?.id,
        companyName: _companyNameController.text.trim(),
        address: _addressController.text.trim(),
        mobile: _mobileController.text.trim(),
      );

      int result;
      if (editingBill != null) {
        result = await DatabaseHelper().updateBillDetails(editingBill!.id!, billDetails);
        _showSnackbar('✅ Bill details updated successfully!');
      } else {
        result = await DatabaseHelper().insertBillDetails(billDetails);
        _showSnackbar('✅ Bill details added successfully!');
      }

      if (result > 0) {
        _clearForm();
        _loadBillDetails();
      }
    } catch (e) {
      _showSnackbar('Error saving bill details: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Delete bill details
  Future<void> _deleteBillDetails(int id) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      final result = await DatabaseHelper().deleteBillDetails(id);
      if (result > 0) {
        _showSnackbar('✅ Bill details deleted successfully!');
        _loadBillDetails();
      }
    } catch (e) {
      _showSnackbar('Error deleting bill details: $e', isError: true);
    }
  }

  // Edit bill details
  void _editBillDetails(BillDetails bill) {
    setState(() {
      editingBill = bill;
      _companyNameController.text = bill.companyName;
      _addressController.text = bill.address;
      _mobileController.text = bill.mobile;
      showForm = true;
    });
    _fabController.forward();
  }

  // Clear form
  void _clearForm() {
    _companyNameController.clear();
    _addressController.clear();
    _mobileController.clear();
    setState(() {
      editingBill = null;
      showForm = false;
    });
    _fabController.reverse();
  }

  // Show snackbar
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete this bill details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Build App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[600]!, Colors.purple[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${billDetailsList.length} Companies',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (showForm)
          IconButton(
            onPressed: _clearForm,
            icon: Icon(Icons.close, color: Colors.white),
          ),
      ],
    );
  }

  // Build Body
  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            SizedBox(height: 16),
            Text(
              'Loading bill details...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: showForm ? _buildForm() : _buildList(),
    );
  }

  // Build Form
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              SizedBox(height: 24),
              _buildCompanyNameField(),
              SizedBox(height: 16),
              _buildAddressField(),
              SizedBox(height: 16),
              _buildMobileField(),
              SizedBox(height: 32),
              _buildFormButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Build Form Header
  Widget _buildFormHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo[500],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              editingBill != null ? Icons.edit : Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editingBill != null ? 'Edit Bill Details' : 'Add New Bill Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  editingBill != null 
                    ? 'Update company information'
                    : 'Enter company information for billing',
                  style: TextStyle(
                    color: Colors.indigo[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Company Name Field
  Widget _buildCompanyNameField() {
    return _buildFormField(
      controller: _companyNameController,
      label: 'Company Name',
      icon: Icons.business,
      hint: 'Enter company name',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Company name is required';
        }
        return null;
      },
    );
  }

  // Build Address Field
  Widget _buildAddressField() {
    return _buildFormField(
      controller: _addressController,
      label: 'Address',
      icon: Icons.location_on,
      hint: 'Enter company address',
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Address is required';
        }
        return null;
      },
    );
  }

  // Build Mobile Field
  Widget _buildMobileField() {
    return _buildFormField(
      controller: _mobileController,
      label: 'Mobile Number',
      icon: Icons.phone,
      hint: 'Enter mobile number',
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Mobile number is required';
        }
        if (value.length < 10) {
          return 'Enter a valid mobile number';
        }
        return null;
      },
    );
  }

  // Build Form Field
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo[600]),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[500]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(icon, color: Colors.grey[500], size: 20),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  // Build Form Buttons
  Widget _buildFormButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearForm,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 20),
                SizedBox(width: 8),
                Text('Cancel'),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveBillDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[500],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  editingBill != null ? 'Update' : 'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build List
  Widget _buildList() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: billDetailsList.isEmpty
              ? _buildEmptyState()
              : _buildBillList(),
        ),
      ],
    );
  }

  // Build Search Bar
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchBillDetails,
        decoration: InputDecoration(
          hintText: 'Search by company name or mobile...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchBillDetails('');
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // Build Bill List
  Widget _buildBillList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredBillDetails.length,
        itemBuilder: (context, index) {
          final bill = filteredBillDetails[index];
          return _buildBillCard(bill, index);
        },
      ),
    );
  }

  // Build Bill Card
  Widget _buildBillCard(BillDetails bill, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[400]!, Colors.purple[400]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.companyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${bill.id}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActionButtons(bill),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.location_on, 'Address', bill.address),
                SizedBox(height: 8),
                _buildInfoRow(Icons.phone, 'Mobile', bill.mobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Info Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Build Action Buttons
  Widget _buildActionButtons(BillDetails bill) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _editBillDetails(bill),
          icon: Icon(Icons.edit, color: Colors.blue[600]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          onPressed: () => _deleteBillDetails(bill.id!),
          icon: Icon(Icons.delete, color: Colors.red[600]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Bill Details Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first company bill details to get started',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() => showForm = true),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add Bill Details',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[500],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Floating Action Button
  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          setState(() => showForm = !showForm);
          if (showForm) {
            _fabController.forward();
          } else {
            _fabController.reverse();
          }
        },
        backgroundColor: Colors.indigo[500],
        elevation: 4,
        icon: Icon(
          showForm ? Icons.list : Icons.add,
          color: Colors.white,
        ),
        label: Text(
          showForm ? 'View List' : 'Add Bill',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}