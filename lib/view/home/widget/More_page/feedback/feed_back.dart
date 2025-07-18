import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'dart:convert';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with TickerProviderStateMixin {
  final ApiHelper _apiHelper = ApiHelper();
  List<FeedbackItem> feedbackList = [];
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadFeedback();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await _apiHelper.getFeedback();
      final Map<String, dynamic> jsonResponse = json.decode(response);
      final FeedbackResponse feedbackResponse = FeedbackResponse.fromJson(
        jsonResponse,
      );

      if (feedbackResponse.status == 1) {
        setState(() {
          feedbackList =
              feedbackResponse.data..sort((a, b) {
                final dateA = DateTime.tryParse(a.sendDate) ?? DateTime.now();
                final dateB = DateTime.tryParse(b.sendDate) ?? DateTime.now();
                return dateB.compareTo(dateA); // Newest first
              });
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          errorMessage =
              feedbackResponse.message.isNotEmpty
                  ? feedbackResponse.message
                  : 'Failed to load feedback';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshFeedback() async {
    setState(() {
      isLoading = true;
    });
    _animationController.reset();
    await _loadFeedback();
    await Future.delayed(const Duration(milliseconds: 100));
    _animationController.forward();
  }

  void _showAddFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.feedback,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Add Your Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      labelText: 'Your Feedback',
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      hintText: 'Share your thoughts and suggestions...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                    maxLines: 5,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (feedbackController.text.trim().isNotEmpty) {
                          _submitFeedback(feedbackController.text.trim());
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 8),
                          Text('Submit', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback(String feedbackText) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Submitting feedback...'),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      final response = await _apiHelper.addFeedback(feedbackText);
      final Map<String, dynamic> jsonResponse = json.decode(response);

      if (jsonResponse['status'] == 1 || jsonResponse['success'] == true) {
        // Create temporary feedback object (use dummy ID or from response if available)
        final newFeedback = FeedbackItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          regId: '0', // or actual user ID if available
          regCode: 'REG123', // optional registration code
          sendDate: DateTime.now().toIso8601String(),
          feedbackMsg: feedbackText,
          replyMsg: null,
          replyDate: null,
          repliedUserid: null,
          commitStatus: '1',
          approve: '0', // Not approved yet
        );

        setState(() {
          feedbackList.insert(0, newFeedback);
          _animationController.forward(from: 0.0);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    jsonResponse['message'] ??
                        'Feedback submitted successfully!',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showErrorSnack(jsonResponse['message'] ?? 'Failed to submit feedback');
      }
    } catch (e) {
      _showErrorSnack('Error submitting feedback: ${e.toString()}');
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              onPressed: _showAddFeedbackDialog,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
              onPressed: _refreshFeedback,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Try Again', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (feedbackList.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  size: 48,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Feedback Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Be the first to share your feedback!\nYour thoughts matter to us.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showAddFeedbackDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('Add Feedback', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshFeedback,
        color: Colors.blue.shade600,
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              child: _buildFeedbackCard(feedback, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackItem feedback, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: feedback.isApproved ? 8 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              feedback.isApproved
                  ? BorderSide(color: Colors.blue.shade300, width: 2)
                  : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                feedback.isApproved
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.white],
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade800],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Feedback #${feedback.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildStatusChip(feedback),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    feedback.feedbackMsg,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (feedback.hasReply) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade50, Colors.green.shade50],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade100,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.reply,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Admin Reply',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feedback.replyMsg!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        if (feedback.formattedReplyDate != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Replied on: ${feedback.formattedReplyDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reg: ${feedback.regCode}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            feedback.formattedSendDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(FeedbackItem feedback) {
    if (feedback.isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade700],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Approved',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink(); // No chip for pending status
    }
  }
}

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
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => FeedbackItem.fromJson(item))
              .toList() ??
          [],
    );
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

  bool get isApproved => approve == '1';
  bool get isCommitted => commitStatus == '1';
  bool get hasReply => replyMsg != null && replyMsg!.isNotEmpty;

  String get formattedSendDate {
    try {
      final date = DateTime.parse(sendDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return sendDate;
    }
  }

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
