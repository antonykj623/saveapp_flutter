class SalesData {
  final String id;
  final String billnoPrefix;
  final String billNo;
  final String displayBillNo;
  final String regId;
  final String regCode;
  final String productId;
  final String salesType;
  final DateTime salesDate;
  final String expeDate;
  final String amt;
  final String cgst;
  final String sgst;
  final String igst;
  final String binaryVal;
  final String currency;
  final String exRate;
  final String rupeeConvertionVal;
  final String sponserRegId;
  final String sponserRegCode;
  final String referalCommissionRupee;
  final String sponserCurrency;
  final String sponserCurExRate;
  final String sponserConversionValue;
  final String binaryGenStatus;
  final String cashTransactionId;
  final String smode;
  final String? orderId;
  final String? trackingId;
  final String? bankRefNo;

  SalesData({
    required this.id,
    required this.billnoPrefix,
    required this.billNo,
    required this.displayBillNo,
    required this.regId,
    required this.regCode,
    required this.productId,
    required this.salesType,
    required this.salesDate,
    required this.expeDate,
    required this.amt,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.binaryVal,
    required this.currency,
    required this.exRate,
    required this.rupeeConvertionVal,
    required this.sponserRegId,
    required this.sponserRegCode,
    required this.referalCommissionRupee,
    required this.sponserCurrency,
    required this.sponserCurExRate,
    required this.sponserConversionValue,
    required this.binaryGenStatus,
    required this.cashTransactionId,
    required this.smode,
    this.orderId,
    this.trackingId,
    this.bankRefNo,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      id: json['id'] as String,
      billnoPrefix: json['billno_prefix'] as String,
      billNo: json['bill_no'] as String,
      displayBillNo: json['display_bill_no'] as String,
      regId: json['reg_id'] as String,
      regCode: json['reg_code'] as String,
      productId: json['product_id'] as String,
      salesType: json['sales_type'] as String,
      salesDate: DateTime.parse(json['sales_date'] as String),
      expeDate: json['expe_date'] as String,
      amt: json['amt'] as String,
      cgst: json['cgst'] as String,
      sgst: json['sgst'] as String,
      igst: json['igst'] as String,
      binaryVal: json['binary_val'] as String,
      currency: json['currency'] as String,
      exRate: json['ex_rate'] as String,
      rupeeConvertionVal: json['rupee_convertion_val'] as String,
      sponserRegId: json['sponser_reg_id'] as String,
      sponserRegCode: json['sponser_reg_code'] as String,
      referalCommissionRupee: json['referal_commission_rupee'] as String,
      sponserCurrency: json['sponser_currency'] as String,
      sponserCurExRate: json['sponser_cur_ex_rate'] as String,
      sponserConversionValue: json['sponser_conversion_value'] as String,
      binaryGenStatus: json['binary_gen_status'] as String,
      cashTransactionId: json['cash_transaction_id'] as String,
      smode: json['smode'] as String,
      orderId: json['order_id'] as String?,
      trackingId: json['tracking_id'] as String?,
      bankRefNo: json['bank_ref_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billno_prefix': billnoPrefix,
      'bill_no': billNo,
      'display_bill_no': displayBillNo,
      'reg_id': regId,
      'reg_code': regCode,
      'product_id': productId,
      'sales_type': salesType,
      'sales_date': salesDate.toIso8601String(),
      'expe_date': expeDate,
      'amt': amt,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'binary_val': binaryVal,
      'currency': currency,
      'ex_rate': exRate,
      'rupee_convertion_val': rupeeConvertionVal,
      'sponser_reg_id': sponserRegId,
      'sponser_reg_code': sponserRegCode,
      'referal_commission_rupee': referalCommissionRupee,
      'sponser_currency': sponserCurrency,
      'sponser_cur_ex_rate': sponserCurExRate,
      'sponser_conversion_value': sponserConversionValue,
      'binary_gen_status': binaryGenStatus,
      'cash_transaction_id': cashTransactionId,
      'smode': smode,
      'order_id': orderId,
      'tracking_id': trackingId,
      'bank_ref_no': bankRefNo,
    };
  }
}