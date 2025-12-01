import 'dart:convert';

class RechargeHistoryEntity {
  int? status;
  String? message;   
  List<RechargeHistoryData>? data;

  RechargeHistoryEntity({
    this.status,
    this.message,
    this.data,
  });

  factory RechargeHistoryEntity.fromJson(Map<String, dynamic> json) {
    return RechargeHistoryEntity(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RechargeHistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RechargeHistoryData {
  String? id;
  String? userId;
  String? rechargeType;
  String? mobileNumber;
  String? accountNumber;
  String? transactionId;
  String? amount;
  String? rechargeAmount;
  String? paymentMode;
  String? operatorName; // renamed from "operator" (since it's a reserved keyword in some contexts)
  String? rechargeDate;
  String? spkey;
  String? rpId;
  String? agentId;
  String? operatorCirclerCode;
  String? paymentStatus;
  String? status;
  String? genStatus;
  dynamic refundDate;
  dynamic refundTransactionId;
  String? transactionAmount;

  RechargeHistoryData({
    this.id,
    this.userId,
    this.rechargeType,
    this.mobileNumber,
    this.accountNumber,
    this.transactionId,
    this.amount,
    this.rechargeAmount,
    this.paymentMode,
    this.operatorName,
    this.rechargeDate,
    this.spkey,
    this.rpId,
    this.agentId,
    this.operatorCirclerCode,
    this.paymentStatus,
    this.status,
    this.genStatus,
    this.refundDate,
    this.refundTransactionId,
    this.transactionAmount,
  });

  factory RechargeHistoryData.fromJson(Map<String, dynamic> json) {
    return RechargeHistoryData(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      rechargeType: json['recharge_type'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      accountNumber: json['account_number'] as String?,
      transactionId: json['transaction_id'] as String?,
      amount: json['amount'] as String?,
      rechargeAmount: json['rechargeamount'] as String?,
      paymentMode: json['Payment_Mode'] as String?,
      operatorName: json['operator'] as String?,
      rechargeDate: json['recharge_date'] as String?,
      spkey: json['spkey'] as String?,
      rpId: json['rp_id'] as String?,
      agentId: json['agent_id'] as String?,
      operatorCirclerCode: json['operator_circler_code'] as String?,
      paymentStatus: json['payment_status'] as String?,
      status: json['status'] as String?,
      genStatus: json['gen_status'] as String?,
      refundDate: json['refund_date'],
      refundTransactionId: json['refund_transactionid'],
      transactionAmount: json['transaction_amount'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recharge_type': rechargeType,
      'mobile_number': mobileNumber,
      'account_number': accountNumber,
      'transaction_id': transactionId,
      'amount': amount,
      'rechargeamount': rechargeAmount,
      'Payment_Mode': paymentMode,
      'operator': operatorName,
      'recharge_date': rechargeDate,
      'spkey': spkey,
      'rp_id': rpId,
      'agent_id': agentId,
      'operator_circler_code': operatorCirclerCode,
      'payment_status': paymentStatus,
      'status': status,
      'gen_status': genStatus,
      'refund_date': refundDate,
      'refund_transactionid': refundTransactionId,
      'transaction_amount': transactionAmount,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
