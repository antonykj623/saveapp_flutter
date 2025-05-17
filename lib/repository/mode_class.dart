/// YApi QuickType插件生成，具体参考文档:https://plugins.jetbrains.com/plugin/18847-yapi-quicktype/documentation

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    Profile({
        required this.data,
        required this.message,
        required this.status,
    });

    Data data;
    String message;
    int status;

    factory Profile.fromJson(Map<dynamic, dynamic> json) => Profile(
        data: Data.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "data": data.toJson(),
        "message": message,
        "status": status,
    };
}

class Data {
    Data({
        required this.emailId,
        required this.wTotalPts,
        required this.uniqueDeviceId,
        required this.mathsTrialNumber,
        required this.activationDate,
        required this.wDeviceId,
        required this.joinSource,
        required this.spRegCode,
        required this.wRedeemedPts,
        required this.profileImage,
        required this.activationKey,
        required this.linkActive,
        required this.defaultLang,
        required this.memberStatus,
        required this.coupStus,
        required this.mathsTrialStatus,
        required this.currency,
        required this.id,
        required this.stateId,
        required this.phoneType,
        required this.deviceId,
        required this.coupon,
        required this.currentAppVersion,
        required this.joinDate,
        required this.mobile,
        required this.resellingPartner,
        required this.spRegId,
        required this.driveMailId,
        required this.fullName,
        required this.encrPassword,
        required this.wBalancePts,
        required this.wPlatform,
        required this.serverbackupFileid,
        required this.countryId,
        required this.gdriveFileid,
        required this.regCode,
        required this.usedLinkForRegistration,
        required this.username,
    });

    String emailId;
    String wTotalPts;
    String uniqueDeviceId;
    String mathsTrialNumber;
    DateTime activationDate;
    String wDeviceId;
    String joinSource;
    String spRegCode;
    String wRedeemedPts;
    String profileImage;
    String activationKey;
    String linkActive;
    String defaultLang;
    String memberStatus;
    String coupStus;
    String mathsTrialStatus;
    String currency;
    String id;
    String stateId;
    String phoneType;
    String deviceId;
    String coupon;
    String currentAppVersion;
    DateTime joinDate;
    String mobile;
    String resellingPartner;
    String spRegId;
    String driveMailId;
    String fullName;
    String encrPassword;
    String wBalancePts;
    String wPlatform;
    String serverbackupFileid;
    String countryId;
    String gdriveFileid;
    String regCode;
    String usedLinkForRegistration;
    String username;

    factory Data.fromJson(Map<dynamic, dynamic> json) => Data(
        emailId: json["email_id"],
        wTotalPts: json["w_total_pts"],
        uniqueDeviceId: json["unique_deviceId"],
        mathsTrialNumber: json["maths_trial_number"],
        activationDate: DateTime.parse(json["activation_date"]),
        wDeviceId: json["w_device_id"],
        joinSource: json["join_source"],
        spRegCode: json["sp_reg_code"],
        wRedeemedPts: json["w_redeemed_pts"],
        profileImage: json["profile_image"],
        activationKey: json["activation_key"],
        linkActive: json["link_active"],
        defaultLang: json["default_lang"],
        memberStatus: json["member_status"],
        coupStus: json["coup_stus"],
        mathsTrialStatus: json["maths_trial_status"],
        currency: json["currency"],
        id: json["id"],
        stateId: json["state_id"],
        phoneType: json["phone_type"],
        deviceId: json["device_id"],
        coupon: json["coupon"],
        currentAppVersion: json["current_app_version"],
        joinDate: DateTime.parse(json["join_date"]),
        mobile: json["mobile"],
        resellingPartner: json["reselling_partner"],
        spRegId: json["sp_reg_id"],
        driveMailId: json["drive_mailId"],
        fullName: json["full_name"],
        encrPassword: json["encr_password"],
        wBalancePts: json["w_balance_pts"],
        wPlatform: json["w_platform"],
        serverbackupFileid: json["serverbackup_fileid"],
        countryId: json["country_id"],
        gdriveFileid: json["gdrive_fileid"],
        regCode: json["reg_code"],
        usedLinkForRegistration: json["used_link_for_registration"],
        username: json["username"],
    );

    Map<dynamic, dynamic> toJson() => {
        "email_id": emailId,
        "w_total_pts": wTotalPts,
        "unique_deviceId": uniqueDeviceId,
        "maths_trial_number": mathsTrialNumber,
        "activation_date": activationDate.toIso8601String(),
        "w_device_id": wDeviceId,
        "join_source": joinSource,
        "sp_reg_code": spRegCode,
        "w_redeemed_pts": wRedeemedPts,
        "profile_image": profileImage,
        "activation_key": activationKey,
        "link_active": linkActive,
        "default_lang": defaultLang,
        "member_status": memberStatus,
        "coup_stus": coupStus,
        "maths_trial_status": mathsTrialStatus,
        "currency": currency,
        "id": id,
        "state_id": stateId,
        "phone_type": phoneType,
        "device_id": deviceId,
        "coupon": coupon,
        "current_app_version": currentAppVersion,
        "join_date": joinDate.toIso8601String(),
        "mobile": mobile,
        "reselling_partner": resellingPartner,
        "sp_reg_id": spRegId,
        "drive_mailId": driveMailId,
        "full_name": fullName,
        "encr_password": encrPassword,
        "w_balance_pts": wBalancePts,
        "w_platform": wPlatform,
        "serverbackup_fileid": serverbackupFileid,
        "country_id": countryId,
        "gdrive_fileid": gdriveFileid,
        "reg_code": regCode,
        "used_link_for_registration": usedLinkForRegistration,
        "username": username,
};
}