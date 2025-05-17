import 'dart:convert';
import 'package:http/http.dart' as http;

String baseurl = "https://mysaving.in/IntegraAccount/api/";

Map<String, String> headers = {
  "Authorization":
      "qwertyuioplkjhgfvbnmlkjiou.OTg0NjI5MDU1NQ==.YmM0MTIwMGI5NDEzNzQwMTM3MzdiZTViNGZlNDM2NDA=.qwertyuioplkjhgfvbnmlkjiou",
  "Content-Type": "application/json", 
};

class ApiHelper {
  Future<String> getApiResponse(String method) async {
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
    final response = await http.post(
      Uri.parse(baseurl + method),
      headers: headers,
      body: jsonEncode(postData), 
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
