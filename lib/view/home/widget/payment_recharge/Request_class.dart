 class RechargeRequest {
  final String timestamp;
  final String userId;
  final String mobileNumber;
  final String accountNumber;
  final String transactionId;
  final String operatorCircle;
  final String amount;
  final String rechargeAmount;
  final String operatorName;
  final String rpId;
  final String agentId;
  final String status;
  final String rechargeType;
  final String spKey;
  final String paymentStatus;
  final String paymentMode;

  RechargeRequest({
    required this.timestamp,
    required this.userId,
    required this.mobileNumber,
    required this.accountNumber,
    required this.transactionId,
    required this.operatorCircle,
    required this.amount,
    required this.rechargeAmount,
    required this.operatorName,
    required this.rpId,
    required this.agentId,
    required this.status,
    required this.rechargeType,
    required this.spKey,
    required this.paymentStatus,
    required this.paymentMode,
  });

  factory RechargeRequest.fromJson(Map<String, dynamic> json) {
    return RechargeRequest(
      timestamp: json['timestamp'] ?? '',
      userId: json['user_id'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      accountNumber: json['account_number'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      operatorCircle: json['operatorcircle'] ?? '',
      amount: json['amount'] ?? '',
      rechargeAmount: json['rechargeamount'] ?? '',
      operatorName: json['operator'] ?? '',
      rpId: json['rp_id'] ?? '',
      agentId: json['agent_id'] ?? '',
      status: json['status'] ?? '1', // Default status set to '1'
      rechargeType: json['recharge_type'] ?? '1', // Default recharge_type set to '1'
      spKey: json['spkey'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMode: json['Payment_Mode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'user_id': userId,
      'mobile_number': mobileNumber,
      'account_number': accountNumber,
      'transaction_id': transactionId,
      'operatorcircle': operatorCircle,
      'amount': amount,
      'rechargeamount': rechargeAmount,
      'operator': operatorName,
      'rp_id': rpId,
      'agent_id': agentId,
      'status': status,
      'recharge_type': rechargeType,
      'spkey': spKey,
      'payment_status': paymentStatus,
      'Payment_Mode': paymentMode,
    };
  }
}