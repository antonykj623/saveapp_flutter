import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/model/insurance.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/custom_textfield_insurance/Custom_textfield.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/insurance_database.dart';

class InsuranceEntryPage extends StatefulWidget {
  final Insurance? insurance;

  const InsuranceEntryPage({Key? key, this.insurance}) : super(key: key);

  @override
  State<InsuranceEntryPage> createState() => _InsuranceEntryPageState();
}

class _InsuranceEntryPageState extends State<InsuranceEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late TextEditingController _accountNameController;
  late TextEditingController _amountController;
  late TextEditingController _premiumAmountController;
  late TextEditingController _paymentDateController;
  late TextEditingController _closingDateController;
  late TextEditingController _remarksController;

  String? _selectedInsuranceType;
  String _selectedPaymentFrequency = 'Monthly';
  DateTime? _paymentDate;
  DateTime? _closingDate;

  List<String> _insuranceAccounts = [
    'Insurance 1',
    'Insurance 2', 
    'Insurance 3'
  ];

  final List<String> _insuranceTypes = [
    'Life Insurance',
    'Health Insurance',
    'Car Insurance',
    'Home Insurance',
    'Travel Insurance',
  ];

  final List<String> _paymentFrequencies = [
    'Monthly',
    'Quarterly',
    'Half yearly',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.insurance != null) {
      _loadInsuranceData();
    }
  }

  void _initializeControllers() {
    _accountNameController = TextEditingController();
    _amountController = TextEditingController();
    _premiumAmountController = TextEditingController();
    _paymentDateController = TextEditingController();
    _closingDateController = TextEditingController();
    _remarksController = TextEditingController();
  }

  void _loadInsuranceData() {
    final insurance = widget.insurance!;
    _accountNameController.text = insurance.accountName;
    _amountController.text = insurance.amount.toString();
    _premiumAmountController.text = insurance.premiumAmount.toString();
    _selectedInsuranceType = insurance.insuranceType.isNotEmpty
        ? insurance.insuranceType
        : null;
    _selectedPaymentFrequency = insurance.paymentFrequency;
    _paymentDate = insurance.paymentDate;
    _closingDate = insurance.closingDate;
    _remarksController.text = insurance.remarks ?? '';

    if (_paymentDate != null) {
      _paymentDateController.text = DateFormat('dd/MM/yyyy').format(_paymentDate!);
    }
    if (_closingDate != null) {
      _closingDateController.text = DateFormat('dd/MM/yyyy').format(_closingDate!);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPaymentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentDate) {
          _paymentDate = picked;
          _paymentDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _closingDate = picked;
          _closingDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _showAddAccountDialog() {
    final TextEditingController newAccountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Insurance Account'),
          content: TextField(
            controller: newAccountController,
            decoration: const InputDecoration(
              hintText: 'Enter account name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newAccountController.text.isNotEmpty) {
                  setState(() {
                    _insuranceAccounts.add(newAccountController.text);
                    _accountNameController.text = newAccountController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveInsurance() async {
    if (_formKey.currentState!.validate()) {
      final insurance = Insurance(
        id: widget.insurance?.id,
        accountName: _accountNameController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        premiumAmount: double.tryParse(_premiumAmountController.text) ?? 0.0,
        insuranceType: _selectedInsuranceType ?? '',
        paymentFrequency: _selectedPaymentFrequency,
        paymentDate: _paymentDate,
        closingDate: _closingDate,
        remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      );

      try {
        if (widget.insurance == null) {
          await _databaseHelper.insertInsurance(insurance);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insurance saved successfully')),
          );
        } else {
          await _databaseHelper.updateInsurance(insurance);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insurance updated successfully')),
          );
        }
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving insurance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Insurance Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Account Name Row with Dropdown and Add Button
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        value: _accountNameController.text.isNotEmpty
                            ? _accountNameController.text
                            : null,
                        items: _insuranceAccounts,
                        hint: 'Select Account Name',
                        displayText: (item) => item,
                        onChanged: (value) {
                          setState(() {
                            _accountNameController.text = value ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: _showAddAccountDialog,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount Field
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomTextField(
                  controller: _amountController,
                  hintText: '0.0',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    return null;
                  }, suffixIcon: null,
                ),
              ),

              // Premium Amount Field
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomTextField(
                  controller: _premiumAmountController,
                  hintText: 'Premium Amount',
                  keyboardType: TextInputType.number,
                ),
              ),

              // Insurance Type Dropdown
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomDropdown<String>(
                  value: _selectedInsuranceType,
                  items: _insuranceTypes,
                  hint: 'Select Insurance Type',
                  displayText: (item) => item,
                  onChanged: (value) {
                    setState(() {
                      _selectedInsuranceType = value;
                    });
                  },
                ),
              ),

              // Payment Date Field
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomTextField(
                  controller: _paymentDateController,
                  hintText: 'Select Date Of Payment',
                  readOnly: true,
                  onTap: () => _selectDate(context, true),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),

              // Closing Date Field
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomTextField(
                  controller: _closingDateController,
                  hintText: 'Select Closing Date',
                  readOnly: true,
                  onTap: () => _selectDate(context, false),
                  suffixIcon: const Icon(Icons.event_available),
                ),
              ),

              // Remarks Field
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: CustomTextField(
                  controller: _remarksController,
                  hintText: 'Enter Remarks',
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveInsurance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _amountController.dispose();
    _premiumAmountController.dispose();
    _paymentDateController.dispose();
    _closingDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}