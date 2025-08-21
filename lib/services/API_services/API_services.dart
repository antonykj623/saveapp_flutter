import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/API_services/version_check/version_model.dart';
import 'package:new_project_2025/view/home/widget/Invoice_page/class_invoice/Model_class_invoice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_update/app_update_class.dart';

class ApiHelper {
  // API endpoint constants
  static const String baseUrl = "https://mysaving.in/IntegraAccount/api/";
  static const String generateHash = "generateHash.php";

  // Generate timestamp for API requests
  String getTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // General GET request method
  Future<String> getApiResponse(String method) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.get(
      Uri.parse(baseUrl + method),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Failed to load data: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // General POST request method (existing)
  Future<String> postApiResponse(String method, dynamic postData) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.post(
      Uri.parse(baseUrl + method),
      headers: headers,
      body: postData,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Failed to post data: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // POST request for Ecommerce APIs (from EcommerceApiHelper)
  Future<String> postEcommerce(String endpoint, {required Map<String, String> formDataPayload}) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: headers,
      body: formDataPayload,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Failed to post data: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // ===== NOTIFICATION METHODS =====

  /// Get all notifications
  Future<List<dynamic>> getNotifications() async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      String response = await getApiResponse(
        "getNotificationsData.php?timestamp=$timestamp",
      );

      final decodedResponse = json.decode(response);

      if (decodedResponse['status'] == 1 && decodedResponse['data'] is List) {
        return decodedResponse['data'];
      } else {
        throw Exception('Invalid response format or no data available');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Get notifications with filters
  Future<List<dynamic>> getNotificationsWithFilters({
    String? dateOrder,
    String? status,
    String? category,
    int? limit,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String url = "getNotificationsData.php?timestamp=$timestamp";

    if (dateOrder != null && dateOrder.isNotEmpty) {
      url += '&dateorder=$dateOrder';
    }

    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    if (limit != null && limit > 0) {
      url += '&limit=$limit';
    }

    try {
      String response = await getApiResponse(url);
      final decodedResponse = json.decode(response);

      if (decodedResponse['status'] == 1 && decodedResponse['data'] is List) {
        return decodedResponse['data'];
      } else {
        throw Exception('Invalid response format or no data available');
      }
    } catch (e) {
      throw Exception('Failed to fetch filtered notifications: $e');
    }
  }

  /// Get notifications by date range
  Future<List<dynamic>> getNotificationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    String url = "getNotificationsData.php?timestamp=$timestamp"
        "&start_date=$startDateStr&end_date=$endDateStr";

    try {
      String response = await getApiResponse(url);
      final decodedResponse = json.decode(response);

      if (decodedResponse['status'] == 1 && decodedResponse['data'] is List) {
        return decodedResponse['data'];
      } else {
        throw Exception('Invalid response format or no data available');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications by date range: $e');
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final postData = {
      'notification_id': notificationId.toString(),
      'timestamp': timestamp,
      'status': 'read',
    };

    try {
      String response = await postApiResponse('updateNotificationStatus.php', postData);
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final postData = {
      'timestamp': timestamp,
      'action': 'mark_all_read',
    };

    try {
      String response = await postApiResponse('updateAllNotificationsStatus.php', postData);
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final postData = {
      'notification_id': notificationId.toString(),
      'timestamp': timestamp,
    };

    try {
      String response = await postApiResponse('deleteNotification.php', postData);
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Get notification count (unread)
  Future<int> getUnreadNotificationCount() async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      String response = await getApiResponse(
        "getNotificationCount.php?timestamp=$timestamp&status=unread",
      );

      final decodedResponse = json.decode(response);

      if (decodedResponse['status'] == 1) {
        return int.parse(decodedResponse['count'].toString());
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to fetch notification count: $e');
    }
  }

  // ===== EXISTING METHODS =====

  Future<AppVersionModel1> checkAppVersion1() async {
    // Placeholder for existing implementation
    throw UnimplementedError(
      'Use your existing ApiHelper checkAppVersion1 method',
    );
  }

  // Verify user credentials before deletion
  Future<Map<String, dynamic>> verifyUserCredentials(
    String mobile,
    String password,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');

    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final postData = {
      "mobile": mobile,
      "password": password,
      "timestamp": timestamp,
    };

    final response = await http.post(
      Uri.parse(baseUrl + "UserLogin.php"),
      headers: headers,
      body: postData,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to verify credentials: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');

    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.get(
      Uri.parse(baseUrl + "deleteAccount.php?timestamp=$timestamp"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to delete account: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Fetch sales data using getDSTSales endpoint
  Future<SalesData> getDSTSales(String regId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final response = await getApiResponse(
        'getDSTSales.php?timestamp=$timestamp&regid=$regId',
      );
      final jsonData = json.decode(response);
      if (jsonData['status'] == 1) {
        return SalesData.fromJson(jsonData['data']);
      } else {
        throw Exception('API returned error: ${jsonData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sales data: $e');
    }
  }

  // Check app version
  Future<AppVersionModel> checkAppVersion() async {
    final timestamp =
        DateFormat('dd-MM-yyyy').format(DateTime.now());

    try {
      final response = await getApiResponse(
        'getMobileAppVersion.php?timestamp=$timestamp',
      );
      final jsonData = json.decode(response);
      return AppVersionModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to check app version: $e');
    }
  }

  // Get feedback
  Future<String> getFeedback() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse('getFeedback.php?timestamp=$timestamp');
  }

  // Get feedback with filters
  Future<String> getFeedbackWithFilters({
    String? timestamp,
    String? dateOrder,
    String? status,
  }) async {
    final currentTimestamp =
        timestamp ?? DateTime.now().millisecondsSinceEpoch.toString();
    String url = 'getFeedback.php?timestamp=$currentTimestamp';

    if (dateOrder != null && dateOrder.isNotEmpty) {
      url += '&dateorder=$dateOrder';
    }

    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    return await getApiResponse(url);
  }

  // Get feedback by date
  Future<String> getFeedbackByDate(String date) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse(
      'getFeedback.php?timestamp=$timestamp&dateorder=$date',
    );
  }

  // Get feedback by status
  Future<String> getFeedbackByStatus(String status) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse(
      'getFeedback.php?timestamp=$timestamp&status=$status',
    );
  }

  // Get feedback with specific timestamp
  Future<String> getFeedbackWithTimestamp(String timestamp) async {
    return await getApiResponse('getFeedback.php?timestamp=$timestamp');
  }

  // Add feedback
  Future<String> addFeedback(String message) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final postData = {'message': message, 'timestamp': timestamp};
    return await postApiResponse('addFeedback.php', postData);
  }
}