class Payment {
  final int? id;
  final String date;
  final String accountName;
  final double amount;
  final String paymentMode;
  final String? remarks;

  Payment({
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

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      date: map['date'],
      accountName: map['accountName'],
      amount: map['amount'],
      paymentMode: map['paymentMode'],
      remarks: map['remarks'],
    );
  }
}
