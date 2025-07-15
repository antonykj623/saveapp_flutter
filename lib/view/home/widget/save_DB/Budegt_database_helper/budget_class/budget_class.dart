class BudgetClass {
  final int? id;
  final String accountName;
  final int year;
  final String month;
  final double amount;

  BudgetClass({
    this.id,
    required this.accountName,
    required this.year,
    required this.month,
    required this.amount,
  });

  factory BudgetClass.fromMap(Map<String, dynamic> map) {
    return BudgetClass(
      id: map['keyid'],
      accountName: map['account_name'],
      year: map['year'],
      month: map['month'],
      amount: map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyid': id,
      'account_name': accountName,
      'year': year,
      'month': month,
      'amount': amount,
    };
  }
}