import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class SMSService {
  // SMS API Configuration
  static const String smsMethod = "httpapi";
  static const String smsBaseUrl = "http://eapoluenterprise.in/httpapi/";
  static const String sender = "CGSAVE";
  static const String forgotPasswordTemplateId = "1007856104698741987";
  static const String registrationTemplateId = "1007625690429475781";
  static const String registrationConfirmTemplateId = "1007134283594642980";
  static const String route = "2";
  static const String type = "1";
  static const String apiKey = "bf25917c3254cfe9f50694f24884f23a";

  /// Generate random 4-digit OTP
  static int generateFourDigitNumber() {
    var random = Random();
    return 1000 + random.nextInt(9000); // Generates from 1000 to 9999
  }

  /// Send SMS for forgot password
  static Future<Map<String, dynamic>> sendForgotPasswordSMS(
    String phoneNumber,
    String message,
  ) async {
    return await _sendSMS(
      phoneNumber: phoneNumber,
      message: message,
      templateId: forgotPasswordTemplateId,
    );
  }

  /// Send SMS for registration
  static Future<Map<String, dynamic>> sendRegistrationSMS(
    String phoneNumber,
    String message,
  ) async {
    return await _sendSMS(
      phoneNumber: phoneNumber,
      message: message,
      templateId: registrationTemplateId,
    );
  }

  /// Send SMS for registration confirmation
  static Future<Map<String, dynamic>> sendRegistrationConfirmSMS(
    String phoneNumber,
    String message,
  ) async {
    return await _sendSMS(
      phoneNumber: phoneNumber,
      message: message,
      templateId: registrationConfirmTemplateId,
    );
  }

  /// Private method to send SMS
  static Future<Map<String, dynamic>> _sendSMS({
    required String phoneNumber,
    required String message,
    required String templateId,
  }) async {
    try {
      String encodedMessage = Uri.encodeComponent(message);
      String url =
          "$smsBaseUrl$smsMethod"
          "?token=$apiKey"
          "&sender=$sender"
          "&number=$phoneNumber"
          "&route=$route"
          "&type=$type"
          "&sms=$encodedMessage"
          "&templateid=$templateId";

      print("SMS URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print("SMS Response Status: ${response.statusCode}");
      print("SMS Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': jsonResponse,
            'message': 'SMS sent successfully',
          };
        } catch (e) {
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': response.body,
            'message': 'SMS sent successfully',
          };
        }
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'data': response.body,
          'message': 'Failed to send SMS: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Error sending SMS: $e");
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'message': 'Error sending SMS: $e',
      };
    }
  }

  /// Generate OTP (kept for backward compatibility)
  static String generateOTP({int length = 4}) {
    if (length == 4) {
      return generateFourDigitNumber().toString();
    } else {
      const String chars = '0123456789';
      var random = Random();
      String otp = '';
      for (int i = 0; i < length; i++) {
        otp += chars[random.nextInt(chars.length)];
      }
      return otp;
    }
  }

  /// Create forgot password message
  static String createForgotPasswordMessage(String otp) {
    return "Your password reset OTP is: $otp. Valid for 10 minutes. Do not share this OTP with anyone.";
  }

  /// Create registration message
  static String createRegistrationMessage(String otp) {
    return "Welcome! Your registration OTP is: $otp. Please enter this OTP to complete your registration.";
  }

  /// Create registration confirmation message
  static String createRegistrationConfirmMessage(String name) {
    return "Hello $name! Your registration is successful. Welcome to My Personal App!";
  }
}

class SMSHelper {
  /// Generate random 4-digit OTP
  static int generateFourDigitNumber() {
    var random = Random();
    return 1000 + random.nextInt(9000); // Generates from 1000 to 9999
  }

  /// Send forgot password OTP
  static Future<Map<String, dynamic>> sendForgotPasswordOTP(
    String phoneNumber,
  ) async {
    String otp = SMSService.generateOTP(length: 4);
    String message = SMSService.createForgotPasswordMessage(otp);

    final result = await SMSService.sendForgotPasswordSMS(phoneNumber, message);

    return result;
  }

  /// Send registration OTP
  static Future<Map<String, dynamic>> sendRegistrationOTP(
    String phoneNumber,
  ) async {
    String otp = SMSService.generateOTP(length: 4);
    String message = SMSService.createRegistrationMessage(otp);

    final result = await SMSService.sendRegistrationSMS(phoneNumber, message);

    return result;
  }

  /// Send registration confirmation
  static Future<Map<String, dynamic>> sendRegistrationConfirmation(
    String phoneNumber,
    String userName,
  ) async {
    String message = SMSService.createRegistrationConfirmMessage(userName);

    return await SMSService.sendRegistrationConfirmSMS(phoneNumber, message);
  }
}