class ReminderDate {
  final int investmentId;
  final DateTime date;
  final String description;

  ReminderDate({
    required this.investmentId,
    required this.date,
    required this.description,
  });
}

class InvestmentAsset1 {
  final int id;
  final String accountName;
  final double amount;
  final DateTime? dateOfPurchase;
  final String? remarks;
  final List<ReminderDate> reminderDates;

  InvestmentAsset1({
    required this.id,
    required this.accountName,
    required this.amount,
    this.dateOfPurchase,
    this.remarks,
    this.reminderDates = const [],
  });
}