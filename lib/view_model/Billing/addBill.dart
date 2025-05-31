import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/databasehelper/data_base_helper.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';

class AddBill extends StatefulWidget {
  final Payment? payment;

  const AddBill({super.key, this.payment});

  @override
  State<AddBill> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddBill> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  var dropdownvalu1 = 'Asset Account';
  var items1 = [
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
      selectedCashOption =
      widget.payment!.paymentMode == 'Bank'
          ? cashOptions[1]
          : cashOptions[0];
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
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Add Bill', style: TextStyle(color: Colors.white)),
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
                          hint: const Text('hiii'),
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
                          items:
                          accounts.map<DropdownMenuItem<String>>((
                              String value,
                              ) {
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

                  Container(


                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        tooltip: 'Increment',
                        shape:   const CircleBorder(),
                        onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder:(context)=>AddBill( )));


                        },
                        child: const Icon(Icons.add, color: Colors.white, size: 25),
                      ),


                  ),
                ],
              ),



              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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


                ],
              ),


              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),

                      child: DropdownButton(
                        isExpanded: true,
                        // Initial Value
                        value: dropdownvalu1,

                        // Down Arrow Icon
                        icon: const Icon(Icons.keyboard_arrow_down),

                        // Array list of items
                        items: items1.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (String? newValue2) {
                          setState(() {
                            dropdownvalu1 = newValue2!;
                            print("Value is..:$dropdownvalu1");
                          });
                        },
                      ),
                    ),
                  ),

                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                     child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      tooltip: 'Increment',
                      shape:   const CircleBorder(),
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder:(context)=>AddBill( )));


                      },
                      child: const Icon(Icons.add, color: Colors.white, size: 25),
                                     ),
                   ),
                 ),
],),



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
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
