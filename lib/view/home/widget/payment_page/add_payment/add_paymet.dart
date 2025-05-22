import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/databasehelper/data_base_helper.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';



class AddPaymentVoucherPage extends StatefulWidget {
  final Payment? payment;

  const AddPaymentVoucherPage({super.key, this.payment});

  @override
  State<AddPaymentVoucherPage> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddPaymentVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();

  final List<String> accounts = [
    'Agriculture Expenses',
    'Agriculture Income',
    'Household Expenses',
    'Salary Income',
    'Miscellaneous',
  ];

  final List<String> cashOptions = [
    'Cash',
    'Bank - HDFC',
    'Bank - SBI',
    'Bank - ICICI',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.payment!.date);
      selectedAccount = widget.payment!.accountName;
      _amountController.text = widget.payment!.amount.toString();
      paymentMode = widget.payment!.paymentMode;
      selectedCashOption = widget.payment!.paymentMode == 'Bank' ? cashOptions[1] : cashOptions[0];
      _remarksController.text = widget.payment!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
      selectedCashOption = cashOptions[0];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: widget.payment?.id,
        date: DateFormat('yyyy-MM-dd').format(selectedDate),
        accountName: selectedAccount!,
        amount: double.parse(_amountController.text),
        paymentMode: paymentMode,
        remarks: _remarksController.text,
      );

      if (widget.payment == null) {
        await DatabaseHelper.instance.insertPayment(payment);
      } else {
        await DatabaseHelper.instance.updatePayment(payment);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Voucher'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select An Account'),
                          value: selectedAccount,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an account';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAccount = newValue;
                            });
                          },
                          items: accounts.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature to add new account')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Amount',
                        ),
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
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget setting feature')),
                      );
                    },
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Radio<String>(
                    value: 'Bank',
                    groupValue: paymentMode,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = cashOptions[1];
                      });
                    },
                  ),
                  const Text('Bank'),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: 'Cash',
                    groupValue: paymentMode,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = cashOptions[0];
                      });
                    },
                  ),
                  const Text('Cash'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: selectedCashOption,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCashOption = newValue;
                              if (newValue == 'Cash') {
                                paymentMode = 'Cash';
                              } else {
                                paymentMode = 'Bank';
                              }
                            });
                          },
                          items: paymentMode == 'Cash'
                              ? [cashOptions[0]].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()
                              : cashOptions
                                  .sublist(1)
                                  .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature to add new bank account'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Remarks',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _savePayment,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
}