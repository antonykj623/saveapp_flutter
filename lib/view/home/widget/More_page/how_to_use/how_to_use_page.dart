import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class HowtouseScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<HowtouseScreen>
    with TickerProviderStateMixin {
  final GoogleTranslator _translator = GoogleTranslator();
  String _selectedLanguage = 'en';
  String _translatedText = '';
  bool _isTranslating = false;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  String _originalText = ''' 
   Account Setup

  To create an account head (ledger).

  1. Display all existing/default account heads in alphabetical order
  Use "Edit/Delete" for modification/deletion.
  3. Press + button to create a new ledger.
  4. Enter the account name.
  5. Select the category.
  6. Enter the opening balance if any.
  7. Select the balance type - debit or credit and save.

  Payment Voucher

  Payment is used to record expenses/payments

  1. The screen displays current month transactions.
  2. Use "Edit/Delete" for modification/deletion.
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
  2. Use "Edit/Delete" for modification/deletion.
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
  2. Use "Edit/Delete" for modification/deletion.
  3. Touch + button to enter new transaction
  4. Select date of Journal.
  5. Select the debit account from the list or press + to create a new account.
  6. Enter the amount.
  7. Select the credit account from the list or press + to create a new account.
  8. Enter remarks if any and save.

  Bank Voucher

  To bank transactions like cash deposits and withdrawals.

  1. The screen displays current month transactions.
  2. Use "Edit/Delete" for modification/deletion.
  3. Touch + button to enter new transaction
  4. Select the date of deposit/withdrawal.
  5. Select the bank account or press + to create a new account.
  6. Enter the amount.
  7. Select type of transaction – deposit/withdrawal
  8. Enter remarks if any and save.

  Billing

  To issue a sales/service bill

  1. The screen displays current month transactions.
  2. Use "Edit/Delete" for modification/deletion.
  3. Use "Get Receipt" to receive the bill amount from the customer.
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
  3. Click "View" to display transactions for the selected period.

  Asset

  To list movable and immovable assets.

  1. The Screen displays already saved assets.
  2. Use "Edit or Delete" for modification.
  3. Press + button to create a new asset. "Example – Car"
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
  2. Use "Edit or Delete" for modification.
  3. Press + button to create a new liability. "Example – Housing loan"
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
  2. Use "Edit or Delete" for modification.
  3. Press + button to create new insurance. "Example – Life insurance"
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
  2. Use "Edit or Delete" for modification.
  3. Press + button to create new investment. "Example – Recurring deposit scheme"
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

  @override
  void initState() {
    super.initState();
    _translatedText = _originalText;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _translateTo(String langCode) async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await _translator.translate(
        _originalText,
        to: langCode,
      );
      setState(() {
        _translatedText = translated.text;
        _selectedLanguage = langCode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Translation failed. Please try again.')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade50,
                  Colors.blue.shade50,
                  Colors.pink.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Language',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Choose your preferred language',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 420),
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        _languageCodes.entries.map((entry) {
                          bool isSelected = _selectedLanguage == entry.value;
                          return TweenAnimationBuilder(
                            duration: Duration(milliseconds: 300),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: 0.9 + (value * 0.1),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? LinearGradient(
                                          colors: [
                                            Color(0xFF667eea).withOpacity(0.15),
                                            Color(0xFF764ba2).withOpacity(0.15),
                                          ],
                                        )
                                        : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Color(0xFF667eea)
                                          : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        isSelected
                                            ? Color(0xFF667eea).withOpacity(0.3)
                                            : Colors.black.withOpacity(0.03),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: Offset(0, isSelected ? 6 : 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient:
                                        isSelected
                                            ? LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            )
                                            : null,
                                    color:
                                        isSelected
                                            ? null
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.translate_rounded,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                    fontSize: 16,
                                    color:
                                        isSelected
                                            ? Color(0xFF667eea)
                                            : Colors.grey.shade800,
                                  ),
                                ),
                                trailing:
                                    isSelected
                                        ? Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        )
                                        : Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey.shade400,
                                          size: 16,
                                        ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _translateTo(entry.value);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
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
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Gorgeous App Bar
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How To Use',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Your Complete Guide',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.language_rounded,
                            color: Color(0xFF667eea),
                          ),
                          tooltip: 'Select Language',
                          onPressed: _showLanguageDialog,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Beautiful Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child:
                        _isTranslating
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF667eea).withOpacity(0.1),
                                          Color(0xFF764ba2).withOpacity(0.1),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF667eea),
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Translating...',
                                    style: TextStyle(
                                      color: Color(0xFF667eea),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Please wait a moment',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(24, 32, 24, 40),
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _translatedText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.8,
                                        color: Colors.grey.shade800,
                                        letterSpacing: 0.3,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
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
