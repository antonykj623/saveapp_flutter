// feedback_model.dart
class FeedbackResponse {
  final int status;
  final String message;
  final List<FeedbackItem> data;

  FeedbackResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => FeedbackItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class FeedbackItem {
  final String id;
  final String regId;
  final String regCode;
  final String sendDate;
  final String feedbackMsg;
  final String? replyMsg;
  final String? replyDate;
  final String? repliedUserid;
  final String commitStatus;
  final String approve;

  FeedbackItem({
    required this.id,
    required this.regId,
    required this.regCode,
    required this.sendDate,
    required this.feedbackMsg,
    this.replyMsg,
    this.replyDate,
    this.repliedUserid,
    required this.commitStatus,
    required this.approve,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id']?.toString() ?? '',
      regId: json['reg_id']?.toString() ?? '',
      regCode: json['reg_code']?.toString() ?? '',
      sendDate: json['send_date']?.toString() ?? '',
      feedbackMsg: json['feedback_msg']?.toString() ?? '',
      replyMsg: json['reply_msg']?.toString(),
      replyDate: json['reply_date']?.toString(),
      repliedUserid: json['replied_userid']?.toString(),
      commitStatus: json['commit_status']?.toString() ?? '0',
      approve: json['approve']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reg_id': regId,
      'reg_code': regCode,
      'send_date': sendDate,
      'feedback_msg': feedbackMsg,
      'reply_msg': replyMsg,
      'reply_date': replyDate,
      'replied_userid': repliedUserid,
      'commit_status': commitStatus,
      'approve': approve,
    };
  }

  // Helper methods
  bool get isApproved => approve == '1';
  bool get isCommitted => commitStatus == '1';
  bool get hasReply => replyMsg != null && replyMsg!.isNotEmpty;
  
  // Format send date for display
  String get formattedSendDate {
    try {
      final date = DateTime.parse(sendDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return sendDate;
    }
  }
  
  // Format reply date for display
  String? get formattedReplyDate {
    if (replyDate == null) return null;
    try {
      final date = DateTime.parse(replyDate!);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return replyDate;
    }
  }
}