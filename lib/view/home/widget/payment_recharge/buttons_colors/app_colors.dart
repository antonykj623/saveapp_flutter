import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF4285F4);
  static const primaryBlueDark = Color(0xFF1a73e8);
  static const successGreen = Color(0xFF10B981);
  static const successGreenDark = Color(0xFF059669);
  static const backgroundLight = Color(0xFFF8F9FA);
  static const backgroundLighter = Color(0xFFFAFBFC);
  static const textPrimary = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF4A5568);
  static const textHint = Color(0xFF718096);
  static const borderLight = Color(0xFFE2E8F0);
  static const orange = Colors.orange;
  static const deepOrange = Colors.deepOrange;
  static const red = Colors.red;
  static const white = Colors.white;
  static const grey = Colors.grey;

  static const gradientPrimary = [
    primaryBlue,
    primaryBlueDark,
  ];
  static const gradientSuccess = [
    successGreen,
    successGreenDark,
  ];
  static const gradientBackground = [
    backgroundLight,
    backgroundLighter,
  ];
  static const gradientOrange = [
    orange,
    deepOrange,
  ];
  static const gradientPaymentHeader = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
}

class AppShadows {
  static final defaultShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
  static final elevatedShadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 30,
    offset: Offset(0, 10),
  );
  static final paymentShadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 40,
    offset: Offset(0, 20),
  );
}