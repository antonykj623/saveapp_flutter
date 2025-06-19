import 'dart:convert';
import 'package:intl/intl.dart';

class Payment {
  final int? id;
  final String date;
  final String accountName;
  final double amount;
  final String paymentMode;
  // final String billID;
  final String? remarks;

  Payment({
    this.id,
    required this.date,
    required this.accountName,
    required this.amount,
    required this.paymentMode,
    // required this.billID,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'accountName': accountName,
      'amount': amount,
      'paymentMode': paymentMode,
      'remarks': remarks,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toInt(),
      date: map['date'] ?? '',
      accountName: map['accountName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMode: map['paymentMode'] ?? '',
      remarks: map['remarks'],
    );
  }

  Payment copyWith({
    int? id,
    String? date,
    String? accountName,
    double? amount,
    String? paymentMode,
    String? remarks,
  }) {
    return Payment(
      id: id ?? this.id,
      date: date ?? this.date,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
    );
  }

  // Convert to JSON string - Fixed formatting
  String toJson() {
    return jsonEncode({
      "id": id,
      "date": date,
      "accountName": accountName,
      "amount": amount,
      "paymentMode": paymentMode,
      "remarks": remarks ?? '',
    });
  }

  // Create Payment from JSON string
  factory Payment.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Payment.fromMap(json);
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Payment(id: $id, date: $date, accountName: $accountName, amount: $amount, paymentMode: $paymentMode, remarks: $remarks)';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.id == id &&
        other.date == date &&
        other.accountName == accountName &&
        other.amount == amount &&
        other.paymentMode == paymentMode &&
        other.remarks == remarks;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        accountName.hashCode ^
        amount.hashCode ^
        paymentMode.hashCode ^
        remarks.hashCode;
  }

  // Validation method
  bool isValid() {
    return date.isNotEmpty &&
        accountName.isNotEmpty &&
        amount > 0 &&
        paymentMode.isNotEmpty;
  }

  // Get formatted amount as string
  String get formattedAmount => amount.toStringAsFixed(2);

  // Get formatted date
  String get formattedDate {
    try {
      final DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Check if payment is cash or bank
  bool get isCashPayment => paymentMode.toLowerCase() == 'cash';
  bool get isBankPayment => paymentMode.toLowerCase() != 'cash';
}
