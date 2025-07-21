// app_version_model.dart
class AppVersionModel {
  final int status;
  final String message;
  final AppVersionData data;

  AppVersionModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: AppVersionData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class AppVersionData {
  final String id;
  final String appVersion;
  final String filepath;

  AppVersionData({
    required this.id,
    required this.appVersion,
    required this.filepath,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      id: json['id'] ?? '',
      appVersion: json['app_version'] ?? '',
      filepath: json['filepath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_version': appVersion,
      'filepath': filepath,
    };
  }
}