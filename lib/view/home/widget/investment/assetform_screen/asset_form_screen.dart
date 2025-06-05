import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/investment/documentUpload_screen/Doument_uplaod.screen.dart';
import 'package:new_project_2025/view/home/widget/investment/model_class1/model_class.dart';

class AssetFormScreen extends StatefulWidget {
  final InvestmentAsset? investment;

  const AssetFormScreen({Key? key, this.investment}) : super(key: key);

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  DateTime? _selectedDate;
  List<ReminderDate> _reminderDates = [];

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: widget.investment?.accountName ?? 'Estate');
    _amountController = TextEditingController(text: widget.investment?.amount.toString() ?? '0');
    _remarksController = TextEditingController(text: widget.investment?.remarks ?? '');
    _selectedDate = widget.investment?.dateOfPurchase ?? DateTime.now();
    _reminderDates = List.from(widget.investment?.reminderDates ?? []);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the default dropdown items
    final List<String> defaultAccountTypes = [
      'Estate',
      'Stocks',
      'Bonds',
      'Real Estate',
      'Other',
    ];

    // Include the investment's accountName in the dropdown items if it's not already present
    final String currentAccountName = _accountNameController.text;
    final List<String> accountTypes = defaultAccountTypes.contains(currentAccountName)
        ? defaultAccountTypes
        : [...defaultAccountTypes, currentAccountName];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D7A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Account Name Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: accountTypes.contains(currentAccountName) ? currentAccountName : 'Estate',
                      isExpanded: true,
                      items: accountTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _accountNameController.text = newValue ?? 'Estate';
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Field
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    textAlign: TextAlign.right,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Date of Purchase
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select Date of Purchase',
                          style: TextStyle(
                            color: _selectedDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Set Remind Dates Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showReminderDateDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Set Remind Dates',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Reminder Dates
                if (_reminderDates.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reminder Dates:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._reminderDates.map(
<<<<<<< HEAD
                              (reminder) => Padding(
=======
                          (reminder) => Padding(
>>>>>>> 4325c58292a5ddccff71198dcfe3a5bb575267e6
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('yyyy-MM-dd').format(reminder.date)),
                                Text(reminder.description),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _reminderDates.remove(reminder);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload Documents Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const DocumentUploadScreen(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text(
                      'Upload Documents',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Remarks Field
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextFormField(
                      controller: _remarksController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Remarks',
                      ),
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _saveInvestment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D7A),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReminderDateDialog() {
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Reminder Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (dateController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  setState(() {
                    _reminderDates.add(
                      ReminderDate(
                        investmentId: widget.investment?.id ?? 0,
                        date: DateFormat('yyyy-MM-dd').parse(dateController.text),
                        description: descriptionController.text,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveInvestment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date of purchase')),
        );
        return;
      }

      final updatedInvestment = InvestmentAsset(
        id: widget.investment?.id ?? 0,
        accountName: _accountNameController.text,
        amount: double.parse(_amountController.text),
        dateOfPurchase: _selectedDate,
        remarks: _remarksController.text,
        reminderDates: _reminderDates,
      );

      print('Saving investment: $updatedInvestment');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Investment saved successfully')),
      );

      Navigator.pop(context, updatedInvestment);
    }
  }
}