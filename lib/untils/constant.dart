import 'dart:ui';

class AppConstants {
  static const String appName = 'Investment Tracker';
  static const String databaseName = 'investments.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String investmentsTable = 'investments';
  static const String reminderDatesTable = 'reminder_dates';
  
  // Colors
  static const Color primaryColor = Color(0xFF2E7D7A);
  static const Color accentColor = Color(0xFFE91E63);
  static const Color backgroundColor = Color(0xFFF5F5F5);
}
