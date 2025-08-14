import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Mobile Plan Models
class MobilePlanResponse {
  final String status;
  final List<Category> categories;
  final String requestId;
  final double processingTime;

  MobilePlanResponse({
    required this.status,
    required this.categories,
    required this.requestId,
    required this.processingTime,
  });

  factory MobilePlanResponse.fromJson(Map<String, dynamic> json) {
    return MobilePlanResponse(
      status: json['status'] ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((category) => Category.fromJson(category))
              .toList() ??
          [],
      requestId: json['requestId'] ?? '',
      processingTime: (json['processingTime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'categories': categories.map((category) => category.toJson()).toList(),
      'requestId': requestId,
      'processingTime': processingTime,
    };
  }
}

class Category {
  final String name;
  final String fullName;
  final List<Plan> plans;

  Category({required this.name, required this.fullName, required this.plans});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      plans:
          (json['plans'] as List<dynamic>?)
              ?.map((plan) => Plan.fromJson(plan))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fullName': fullName,
      'plans': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class Plan {
  final int id;
  final int amount;
  final String validity;
  final double talktime;
  final int? validityDays;
  final String benefit;
  final String calls;
  final String sms;
  final String data;
  final List<Subscription> subscriptions;
  final String remark;
  final bool rechargeable;
  final double? dailyCost;
  final String addedAt;

  Plan({
    required this.id,
    required this.amount,
    required this.validity,
    required this.talktime,
    this.validityDays,
    required this.benefit,
    required this.calls,
    required this.sms,
    required this.data,
    required this.subscriptions,
    required this.remark,
    required this.rechargeable,
    this.dailyCost,
    required this.addedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0,
      validity: json['validity'] ?? '',
      talktime: (json['talktime'] as num?)?.toDouble() ?? 0.0,
      validityDays: json['validityDays'],
      benefit: json['benefit'] ?? '',
      calls: json['calls'] ?? '',
      sms: json['sms'] ?? '',
      data: json['data'] ?? '',
      subscriptions:
          (json['subscriptions'] as List<dynamic>?)
              ?.map((sub) => Subscription.fromJson(sub))
              .toList() ??
          [],
      remark: json['remark'] ?? '',
      rechargeable: json['rechargeable'] ?? false,
      dailyCost: (json['dailyCost'] as num?)?.toDouble(),
      addedAt: json['addedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'validity': validity,
      'talktime': talktime,
      'validityDays': validityDays,
      'benefit': benefit,
      'calls': calls,
      'sms': sms,
      'data': data,
      'subscriptions': subscriptions.map((sub) => sub.toJson()).toList(),
      'remark': remark,
      'rechargeable': rechargeable,
      'dailyCost': dailyCost,
      'addedAt': addedAt,
    };
  }
}

class Subscription {
  final String code;
  final String logo;
  final String name;
  final int popularity;

  Subscription({
    required this.code,
    required this.logo,
    required this.name,
    required this.popularity,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      code: json['code'] ?? '',
      logo: json['logo'] ?? '',
      name: json['name'] ?? '',
      popularity: json['popularity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'logo': logo, 'name': name, 'popularity': popularity};
  }
}

// API Service Class
class MobilePlansApiService {
  static String baseUrl = 'https://mysaveapp.com/easyrecharge/newrecharge';

  // Operator code mapping
  static const Map<String, String> operatorCodes = {
    'AIRTEL': 'AT',
    'BSNL': 'CG',
    'VI': 'VI',
    'JIO': 'RJ',
  };

  // Circle code mapping (you already have this in your existing code)
  static const Map<String, String> circleCodes = {
    "Andhra Pradesh": "AP",
    "Assam": "AS",
    "Bihar and Jharkhand": "BR",
    "Delhi Metro": "DL",
    "Gujarat": "GJ",
    "Himachal Pradesh": "HP",
    "Haryana": "HR",
    "Jammu and Kashmir": "JK",
    "Kerala": "KL",
    "Karnataka": "KA",
    "Kolkata Metro": "KO",
    "Maharashtra": "MH",
    "Madhya Pradesh and Chhattisgarh": "MP",
    "Mumbai Metro": "MU",
    "North East India": "NE",
    "Odisha": "OR",
    "Punjab": "PB",
    "Rajasthan": "RJ",
    "Tamil Nadu": "TN",
    "Uttar Pradesh(East)": "UE",
    "Uttar Pradesh (West) and Uttarakhand": "UW",
    "West Bengal": "WB",
  };

  static Future<Map<String, dynamic>?> fetchCircleAndOperator(
    String mobile,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final url = Uri.parse(
        '$baseUrl/mobileCircle.php?mobile=$mobile&timestamp=$timestamp',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          return json['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching circle and operator: $e');
      return null;
    }
  }

  /// Fetch mobile plans
  static Future<MobilePlanResponse?> fetchMobilePlans({
    required String mobileNumber,
    required String circle,
    required String operatorCode,
  }) async {
    try {
      // Get operator code from mapping
      final opCode = operatorCodes[operatorCode];
      // Get circle code from mapping
      final circleCode = circleCodes[circle];

      if (opCode == null || circleCode == null) {
        print('Invalid operator code or circle');
        return null;
      }

      // Generate a unique request ID (you can customize this)
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      final url = Uri.parse(
        '$baseUrl/mobilePlans.php?q=$requestId&circle=$circleCode&operatorcode=$opCode',
      );

      print('Fetching plans from: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return MobilePlanResponse.fromJson(json);
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching mobile plans: $e');
      return null;
    }
  }

  /// Convert API Plan to your existing plan format for compatibility
  static Map<String, dynamic> convertApiPlanToLocal(
    Plan apiPlan,
    String category,
  ) {
    // Determine color based on amount or category
    Color planColor = _getPlanColor(apiPlan.amount, category);

    // Create benefits list from API data
    List<String> benefits = [];
    if (apiPlan.data.isNotEmpty && apiPlan.data != "NA") {
      benefits.add('${apiPlan.data} High Speed Data');
    }
    if (apiPlan.calls.isNotEmpty && apiPlan.calls != "NA") {
      benefits.add(apiPlan.calls);
    }
    if (apiPlan.sms.isNotEmpty && apiPlan.sms != "NA") {
      benefits.add(apiPlan.sms);
    }
    if (apiPlan.benefit.isNotEmpty) {
      benefits.add(apiPlan.benefit);
    }

    // Add subscription benefits
    for (var subscription in apiPlan.subscriptions) {
      benefits.add('${subscription.name} Subscription');
    }

    // Determine if plan is popular (you can customize this logic)
    bool isPopular = apiPlan.subscriptions.isNotEmpty || apiPlan.amount >= 399;

    return {
      'id': apiPlan.id.toString(),
      'amount': apiPlan.amount,
      'validity': apiPlan.validity,
      'data': apiPlan.data.isEmpty ? '' : apiPlan.data,
      'description': _generateDescription(apiPlan),
      'category': category,
      'popular': isPopular,
      'color': planColor,
      'benefits': benefits,
      'savings':
          apiPlan.dailyCost != null
              ? 'Save ₹${(apiPlan.dailyCost! * 30).toStringAsFixed(0)}/month'
              : null,
      'calls': apiPlan.calls,
      'sms': apiPlan.sms,
      'talktime': apiPlan.talktime,
      'validityDays': apiPlan.validityDays,
      'subscriptions': apiPlan.subscriptions,
      'rechargeable': apiPlan.rechargeable,
    };
  }

  static Color _getPlanColor(int amount, String category) {
    if (category.toLowerCase().contains('unlimited')) {
      return Colors.purple;
    } else if (category.toLowerCase().contains('data')) {
      return Colors.blue;
    } else if (category.toLowerCase().contains('talktime')) {
      return Colors.green;
    } else {
      // Color based on amount
      if (amount < 100) return Colors.green;
      if (amount < 300) return Colors.blue;
      if (amount < 500) return Colors.orange;
      return Colors.purple;
    }
  }

  static String _generateDescription(Plan plan) {
    List<String> parts = [];

    if (plan.data.isNotEmpty && plan.data != "NA") {
      parts.add(plan.data);
    }

    if (plan.calls.isNotEmpty &&
        plan.calls != "NA" &&
        !plan.calls.toLowerCase().contains('unlimited')) {
      parts.add('Calls');
    } else if (plan.calls.toLowerCase().contains('unlimited')) {
      parts.add('Unlimited Calls');
    }

    if (plan.sms.isNotEmpty &&
        plan.sms != "NA" &&
        !plan.sms.toLowerCase().contains('unlimited')) {
      parts.add('SMS');
    } else if (plan.sms.toLowerCase().contains('unlimited')) {
      parts.add('Unlimited SMS');
    }

    if (plan.subscriptions.isNotEmpty) {
      parts.add('OTT Benefits');
    }

    return parts.isEmpty ? 'Recharge Plan' : parts.join(' + ');
  }
}

// Exception class for API errors
class MobilePlansApiException implements Exception {
  final String message;
  final int? statusCode;

  MobilePlansApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'MobilePlansApiException: $message';
}
