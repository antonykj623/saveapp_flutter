// Add this Receipt class if it doesn't exist or fix the existing one
class Receipt {
  final int? id;
  final String date;
  final String accountName;
  final double amount;
  final String paymentMode;
  final String? remarks;

  Receipt({
    this.id,
    required this.date,
    required this.accountName,
    required this.amount,
    required this.paymentMode,
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

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id']?.toInt(),
      date: map['date'] ?? '',
      accountName: map['accountName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      paymentMode: map['paymentMode'] ?? '',
      remarks: map['remarks'],
    );
  }
}