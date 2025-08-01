import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_project_2025/view/home/widget/Invoice_page/class_invoice/Model_class_invoice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/view/home/widget/setting_page/app_update/app_update_class.dart'; 

class ApiHelper {
  final String baseurl = "https://mysaving.in/IntegraAccount/api/";

  // General GET request method
  Future<String> getApiResponse(String method) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.get(
      Uri.parse(baseurl + method),
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

  // General POST request method
  Future<String> postApiResponse(String method, dynamic postData) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    Map<String, String> headers = {
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final response = await http.post(
      Uri.parse(baseurl + method),
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

  // Verify user credentials before deletion
  Future<Map<String, dynamic>> verifyUserCredentials(String mobile, String password) async {
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
      Uri.parse(baseurl + "UserLogin.php"),
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
      Uri.parse(baseurl + "deleteAccount.php?timestamp=$timestamp"),
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
        DateTime.now().day.toString().padLeft(2, '0') +
        '-' +
        DateTime.now().month.toString().padLeft(2, '0') +
        '-' +
        DateTime.now().year.toString();

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