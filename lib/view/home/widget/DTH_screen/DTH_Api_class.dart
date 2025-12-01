import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ApiHelper1 {
  // Base URLs
  static const String baseUrl = "https://mysaving.in/IntegraAccount/api/";
  static const String easyRechargeBaseUrl =
      "https://mysaveapp.com/easyrecharge/";
  static const String generateHashUrl =
      "https://mysaveapp.com/generateHash.php";

  // Generate timestamp
  String getRandomnumber() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  // Show loading dialog
  static showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text("Loading..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Get headers with proper token management
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
    };
  }

  // Get headers for JSON requests
  Future<Map<String, String>> _getJsonHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      "Content-Type": "application/json",
      "Authorization": (token != null && token.isNotEmpty) ? token : "",
    };
  }

  // GET API request
  Future<String> getApiResponse(String url) async {
    try {
      Map<String, String> headers;

      // Check if it's a full URL or just an endpoint
      if (url.startsWith('http')) {
        headers = await _getJsonHeaders();
      } else {
        headers = await _getJsonHeaders();
        url = baseUrl + url;
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
          'Failed to load data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST API request
  Future<String> postApiResponse(
    String url,
    Map<String, String> postData,
  ) async {
    try {
      Map<String, String> headers;

      // Check if it's a full URL or just an endpoint
      if (url.startsWith('http')) {
        headers = await _getHeaders();
      } else {
        headers = await _getHeaders();
        url = baseUrl + url;
      }

      final response = await http.post(
        Uri.parse(url),
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
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request for Ecommerce APIs
  Future<String> postEcommerce(
    String endpoint, {
    required Map<String, String> formDataPayload,
  }) async {
    final headers = await _getHeaders();

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

  // Generate hash for payments
  Future<String> generateHash(String data) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final url = "$generateHashUrl?timestamp=$timestamp";

    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: {"data": data},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse["value"] ?? "";
    } else {
      throw Exception('Failed to generate hash: ${response.statusCode}');
    }
  }

  Future<String> getDTHPlans(String operatorCode, String type) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final url =
        "${easyRechargeBaseUrl}newrecharge/DTHplans.php?timestamp=$timestamp&operatorcode=$operatorCode&type=$type";

    return await getApiResponse(url);
  }

  Future<String> getUserDetails() async {
    return await postApiResponse("getUserDetails.php", {});
  }

  Future<String> getPaymentCredentials() async {
    return await postApiResponse("ecommerce_api/getPaymentCredentials.php", {});
  }

  Future<String> updatePaymentDetails(Map<String, String> params) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final url =
        "${easyRechargeBaseUrl}updatePaymentdetailsToRecharge.php?timestamp=$timestamp";

    return await postApiResponse(url, params);
  }

  Future<String> postTransactionData(Map<String, String> params) async {
    return await postApiResponse("PostTransactionata.php", params);
  }

  Future<String> updateRechargeStatus(Map<String, String> params) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final url =
        "https://mysaving.in/IntegraAccount/api/updateRechargeStatus.php?timestamp=$timestamp";

    return await postApiResponse(url, params);
  }

  // Update recharge status retry
  Future<String> updateRechargeStatusRetry(Map<String, String> params) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final url =
        "https://mysaving.in/IntegraAccount/api/updateRechargeStatusRetry.php?timestamp=$timestamp";

    return await postApiResponse(url, params);
  }

  // Verify user credentials
  Future<Map<String, dynamic>> verifyUserCredentials(
    String mobile,
    String password,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final postData = {
      "mobile": mobile,
      "password": password,
      "timestamp": timestamp,
    };

    final response = await postApiResponse("UserLogin.php", postData);
    return json.decode(response);
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final url = "deleteAccount.php?timestamp=$timestamp";

    final response = await getApiResponse(url);
    return json.decode(response);
  }

  static showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Generic error handler
  static void handleApiError(
    BuildContext context,
    String operation,
    dynamic error,
  ) {
    String errorMessage = "An error occurred during $operation";

    if (error is Exception) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    showAlertDialog(context, "Error", errorMessage);
  }

  // Check network connectivity (you might want to add connectivity_plus package)
  Future<bool> hasNetworkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://www.google.com'),
            headers: {'Connection': 'close'},
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Clear token from SharedPreferences
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
