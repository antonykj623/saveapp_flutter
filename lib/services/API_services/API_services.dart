import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String baseurl = "https://mysaving.in/IntegraAccount/api/";



class ApiHelper {
  Future<String> getApiResponse(String method) async {

    final prefs = await SharedPreferences.getInstance();
   
     String? token =  await prefs.getString('token');
 
Map<String, String> headers = {
  "Authorization":
    (token!=null && token.toString().isEmpty)?token.toString():""  ,
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
   
     String? token =  await prefs.getString('token');
 
Map<String, String> headers = {
  "Authorization":
    (token!=null && token.toString().isEmpty)?token.toString():""  ,
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
}
