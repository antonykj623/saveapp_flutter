class WalletTransaction {
  final int? id;
  final String date;
  final double amount;
  final String description;
  final String type; // 'credit' or 'debit'

  WalletTransaction({
    this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'description': description,
      'type': type,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id']?.toInt(),
      date: map['date'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      type: map['type'] ?? 'credit',
    );
  }

  WalletTransaction copyWith({
    int? id,
    String? date,
    double? amount,
    String? description,
    String? type,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
}