import 'package:flutter/material.dart';
import 'package:translator/translator.dart';


class HowtouseScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<HowtouseScreen> {
  final GoogleTranslator _translator = GoogleTranslator();
  String _selectedLanguage = 'en';
  String _translatedText = '';
  String _originalText = ''' 
   Account Setup

  To create an account head (ledger).

  1. Display all existing/default account heads in alphabetical order
  Use “Edit/Delete” for modification/deletion.
  3. Press + button to create a new ledger.
  4. Enter the account name.
  5. Select the category.
  6. Enter the opening balance if any.
  7. Select the balance type - debit or credit and save.

  Payment Voucher

  Payment is used to record expenses/payments

  1. The screen displays current month transactions.
  2. Use “Edit/Delete” for modification/deletion.
  3. Touch + button to enter new expenses/payment.
  4. Select date of payment.
  5. Select the payment account from the list or Press + to create a new account.
  6. Enter the amount paid.
  7. Select the mode of payment - Cash or Bank.
  8. If the payment mode is a bank, select the bank account or press + to create a new bank account.
  9. Enter remarks if any and save.

  Receipt Voucher

  Receipts is used to record receipts/incomes

  1. The screen displays current month transactions.
  2. Use “Edit/Delete” for modification/deletion.
  3. Touch + button to enter new receipt/income.
  4. Select the date of receipt.
  5. Select the receipt account from the list or press + to create a new account.
  6. Enter the amount received.
  7. Select the mode of receipt - Cash or Bank.
  8. If the receipt is through a bank, select the bank account or press + to create a new bank account.
  9. Enter remarks if any and save.

  Journal Voucher

  Journal is used for adjustment entries between two accounts.

  1. The screen displays current month transactions.
  2. Use “Edit/Delete” for modification/deletion.
  3. Touch + button to enter new transaction
  4. Select date of Journal.
  5. Select the debit account from the list or press + to create a new account.
  6. Enter the amount.
  7. Select the credit account from the list or press + to create a new account.
  8. Enter remarks if any and save.

  Bank Voucher

  To bank transactions like cash deposits and withdrawals.

  1. The screen displays current month transactions.
  2. Use “Edit/Delete” for modification/deletion.
  3. Touch + button to enter new transaction
  4. Select the date of deposit/withdrawal.
  5. Select the bank account or press + to create a new account.
  6. Enter the amount.
  7. Select type of transaction – deposit/withdrawal
  8. Enter remarks if any and save.

  Billing

  To issue a sales/service bill

  1. The screen displays current month transactions.
  2. Use “Edit/Delete” for modification/deletion.
  3. Use “Get Receipt” to receive the bill amount from the customer.
  4. Touch + button to enter a new transaction
  5. Select the date of the bill.
  6. Select the customer or press + to create a new customer.
  7. Enter the amount.
  8. Select the type of income account or press + to create a new income account.
  9. Enter remarks if any and save.

  Wallet

  This is a virtual wallet.

  1. Screen displays expenses of the current month and wallet balance.
  2. Touch + button to add money to the wallet.
  3. Select the date.
  4. Enter the amount and save.

  Cash/Bank statement

  1. Screen shows the current closing balance of cash and bank accounts.
  2. Select period to show the transactions
  3. Click “View” to display transactions for the selected period.

  Asset

  To list movable and immovable assets.

  1. The Screen displays already saved assets.
  2. Use “Edit or Delete” for modification.
  3. Press + button to create a new asset. “Example – Car”
  4. Category by default will be Asset account
  5. Enter the current value if any
  6. All assets will be in Debit as default
  7. Enter the save button to create an asset
  8. If required, enter the date of purchase
  9. Set reminds dates such as insurance renewal date, Tax payable date, etc.
  10. Select date and type description
  11. Press the reminder button again for another date if needed.
  12. The dates will set automatically in reminder and will display in Daily Task.

  Liability

  To list loans and liabilities

  1. The screen displays already saved loans and liabilities.
  2. Use “Edit or Delete” for modification.
  3. Press + button to create a new liability. “Example – Housing loan”
  4. Category by default will be a Liability account
  5. Enter the current balance
  6. All liabilities will be in Credit as default.
  7. Enter the save button to create a liability.
  8. Select repayment type - EMI/Non-EMI.
  9. Enter EMI amount
  10. Enter the number of EMI that remains
  11. Select the payment date of EMI.
  12. System will display the closing date.
  13. The payment dates will set automatically in reminder and will display in Daily Task.

  Insurance

  Used to record information about the insurance policies.

  1. The screen displays already saved insurance.
  2. Use “Edit or Delete” for modification.
  3. Press + button to create new insurance. “Example – Life insurance”
  4. Category by default will be insurance
  5. Enter the paid-up value.
  6. All insurance will be in Debit as default.
  7. Enter the save button to create an insurance.
  8. Enter the premium amount
  9. Select the premium payment frequency.
  10. Closing date and remarks if any.
  11. The premium dates will set automatically in reminder and will display in Daily Task.

  Investments

  Used to record information about the investments.

  1. The screen displays already saved investments.
  2. Use “Edit or Delete” for modification.
  3. Press + button to create new investment. “Example – Recurring deposit scheme”
  4. Category by default will be an investment.
  5. Enter the current deposit value.
  6. All insurance will be in Debit as default.
  7. Select payment frequency
  8. Enter installment amount
  9. Enter the number of installments that remains
  10. Enter the date of payment and remarks if any.
  11. System will display the closing date.
  12. The payment dates will set automatically in reminder and will display in Daily Task.

  My Diary

  Used to record thoughts, experience, passion and hobbies.

  1. The screen displays already saved notes
  2. Press the arrow button to download PDF formats of selected subjects for the selected period.
  3. Press + button to create a new note.
  4. Select language
  5. Select date
  6. Press + button to create new subject
  7. Start typing or record your thoughts and experience.
  8. Press the save button to save data

  Budget

  Budget is used to set a budget and budgetary provision.

  1. Select the year of budget
  2. Select the expense heads from the list.
  3. Enter the monthly amount.
  4. System will automatically allocate the entered amount to all months when submitting.
  5. Edit monthly figure as per requirement.
  6. When entering expenses through payment voucher, the user gets a warning message if the budgetary provision exceeds for the selected head.

  Reports

  1. Transactions
  This report shows all the transactions in the given period in a double entry manner.

  2. Ledger
  All existing ledgers are displayed on the first page along with their closing balance. Touching the view button, it shows date-wise entries for the given period. You can also download this report in pdf format by touching the down arrow.

  3. Cash and Bank Balances
  This is a report similar to the Ledger report. Only accounts in the Cash or Bank Account categories are shown here. It can also be downloaded in pdf.

  4. Income and Expenditure Statement.
  This report shows the excess or deficit of income over expenses for a particular period.
  Touch Search after entering the date period, it will display the summary of Total Income and Total Expenses.
  The details can be seen by touching the down arrow to the right of each of them.

  5. Reminders
  Display all reminders that are generated from Task, Asset, Liability, Investment and insurance.
  There is an option to search for reminders for a particular date.

  6. List of My Assets
  It lists all the assets recorded in the Asset module. Touch the view to see the closing balance and transaction details recorded in each.

  7. List of My Liabilities
  It lists all the liabilities recorded in the Liability module. Touch the view to see the closing balance and transaction details recorded in each.

  8. List of My Insurances
  It lists all the insurances recorded in the Insurance module. Touch the view to see the closing balance and transaction details recorded in each.

  9. List of My Investments
  It lists all the Investments recorded in the Investment module. Touch the view to see the closing balance and transaction details recorded in each.

  ''';


  final Map<String, String> _languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Malayalam': 'ml',
    'Kannada': 'kn',
    'Telugu': 'te',
    'Tamil': 'ta',
  };

  Future<void> _translateTo(String langCode) async {
    final translated = await _translator.translate(_originalText, to: langCode);
    setState(() {
      _translatedText = translated.text;
      _selectedLanguage = langCode;
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _languageCodes.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () async {
                    Navigator.pop(context); // Close dialog
                    await _translateTo(entry.value); // Auto-translate
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _translatedText = _originalText; // Show English text on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'How To Use',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            tooltip: 'Select Language',
            onPressed: _showLanguageDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _translatedText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}