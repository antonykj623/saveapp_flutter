import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final double charges;
  final bool isRecommended;

  PaymentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.charges,
    this.isRecommended = false,
  });
}

// PaymentTypeDialog class to display payment options
class PaymentTypeDialog extends StatefulWidget {
  final double amount;
  final Function(String paymentType, double totalAmount) onPaymentSelected;

  const PaymentTypeDialog({
    Key? key,
    required this.amount,
    required this.onPaymentSelected,
  }) : super(key: key);

  @override
  _PaymentTypeDialogState createState() => _PaymentTypeDialogState();
}

class _PaymentTypeDialogState extends State<PaymentTypeDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? selectedPaymentType;
  final List<PaymentOption> paymentOptions = [
    PaymentOption(
      id: 'upi',
      title: 'UPI',
      subtitle: '(no convenience charges)',
      icon: Icons.account_balance_wallet,
      gradient: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      charges: 0.0,
      isRecommended: true,
    ),
    PaymentOption(
      id: 'net_banking',
      title: 'NET Banking',
      subtitle: '(payment gateway charge @1.5% applicable)',
      icon: Icons.account_balance,
      gradient: [Color(0xFF2196F3), Color(0xFF0D47A1)],
      charges: 1.5,
    ),
    PaymentOption(
      id: 'debit_card',
      title: 'Debit Card',
      subtitle: '(payment gateway charge @0.4% applicable)',
      icon: Icons.credit_card,
      gradient: [Color(0xFF9C27B0), Color(0xFF4A148C)],
      charges: 0.4,
    ),
    PaymentOption(
      id: 'credit_card',
      title: 'Credit Card',
      subtitle: '(payment gateway charge @2.1% applicable)',
      icon: Icons.credit_card_outlined,
      gradient: [Color(0xFFFF5722), Color(0xFFBF360C)],
      charges: 2.1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateTotalAmount(double charges) {
    if (charges == 0) return widget.amount;
    return widget.amount + (widget.amount * charges / 100);
  }

  void _selectPaymentType(PaymentOption option) {
    setState(() {
      selectedPaymentType = option.id;
    });
    HapticFeedback.mediumImpact();
    // Action triggered when user taps a payment option
    print(
      '🔔 User selected payment option: ${option.title} (ID: ${option.id}, Charges: ${option.charges}%)',
    );
  }

  void _proceedWithPayment() {
    if (selectedPaymentType != null) {
      final selectedOption = paymentOptions.firstWhere(
        (option) => option.id == selectedPaymentType,
      );
      final totalAmount = _calculateTotalAmount(selectedOption.charges);
      widget.onPaymentSelected(selectedOption.id, totalAmount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dialogHeight = screenHeight * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            constraints: BoxConstraints(maxHeight: dialogHeight),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFAFBFC), Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32, 32, 32, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Payment Type',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount to Pay',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${widget.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.payments,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Choose your preferred payment method',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ...paymentOptions.asMap().entries.map((entry) {
                          int index = entry.key;
                          PaymentOption option = entry.value;
                          bool isSelected = selectedPaymentType == option.id;

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () => _selectPaymentType(option),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected
                                          ? LinearGradient(
                                            colors: [
                                              option.gradient[0].withOpacity(
                                                0.1,
                                              ),
                                              option.gradient[1].withOpacity(
                                                0.05,
                                              ),
                                            ],
                                          )
                                          : LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Color(0xFFFAFBFC),
                                            ],
                                          ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? option.gradient[0]
                                            : Color(0xFFE2E8F0),
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isSelected
                                              ? option.gradient[0].withOpacity(
                                                0.25,
                                              )
                                              : Colors.black.withOpacity(0.05),
                                      blurRadius: isSelected ? 20 : 10,
                                      offset: Offset(0, isSelected ? 8 : 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    if (option.isRecommended)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.orange,
                                                Colors.deepOrange,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'RECOMMENDED',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: option.gradient,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: option.gradient[0]
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              option.icon,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option.title,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1A202C),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  option.subtitle,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF718096),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(height: 8),
                                                Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Total: ',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xFF4A5568,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_calculateTotalAmount(option.charges).toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            option.gradient[0],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (option.charges > 0) ...[
                                                      SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '+${option.charges}%',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  isSelected
                                                      ? LinearGradient(
                                                        colors: option.gradient,
                                                      )
                                                      : LinearGradient(
                                                        colors: [
                                                          Color(0xFFF8F9FA),
                                                          Color(0xFFE2E8F0),
                                                        ],
                                                      ),
                                              shape: BoxShape.circle,
                                              boxShadow:
                                                  isSelected
                                                      ? [
                                                        BoxShadow(
                                                          color: option
                                                              .gradient[0]
                                                              .withOpacity(0.4),
                                                          blurRadius: 12,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ]
                                                      : [],
                                            ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Color(0xFF718096),
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 24),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  selectedPaymentType != null
                                      ? [Color(0xFF10B981), Color(0xFF059669)]
                                      : [Color(0xFFB0BEC5), Color(0xFF78909C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    selectedPaymentType != null
                                        ? Color(0xFF10B981).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                selectedPaymentType != null
                                    ? _proceedWithPayment
                                    : null,
                            child: Text(
                              'Proceed to Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'All transactions are secure and encrypted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
