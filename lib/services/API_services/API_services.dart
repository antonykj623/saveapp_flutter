import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_project_2025/view/home/widget/setting_page/app_update/app_update_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseurl = "https://mysaving.in/IntegraAccount/api/";

class ApiHelper {
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

  // New method to check app version
  Future<AppVersionModel> checkAppVersion() async {
    final timestamp = DateTime.now().day.toString().padLeft(2, '0') + 
                     '-' + DateTime.now().month.toString().padLeft(2, '0') + 
                     '-' + DateTime.now().year.toString();
    
    try {
      final response = await getApiResponse('getMobileAppVersion.php?timestamp=$timestamp');
      final jsonData = json.decode(response);
      return AppVersionModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to check app version: $e');
    }
  }
  
  // Existing methods...
  Future<String> getFeedback() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse('getFeedback.php?timestamp=$timestamp');
  }
  
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
  
  Future<String> getFeedbackByDate(String date) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse(
      'getFeedback.php?timestamp=$timestamp&dateorder=$date',
    );
  }
  
  Future<String> getFeedbackByStatus(String status) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return await getApiResponse(
      'getFeedback.php?timestamp=$timestamp&status=$status',
    );
  }
  
  Future<String> getFeedbackWithTimestamp(String timestamp) async {
    return await getApiResponse('getFeedback.php?timestamp=$timestamp');
  }
  
  Future<String> addFeedback(String message) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    final postData = {'message': message, 'timestamp': timestamp};
    
    return await postApiResponse('addFeedback.php', postData);
  }
}