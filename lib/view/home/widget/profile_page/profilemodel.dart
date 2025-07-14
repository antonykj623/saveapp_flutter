class UserProfileResponse {
  final int status;
  final String message;
  final UserProfile data;

  UserProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'],
      message: json['message'],
      data: UserProfile.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

class UserProfile {
  final String id;
  final String fullName;
  final String regCode;
  final String countryId;
  final String stateId;
  final String mobile;
  final String profileImage;
  final String emailId;
  final String currency;
  final String joinDate;
  final String activationDate;
  final String? activationKey;
  final String joinSource;
  final String usedLinkForRegistration;
  final String spRegId;
  final String deviceId;
  final String wDeviceId;
  final String wPlatform;
  final String spRegCode;
  final String defaultLang;
  final String username;
  final String encrPassword;
  final String? pwd;
  final String gdriveFileid;
  final String uniqueDeviceId;
  final String memberStatus;
  final String resellingPartner;
  final String coupon;
  final String coupStus;
  final String currentAppVersion;
  final String phoneType;
  final String driveMailId;
  final String serverbackupFileid;
  final String mathsTrialNumber;
  final String mathsTrialStatus;
  final String linkActive;
  final String wTotalPts;
  final String wRedeemedPts;
  final String wBalancePts;
  final String token;
  UserProfile({
    required this.id,
    required this.fullName,
    required this.regCode,
    required this.countryId,
    required this.stateId,
    required this.mobile,
    required this.profileImage,
    required this.emailId,
    required this.currency,
    required this.joinDate,
    required this.activationDate,
    required this.activationKey,
    required this.joinSource,
    required this.usedLinkForRegistration,
    required this.spRegId,
    required this.deviceId,
    required this.wDeviceId,
    required this.wPlatform,
    required this.spRegCode,
    required this.defaultLang,
    required this.username,
    required this.encrPassword,
    required this.pwd,
    required this.gdriveFileid,
    required this.uniqueDeviceId,
    required this.memberStatus,
    required this.resellingPartner,
    required this.coupon,
    required this.coupStus,
    required this.currentAppVersion,
    required this.phoneType,
    required this.driveMailId,
    required this.serverbackupFileid,
    required this.mathsTrialNumber,
    required this.mathsTrialStatus,
    required this.linkActive,
    required this.wTotalPts,
    required this.wRedeemedPts,
    required this.wBalancePts,
    required this.token,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name']?.trim() ?? '',
      regCode: json['reg_code'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      mobile: json['mobile'],
      profileImage: json['profile_image'],
      emailId: json['email_id'],
      currency: json['currency'],
      joinDate: json['join_date'],
      activationDate: json['activation_date'],
      activationKey: json['activation_key'],
      joinSource: json['join_source'],
      usedLinkForRegistration: json['used_link_for_registration'],
      spRegId: json['sp_reg_id'],
      deviceId: json['device_id'],
      wDeviceId: json['w_device_id'],
      wPlatform: json['w_platform'],
      spRegCode: json['sp_reg_code'],
      defaultLang: json['default_lang'],
      username: json['username'],
      encrPassword: json['encr_password'],
      pwd: json['pwd'],
      gdriveFileid: json['gdrive_fileid'],
      uniqueDeviceId: json['unique_deviceId'],
      memberStatus: json['member_status'],
      resellingPartner: json['reselling_partner'],
      coupon: json['coupon'],
      coupStus: json['coup_stus'],
      currentAppVersion: json['current_app_version'],
      phoneType: json['phone_type'],
      driveMailId: json['drive_mailId'],
      serverbackupFileid: json['serverbackup_fileid'],
      mathsTrialNumber: json['maths_trial_number'],
      mathsTrialStatus: json['maths_trial_status'],
      linkActive: json['link_active'],
      wTotalPts: json['w_total_pts'],
      wRedeemedPts: json['w_redeemed_pts'],
      wBalancePts: json['w_balance_pts'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'reg_code': regCode,
    'country_id': countryId,
    'state_id': stateId,
    'mobile': mobile,
    'profile_image': profileImage,
    'email_id': emailId,
    'currency': currency,
    'join_date': joinDate,
    'activation_date': activationDate,
    'activation_key': activationKey,
    'join_source': joinSource,
    'used_link_for_registration': usedLinkForRegistration,
    'sp_reg_id': spRegId,
    'device_id': deviceId,
    'w_device_id': wDeviceId,
    'w_platform': wPlatform,
    'sp_reg_code': spRegCode,
    'default_lang': defaultLang,
    'username': username,
    'encr_password': encrPassword,
    'pwd': pwd,
    'gdrive_fileid': gdriveFileid,
    'unique_deviceId': uniqueDeviceId,
    'member_status': memberStatus,
    'reselling_partner': resellingPartner,
    'coupon': coupon,
    'coup_stus': coupStus,
    'current_app_version': currentAppVersion,
    'phone_type': phoneType,
    'drive_mailId': driveMailId,
    'serverbackup_fileid': serverbackupFileid,
    'maths_trial_number': mathsTrialNumber,
    'maths_trial_status': mathsTrialStatus,
    'link_active': linkActive,
    'w_total_pts': wTotalPts,
    'w_redeemed_pts': wRedeemedPts,
    'w_balance_pts': wBalancePts,
    token: token,
  };
}
//new
//{
// "status" : 1,
// "data" : {
// "id" : "229",
// "full_name" : "Test\n",
// "reg_code" : "051470523",
// "country_id" : "0",
// "state_id" : "0",
// "mobile" : "9747497967",
// "profile_image" : "1551519392.jpg",
// "email_id" : "antonykj623@gmail.com",
// "currency" : "rupee",
// "join_date" : "2021-07-19 07:46:02",
// "activation_date" : "2021-08-22 06:14:11",
// "activation_key" : null,
// "join_source" : "link",
// "used_link_for_registration" : "qwertyuioplkjhgfvbnmlkjiou.ODk0MzcxNjcyNQ==.YTdjZTQ0Nzg0ODY4Y2JiOWZjMTNjMDQyN2NkODkzZWQ=.qwertyuioplkjhgfvbnmlkjiou",
// "sp_reg_id" : "22",
// "device_id" : "cpVJ897bQGazP1OA0hmEcu:APA91bF3OFQk7xWO5GU4FcbrWuv5Yq91BXpWL_yZEJ3GY6JUNXGAAwDSupSA__CZHLCuYh8lHDPQCILO__CAw_r8Cm_KxwhNWoJF896RNeC9YaW8b0wCQGE",
// "w_device_id" : "a00f0cbe656b6a4a",
// "w_platform" : "Android",
// "sp_reg_code" : "076066653",
// "default_lang" : "",
// "username" : "antonykj1994",
// "encr_password" : "25d55ad283aa400af464c76d713c07ad",
// "pwd" : null,
// "gdrive_fileid" : "1-HzhNqxIo_Vw6LtoRhoXw-Y1rnmoZexM",
// "unique_deviceId" : "ffffffff-9f2a-9070-0000-00003fc2ff52",
// "member_status" : "active-member",
// "reselling_partner" : "1",
// "coupon" : "46943KDHPQ",
// "coup_stus" : "1",
// "current_app_version" : "16.0",
// "phone_type" : "android",
// "drive_mailId" : "",
// "serverbackup_fileid" : "229-1693931583.txt",
// "maths_trial_number" : "3051470523",
// "maths_trial_status" : "1",
// "link_active" : "1",
// "w_total_pts" : "0",
// "w_redeemed_pts" : "0",
// "w_balance_pts" : "0"
// },
// "message" : "Success"
// }