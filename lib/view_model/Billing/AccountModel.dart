class Account {
  final int? id;
  final int? voucherType;
  final String? entryId;
  final String? date;
  final String? setupId;
  final String? amount;
  final String? type;
  final String? remarks;
  final String? year;
  final String? month;
  final String? cashBankType;
  final String? billId;
  final String? billVoucherNumber;

  Account({
    this.id,
    this.voucherType,
    this.entryId,
    this.date,
    this.setupId,
    this.amount,
    this.type,
    this.remarks,
    this.year,
    this.month,
    this.cashBankType,
    this.billId,
    this.billVoucherNumber,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['ACCOUNTS_id'],
      voucherType: map['ACCOUNTS_VoucherType'],
      entryId: map['ACCOUNTS_entryid'],
      date: map['ACCOUNTS_date'],
      setupId: map['ACCOUNTS_setupid'],
      amount: map['ACCOUNTS_amount'],
      type: map['ACCOUNTS_type'],
      remarks: map['ACCOUNTS_remarks'],
      year: map['ACCOUNTS_year'],
      month: map['ACCOUNTS_month'],
      cashBankType: map['ACCOUNTS_cashbanktype'],
      billId: map['ACCOUNTS_billId'],
      billVoucherNumber: map['ACCOUNTS_billVoucherNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ACCOUNTS_id': id,
      'ACCOUNTS_VoucherType': voucherType,
      'ACCOUNTS_entryid': entryId,
      'ACCOUNTS_date': date,
      'ACCOUNTS_setupid': setupId,
      'ACCOUNTS_amount': amount,
      'ACCOUNTS_type': type,
      'ACCOUNTS_remarks': remarks,
      'ACCOUNTS_year': year,
      'ACCOUNTS_month': month,
      'ACCOUNTS_cashbanktype': cashBankType,
      'ACCOUNTS_billId': billId,
      'ACCOUNTS_billVoucherNumber': billVoucherNumber,
    };
  }
}