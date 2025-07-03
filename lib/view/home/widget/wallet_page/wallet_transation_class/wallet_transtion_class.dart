class WalletTransaction {
  final int? id;
  final String date;
  final double amount;
  final String description;
  final String type;
  final String? paymentMethod;
  final String? paymentEntryId;

  WalletTransaction({
    this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
    this.paymentMethod,
    this.paymentEntryId,
  });
}