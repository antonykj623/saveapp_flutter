class InvestmentAsset {
  int? id;
  String accountName;
  double amount;
  DateTime? dateOfPurchase;
  List<ReminderDate> reminderDates;
  String? remarks;
  String? documentPath;

  InvestmentAsset({
    this.id,
    required this.accountName,
    required this.amount,
    this.dateOfPurchase,
    this.reminderDates = const [],
    this.remarks,
    this.documentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountName': accountName,
      'amount': amount,
      'dateOfPurchase': dateOfPurchase?.millisecondsSinceEpoch,
      'remarks': remarks,
      'documentPath': documentPath,
    };
  }

  factory InvestmentAsset.fromMap(Map<String, dynamic> map) {
    return InvestmentAsset(
      id: map['id'],
      accountName: map['accountName'],
      amount: map['amount'],
      dateOfPurchase: map['dateOfPurchase'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfPurchase'])
          : null,
      remarks: map['remarks'],
      documentPath: map['documentPath'],
    );
  }
}

class ReminderDate {
  int? id;
  int investmentId;
  DateTime date;
  String description;

  ReminderDate({
    this.id,
    required this.investmentId,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'investmentId': investmentId,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory ReminderDate.fromMap(Map<String, dynamic> map) {
    return ReminderDate(
      id: map['id'],
      investmentId: map['investmentId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
    );
  }
}