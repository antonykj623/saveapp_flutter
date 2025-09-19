import 'dart:convert';

class ProfileEntity {
  int? status;
  ProfileData? data;
  String? message;

  ProfileEntity({this.status, this.data, this.message});

  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      status: json['status'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "data": data?.toJson(),
      "message": message,
    };
  }

  @override
  String toString() => jsonEncode(this);
}

class ProfileData {
  String? id;
  String? fullName;
  String? regCode;
  String? countryId;
  String? stateId;
  String? mobile;
  String? profileImage;
  String? emailId;
  String? currency;
  String? joinDate;
  String? activationDate;
  dynamic activationKey;
  String? joinSource;
  String? usedLinkForRegistration;
  String? spRegId;
  String? deviceId;
  String? wDeviceId;
  String? wPlatform;
  String? spRegCode;
  String? defaultLang;
  String? username;
  String? encrPassword;
  dynamic pwd;
  String? gdriveFileid;
  String? uniqueDeviceid;
  String? memberStatus;
  String? resellingPartner;
  String? coupon;
  String? coupStus;
  String? currentAppVersion;
  String? phoneType;
  String? driveMailid;
  String? serverbackupFileid;
  String? mathsTrialNumber;
  String? mathsTrialStatus;
  String? linkActive;
  String? wTotalPts;
  String? wRedeemedPts;
  String? wBalancePts;
  String? cartWithdrawPts;

  ProfileData({
    this.id,
    this.fullName,
    this.regCode,
    this.countryId,
    this.stateId,
    this.mobile,
    this.profileImage,
    this.emailId,
    this.currency,
    this.joinDate,
    this.activationDate,
    this.activationKey,
    this.joinSource,
    this.usedLinkForRegistration,
    this.spRegId,
    this.deviceId,
    this.wDeviceId,
    this.wPlatform,
    this.spRegCode,
    this.defaultLang,
    this.username,
    this.encrPassword,
    this.pwd,
    this.gdriveFileid,
    this.uniqueDeviceid,
    this.memberStatus,
    this.resellingPartner,
    this.coupon,
    this.coupStus,
    this.currentAppVersion,
    this.phoneType,
    this.driveMailid,
    this.serverbackupFileid,
    this.mathsTrialNumber,
    this.mathsTrialStatus,
    this.linkActive,
    this.wTotalPts,
    this.wRedeemedPts,
    this.wBalancePts,
    this.cartWithdrawPts,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      fullName: json['full_name'],
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
      uniqueDeviceid: json['unique_deviceId'],
      memberStatus: json['member_status'],
      resellingPartner: json['reselling_partner'],
      coupon: json['coupon'],
      coupStus: json['coup_stus'],
      currentAppVersion: json['current_app_version'],
      phoneType: json['phone_type'],
      driveMailid: json['drive_mailId'],
      serverbackupFileid: json['serverbackup_fileid'],
      mathsTrialNumber: json['maths_trial_number'],
      mathsTrialStatus: json['maths_trial_status'],
      linkActive: json['link_active'],
      wTotalPts: json['w_total_pts'],
      wRedeemedPts: json['w_redeemed_pts'],
      wBalancePts: json['w_balance_pts'],
      cartWithdrawPts: json['cart_withdraw_pts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "reg_code": regCode,
      "country_id": countryId,
      "state_id": stateId,
      "mobile": mobile,
      "profile_image": profileImage,
      "email_id": emailId,
      "currency": currency,
      "join_date": joinDate,
      "activation_date": activationDate,
      "activation_key": activationKey,
      "join_source": joinSource,
      "used_link_for_registration": usedLinkForRegistration,
      "sp_reg_id": spRegId,
      "device_id": deviceId,
      "w_device_id": wDeviceId,
      "w_platform": wPlatform,
      "sp_reg_code": spRegCode,
      "default_lang": defaultLang,
      "username": username,
      "encr_password": encrPassword,
      "pwd": pwd,
      "gdrive_fileid": gdriveFileid,
      "unique_deviceId": uniqueDeviceid,
      "member_status": memberStatus,
      "reselling_partner": resellingPartner,
      "coupon": coupon,
      "coup_stus": coupStus,
      "current_app_version": currentAppVersion,
      "phone_type": phoneType,
      "drive_mailId": driveMailid,
      "serverbackup_fileid": serverbackupFileid,
      "maths_trial_number": mathsTrialNumber,
      "maths_trial_status": mathsTrialStatus,
      "link_active": linkActive,
      "w_total_pts": wTotalPts,
      "w_redeemed_pts": wRedeemedPts,
      "w_balance_pts": wBalancePts,
      "cart_withdraw_pts": cartWithdrawPts,
    };
  }

  @override
  String toString() => jsonEncode(this);
}