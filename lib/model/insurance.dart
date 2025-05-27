
class Insurance {
  int? id;
  String accountName;
  double amount;
  double premiumAmount;
  String insuranceType;
  String paymentFrequency;
  DateTime? paymentDate;
  DateTime? closingDate;
  String? remarks;
  DateTime createdAt;
  DateTime updatedAt;

  Insurance({
    this.id,
    required this.accountName,
    this.amount = 0.0,
    this.premiumAmount = 0.0,
    this.insuranceType = '',
    this.paymentFrequency = 'Monthly',
    this.paymentDate,
    this.closingDate,
    this.remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_name': accountName,
      'amount': amount,
      'premium_amount': premiumAmount,
      'insurance_type': insuranceType,
      'payment_frequency': paymentFrequency,
      'payment_date': paymentDate?.millisecondsSinceEpoch,
      'closing_date': closingDate?.millisecondsSinceEpoch,
      'remarks': remarks,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Insurance.fromMap(Map<String, dynamic> map) {
    return Insurance(
      id: map['id'],
      accountName: map['account_name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      premiumAmount: (map['premium_amount'] ?? 0.0).toDouble(),
      insuranceType: map['insurance_type'] ?? '',
      paymentFrequency: map['payment_frequency'] ?? 'Monthly',
      paymentDate: map['payment_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['payment_date'])
          : null,
      closingDate: map['closing_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['closing_date'])
          : null,
      remarks: map['remarks'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Insurance copyWith({
    int? id,
    String? accountName,
    double? amount,
    double? premiumAmount,
    String? insuranceType,
    String? paymentFrequency,
    DateTime? paymentDate,
    DateTime? closingDate,
    String? remarks,
  }) {
    return Insurance(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      premiumAmount: premiumAmount ?? this.premiumAmount,
      insuranceType: insuranceType ?? this.insuranceType,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      paymentDate: paymentDate ?? this.paymentDate,
      closingDate: closingDate ?? this.closingDate,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
