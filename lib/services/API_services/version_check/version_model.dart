class AppVersionModel1 {
  final String? latestVersion;
  final bool? updateAvailable;
  final bool? forceUpdate;
  final String? updateUrl;
  final String? releaseNotes;
  final String? message;
  final int? status;
  final String? currentVersion;

  AppVersionModel1({
    this.latestVersion,
    this.updateAvailable,
    this.forceUpdate,
    this.updateUrl,
    this.releaseNotes,
    this.message,
    this.status,
    this.currentVersion,
  });

  factory AppVersionModel1.fromJson(Map<String, dynamic> json) {
    return AppVersionModel1(
      latestVersion: json['latest_version'] ?? json['version'] ?? json['app_version'],
      updateAvailable: json['update_available'] ?? _checkUpdateNeeded(json),
      forceUpdate: json['force_update'] ?? json['mandatory'] ?? false,
      updateUrl: json['update_url'] ?? json['download_url'] ?? json['app_url'] ?? _getDefaultUpdateUrl(),
      releaseNotes: json['release_notes'] ?? json['notes'] ?? json['changelog'] ?? 'Bug fixes and improvements',
      message: json['message'] ?? json['msg'],
      status: json['status'],
      currentVersion: json['current_version'],
    );
  }

  // Helper method to check if update is needed based on different response formats
  static bool _checkUpdateNeeded(Map<String, dynamic> json) {
    // If the API returns a status indicating update needed
    if (json['status'] == 0 && json['message']?.toString().toLowerCase().contains('update') == true) {
      return true;
    }
    
    // If there's version comparison data
    if (json['latest_version'] != null && json['current_version'] != null) {
      return _isNewerVersion(json['current_version'], json['latest_version']);
    }
    
    // Default to false if we can't determine
    return false;
  }

  // Helper method to get default update URL based on platform
  static String _getDefaultUpdateUrl() {
    // You can customize this based on your app's store URLs
    return ''; // Return empty string if no URL provided
  }

  // Helper method for version comparison
  static bool _isNewerVersion(String currentVersion, String newVersion) {
    try {
      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> newer = newVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < current.length && i < newer.length; i++) {
        if (newer[i] > current[i]) return true;
        if (newer[i] < current[i]) return false;
      }

      return newer.length > current.length;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'update_available': updateAvailable,
      'force_update': forceUpdate,
      'update_url': updateUrl,
      'release_notes': releaseNotes,
      'message': message,
      'status': status,
      'current_version': currentVersion,
    };
  }

  @override
  String toString() {
    return 'AppVersionModel{latestVersion: $latestVersion, updateAvailable: $updateAvailable, forceUpdate: $forceUpdate, updateUrl: $updateUrl, message: $message, status: $status}';
  }

  // Convenience methods
  bool get hasUpdate => updateAvailable == true;
  bool get isMandatoryUpdate => forceUpdate == true;
  bool get isSuccess => status == 1;
  String get displayMessage => message ?? 'Unknown response';
}