import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';
import 'package:new_project_2025/app/Modules/accounts/global.dart';

import '../../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Editaccount extends StatefulWidget {
  final String keyid, year, accname, cat, obalance, actype;

  Editaccount({
    required this.keyid,  
    required this.year,
    required this.accname,
    required this.cat,
    required this.obalance,
    required this.actype,
  });

  @override
  State<Editaccount> createState() => _EditaccountState();
}

class _EditaccountState extends State<Editaccount> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController accountNameController;
  late TextEditingController openingBalanceController;

  String? selectedCategory;
  String? selectedType;
  String? selectedYear;

  bool isLoading = false;

  final List<String> categories = [
    'Asset Account',
    'Bank',
    'Cash',
    'Credit Card',
    'Customers',
    'Expense Account',
    'Income Account',
    'Insurance',
    'Investment',
    'Liability Account',
  ];

  final List<String> types = ['Debit', 'Credit'];

  final List<String> years = [
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
  ];

  @override
  void initState() {
    super.initState();

    accountNameController = TextEditingController(text: widget.accname);
    openingBalanceController = TextEditingController(text: widget.obalance);

    // Set initial dropdown values
    selectedCategory = widget.cat;
    selectedType = widget.actype;
    selectedYear = widget.year;

    // Validate initial values
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
    if (!types.contains(selectedType)) {
      selectedType = types.first;
    }
    if (!years.contains(selectedYear)) {
      selectedYear = years.first;
    }
  }

  @override
  void dispose() {
    accountNameController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null ||
        selectedType == null ||
        selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await DatabaseHelper().updateaccountdet(
        accountNameController.text.trim(),
        selectedCategory!,
        openingBalanceController.text.trim(),
        selectedType!,
        selectedYear!,
        widget.keyid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Account updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a moment then pop
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Edit Account', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Name Field
                _buildLabel('Account Name'),
                SizedBox(height: 8),
                TextFormField(
                  controller: accountNameController,
                  decoration: _buildInputDecoration(
                    hintText: 'Enter account name',
                    prefixIcon: Icons.account_balance,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Category Dropdown
                _buildLabel('Account Category'),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: _buildInputDecoration(
                    hintText: 'Select category',
                    prefixIcon: Icons.category,
                  ),
                  items:
                      categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Opening Balance Field
                _buildLabel('Opening Balance'),
                SizedBox(height: 8),
                TextFormField(
                  controller: openingBalanceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: _buildInputDecoration(
                    hintText: 'Enter opening balance',
                    prefixIcon: Icons.currency_rupee,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter opening balance';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Type Dropdown
                _buildLabel('Account Type (Nature)'),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: _buildInputDecoration(
                    hintText: 'Select type',
                    prefixIcon: Icons.swap_horiz,
                  ),
                  items:
                      types.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      type == 'Debit'
                                          ? Colors.orange
                                          : Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(type),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select account type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Year Dropdown
                _buildLabel('Financial Year'),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  decoration: _buildInputDecoration(
                    hintText: 'Select year',
                    prefixIcon: Icons.calendar_today,
                  ),
                  items:
                      years.map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select year';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                // Update Button
                ElevatedButton(
                  onPressed: isLoading ? null : _updateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 8),
                              Text(
                                'Update Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                ),
                SizedBox(height: 16),

                // Cancel Button
                OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.teal),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
