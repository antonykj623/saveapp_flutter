import 'dart:convert';

class MobileRechargeResponse {
  String account;
  double amount;
  String rpid;
  String agentid;
  String opid;
  bool isRefundStatusShow;
  int status;
  String msg;
  double bal;
  String errorcode;

  MobileRechargeResponse({
    this.account = "",
    this.amount = 0.0,
    this.rpid = "",
    this.agentid = "",
    this.opid = "",
    this.isRefundStatusShow = false,
    this.status = 0,
    this.msg = "",
    this.bal = 0.0,
    this.errorcode = "",
  });

  factory MobileRechargeResponse.fromJson(Map<String, dynamic> json) {
    return MobileRechargeResponse(
      account: json['account'] ?? "",
      amount: (json['amount'] ?? 0.0).toDouble(),
      rpid: json['rpid'] ?? "",
      agentid: json['agentid'] ?? "",
      opid: json['opid'] ?? "",
      isRefundStatusShow: json['isRefundStatusShow'] ?? false,
      status: json['status'] ?? 0,
      msg: json['msg'] ?? "",
      bal: (json['bal'] ?? 0.0).toDouble(),
      errorcode: json['errorcode'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'rpid': rpid,
      'agentid': agentid,
      'opid': opid,
      'isRefundStatusShow': isRefundStatusShow,
      'status': status,
      'msg': msg,
      'bal': bal,
      'errorcode': errorcode,
    };
  }

  /// Optional: helper to parse from JSON string
  static MobileRechargeResponse fromJsonString(String jsonStr) =>
      MobileRechargeResponse.fromJson(json.decode(jsonStr));

  /// Optional: helper to convert to JSON string
  String toJsonString() => json.encode(toJson());
}
