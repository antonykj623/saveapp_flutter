class JournalEntry {
  final int entryId;
  final String date;
  final String debitAccount;
  final String creditAccount;
  final double amount;
  final String? remarks;

  JournalEntry({
    required this.entryId,
    required this.date,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    this.remarks,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      entryId: map['entryId'] ?? 0,
      date: map['date'] ?? '',
      debitAccount: map['debitAccount'] ?? '',
      creditAccount: map['creditAccount'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      remarks: map['remarks'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'date': date,
      'debitAccount': debitAccount,
      'creditAccount': creditAccount,
      'amount': amount,
      'remarks': remarks,
    };
  }

  JournalEntry copyWith({
    int? entryId,
    String? date,
    String? debitAccount,
    String? creditAccount,
    double? amount,
    String? remarks,
  }) {
    return JournalEntry(
      entryId: entryId ?? this.entryId,
      date: date ?? this.date,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  String toString() {
    return 'JournalEntry(entryId: $entryId, date: $date, debitAccount: $debitAccount, creditAccount: $creditAccount, amount: $amount, remarks: $remarks)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry && other.entryId == entryId;
  }

  @override
  int get hashCode {
    return entryId.hashCode;
  }
}