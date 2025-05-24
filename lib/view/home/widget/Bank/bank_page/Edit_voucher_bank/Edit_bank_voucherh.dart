import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/data_base_helper/data_base_helper_bank.dart';

class AddEditVoucherScreen extends StatefulWidget {
  final BankVoucher? voucher;

  AddEditVoucherScreen({this.voucher});

  @override
  _AddEditVoucherScreenState createState() => _AddEditVoucherScreenState();
}

class _AddEditVoucherScreenState extends State<AddEditVoucherScreen> {
  final BankDatabase _bankDatabase = BankDatabase();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  
  String _selectedDebit = 'Hdfc';
  String _selectedTransactionType = 'Deposit';
  String _selectedCredit = 'Cash';

  final List<String> _debitOptions = ['Hdfc', 'SBI', 'ICICI', 'Axis'];
  final List<String> _transactionTypes = ['Deposit', 'Withdrawal'];
  final List<String> _creditOptions = ['Cash', 'Cheque', 'Online'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.voucher?.date ?? DateFormat('dd-MM-yyyy').format(DateTime.now())
    );
    _amountController = TextEditingController(
      text: widget.voucher?.amount.toString() ?? ''
    );
    _remarksController = TextEditingController(
      text: widget.voucher?.remarks ?? ''
    );
    
    if (widget.voucher != null) {
      _selectedDebit = widget.voucher!.debit;
      _selectedCredit = widget.voucher!.credit;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.voucher != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit bank voucher' : 'Bank'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(),
                ),
              ),
                            Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDebit,
                          isExpanded: true,
                          items: _debitOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDebit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {},
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Transaction Type Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTransactionType,
                    isExpanded: true,
                    items: _transactionTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTransactionType = newValue!;
                      });
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCredit,
                          isExpanded: true,
                          items: _creditOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCredit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {},
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Remarks Field
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Enter Remarks',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              
              Spacer(),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text('Save'),
                    ),
                  ),
                  if (isEdit) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _saveVoucher() async {
    if (_formKey.currentState!.validate()) {
      final voucher = BankVoucher(
        id: widget.voucher?.id,
        date: DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_dateController.text)),
        debit: _selectedDebit,
        amount: double.parse(_amountController.text),
        credit: _selectedCredit,
        remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      );

      if (widget.voucher == null) {
        await _bankDatabase.insertVoucher(voucher);
      } else {
        await _bankDatabase.updateVoucher(voucher);
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteVoucher() async {
    if (widget.voucher != null) {
      await _bankDatabase.deleteVoucher(widget.voucher!.id!);
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}