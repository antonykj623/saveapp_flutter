import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/DTH_API_class.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/profile_entity.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
import 'Utils.dart';
import 'mobilerechargeresponse.dart';

class DthPaymentScreen extends StatefulWidget {
  Plan plan;
  String cardnumber;
  String phonenumber;
  String rechargeamount;
  String paidamount;
  String paymentmode;

  DthPaymentScreen(
    this.plan,
    this.cardnumber,
    this.phonenumber,
    this.rechargeamount,
    this.paidamount,
    this.paymentmode,
  );

  @override
  _DthPaymentScreenState createState() => _DthPaymentScreenState(
    this.plan,
    this.cardnumber,
    this.phonenumber,
    this.rechargeamount,
    this.paidamount,
    this.paymentmode,
  );
}

class _DthPaymentScreenState extends State<DthPaymentScreen> {
  Plan plan;
  String cardnumber;
  String phonenumber;
  String rechargeamount;
  String paidamount;
  String paymentmode;
  String resulturl =
      "https://mysaveapp.com/easyrecharge/paymentgateway/result.php";

  WeiplCheckoutFlutter wlCheckoutFlutter = WeiplCheckoutFlutter();
  _DthPaymentScreenState(
    this.plan,
    this.cardnumber,
    this.phonenumber,
    this.rechargeamount,
    this.paidamount,
    this.paymentmode,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileByPhoneNumber();
    wlCheckoutFlutter.on(WeiplCheckoutFlutter.wlResponse, handleResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back, color: Colors.black),

          onTap: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Payment",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),

      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> handleResponse(dynamic response) async {
    //  ResponsiveInfo.showAlertDialog(context, "Response", response.toString());
    print(response);
    List<String> parts = response['msg']!.split('|');
    String statusCode = parts[0]; // 0300
    String statusMessage = parts[1]; // SUCCESS
    String description = parts[2]; // Verification SUCCESS Transaction
    String transactionId = parts[3]; // 1234567
    String orderId = parts[4]; // 33570
    String customerId = parts[5]; // 669013977
    String amount = parts[6]; // 1.00
    String txnDateTime = parts[8]; // 27-06-2025 12:50:34
    String uuid = parts[14]; // 607369e3-68fe-4f9b-b3a4-fe0a2e7fd5a3
    String hashValue = parts[15]; // Long hash string
    String merchantCode = response['merchant_code'] ?? '';
    String transactiondetails =
        "Transaction ID : " +
        transactionId +
        "\n" +
        "Order ID : " +
        orderId +
        "\nCustomer ID : " +
        customerId +
        "\n" +
        "Transaction Date : " +
        txnDateTime +
        "\nmessage : " +
        statusMessage;

    String paymentstatus = "4";

    if (statusCode.compareTo("0300") == 0) {
      if (statusMessage.compareTo("SUCCESS") == 0) {
        paymentstatus = "5";

        // For success
        // showOrderDialog(context, true, "Your order  placed successfully!");
      } else {
        paymentstatus = "6";
      }
    } else {
      paymentstatus = "6";
    }

    String msg1 = "";

    if (paymentstatus.compareTo("5") == 0) {
      msg1 = "Your transaction is successful";
    } else {
      msg1 = "Transaction failed";
    }

    Map<String, String> params = new HashMap();
    params["transaction_amount"] = amount;
    params["paymentstatus"] = paymentstatus;
    params["order_id"] = transactionId;
    params["msg"] = msg1;
    params["timestamp"] = new DateTime.now().microsecondsSinceEpoch.toString();

    String url1 =
        "https://mysaveapp.com/easyrecharge/updatePaymentdetailsToRecharge.php?timestamp=" +
        new DateTime.now().microsecondsSinceEpoch.toString();

    ApiHelper1 apiHelper = new ApiHelper1();

    String responsedata = await apiHelper.postApiResponse(url1, params);

    Map a = jsonDecode(responsedata);
    String urltoLoad = a["urltoLoad"];

    loadResult(urltoLoad, transactionId);
  }

  loadResult(String url1, String transactionId) async {
    if (url1.contains(resulturl)) {
      getResponseFromPayment(url1, transactionId);
    } else {
      ApiHelper1 apiHelper = new ApiHelper1();

      String response = await apiHelper.getApiResponse(url1);

      Map jsonObject = jsonDecode(response);

      String urltoLoad = jsonObject["urltoLoad"];

      getResponseFromPayment(urltoLoad, transactionId);
    }
  }

  void getResponseFromPayment(String urlData, String transactionId) {
    if (urlData.contains(
      "https://mysaveapp.com/easyrecharge/paymentgateway/result.php?message=Payment Failed",
    )) {
      _showNotification("Payment process failed..", "Recharge");

      // Navigate to dashboard page

      Navigator.pop(context);
    } else {
      List<String> data = urlData.split("=");

      if (data.isNotEmpty) {
        String res = data[1];

        if (res.isNotEmpty) {
          if (res.contains("Recharge Amount mismatch")) {
            _updateRechargeStatus("", "", "0", transactionId);
            _showNotification(
              "Recharge process failed..",
              "Recharge Amount mismatch",
            );
          } else {
            String s = res;

            // Parse response JSON
            MobileRechargeResponse mobileRechargeResponse =
                MobileRechargeResponse.fromJson(jsonDecode(s));

            String msg = mobileRechargeResponse.msg;
            String status = mobileRechargeResponse.status.toString();

            if (status == "2") {
              _showNotification(
                "Successfully completed your recharge..\n$msg",
                "Recharge",
              );

              _updateRechargeStatus(
                mobileRechargeResponse.rpid,
                mobileRechargeResponse.agentid,
                "1",
                transactionId,
              );
            } else if (status == "1") {
              _showNotification(
                "Recharge process is pending. Please go back to recharge dashboard and retry again",
                "Recharge",
              );

              _updateRechargeStatus(
                mobileRechargeResponse.rpid,
                mobileRechargeResponse.agentid,
                "2",
                transactionId,
              );
            } else {
              _updateRechargeStatus(
                mobileRechargeResponse.rpid,
                mobileRechargeResponse.agentid,
                "0",
                transactionId,
              );

              _showNotification("Recharge process failed.. $msg", "Recharge");
            }
          }
        }
      }
    }
  }

  /// Stub method for updating recharge status
  Future<void> _updateRechargeStatus(
    String rpid,
    String agentid,
    String status,
    String transactionId,
  ) async {
    // TODO: Implement API call or DB update
    debugPrint(
      "Update Recharge Status: rpid=$rpid agentid=$agentid status=$status",
    );

    Map<String, String> params = {
      "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
      "status": status,
      "id": transactionId,
      "rp_id": rpid,
      "agent_id": agentid,
    };

    if (status.toLowerCase() == "1") {
      params["genstatus"] = "1";
    } else {
      params["genstatus"] = "0";
    }

    String urldata =
        "https://mysaving.in/IntegraAccount/api/updateRechargeStatus.php?timestamp=" +
        DateTime.now().microsecondsSinceEpoch.toString();

    ApiHelper1 apiHelper = new ApiHelper1();
    String responsedata = await apiHelper.postApiResponse(urldata, params);

    final Map<String, dynamic> jsonObject = jsonDecode(responsedata);

    if (jsonObject["status"] == 1) {
      String msg = jsonObject["message"];
      updateGenStatus(transactionId);
    } else {
      // handle else case
    }
  }

  Future<void> updateGenStatus(String transactionId) async {
    // Your logic here
    print("Gen status updated!");

    Map<String, String> params = {
      "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
      "id": transactionId, // renamed to follow Dart naming convention
    };

    String urldata =
        "https://mysaving.in/IntegraAccount/api/updateRechargeStatusRetry.php?timestamp=" +
        DateTime.now().microsecondsSinceEpoch.toString();

    ApiHelper1 apiHelper = new ApiHelper1();
    String responsedata = await apiHelper.postApiResponse(urldata, params);

    final Map<String, dynamic> jsonObject = jsonDecode(responsedata);

    if (jsonObject["status"] == 1) {
      String msg = jsonObject["message"];
      Navigator.pop(context);
      // updateGenStatus(transactionId);
    } else {
      // handle else case
      Navigator.pop(context);
    }
  }

  /// Stub method for showing notification
  void _showNotification(String message, String title) {
    // For now using SnackBar, you can replace with local notifications
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$title: $message")));
  }

  getProfileByPhoneNumber() async {
    // String urldata="https://mysaving.in/IntegraAccount/api/getUserByMobile.php?mobile=9747497967";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiHelper1.showLoaderDialog(context);
    });

    ApiHelper1 apiHelper = new ApiHelper1();

    // String response=await apiHelper.getApiResponse(urldata);
    String response = await apiHelper.postApiResponse(
      "https://mysaving.in/IntegraAccount/api/getUserDetails.php",
      {},
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });

    ProfileEntity entity = ProfileEntity.fromJson(jsonDecode(response));

    if (entity.status == 1) {
      Map<String, String> params = {
        "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
        "user_id": entity.data!.id.toString(),
        "mobile_number": entity.data!.mobile.toString(),
        "account_number": cardnumber,
        "transaction_id": "",
        "operatorcircle": "",
        "amount": paidamount,
        "rechargeamount": rechargeamount,
        "operator": plan.name,
        "rp_id": "",
        "agent_id": "",
        "status": "2",
        "recharge_type": "2",
        "spkey": plan.spKey,
        "payment_status": "4",
        "Payment_Mode": paymentmode,
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ApiHelper1.showLoaderDialog(context);
      });

      ApiHelper1 apiHelper = new ApiHelper1();

      String urldata1 =
          "https://mysaving.in/IntegraAccount/api/PostTransactionata.php";

      String response1 = await apiHelper.postApiResponse(urldata1, params);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });

      print(response1);

      Map jsonObject = jsonDecode(response1);

      String msg = jsonObject["message"];
      String id_transaction = jsonObject["id"].toString();

      goToPaymentSection(
        id_transaction,
        entity.data!.emailId.toString(),
        entity.data!.mobile.toString(),
        rechargeamount,
      );
    }
  }

  goToPaymentSection(
    String transactionid,
    String email,
    String phone,
    String amount,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiHelper1.showLoaderDialog(context);
    });

    ApiHelper1 apiHelper = new ApiHelper1();

    String urldata1 =
        "https://mysaving.in/IntegraAccount/ecommerce_api/getPaymentCredentials.php";

    String response1 = await apiHelper.postApiResponse(urldata1, {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });

    Map data1 = jsonDecode(response1);

    String customerid = data1["customerid"];
    String merchantcode = data1["merchantcode"];
    String salt = data1["saltkey"];
    String txnid = transactionid; // Assuming idTransaction is defined

    String a =
        merchantcode +
        "|" +
        txnid +
        "|" +
        amount +
        "||" +
        customerid +
        "|" +
        phone +
        "|" +
        email +
        "||||||||||" +
        salt;

    String methode =
        "https://mysaveapp.com/generateHash.php?timestamp=" +
        new DateTime.now().microsecondsSinceEpoch.toString();

    String responsedata = await apiHelper.postApiResponse(methode, {"data": a});

    Map js = jsonDecode(responsedata);

    // int status = jsonObject.getInt("status");
    String value = js["value"];

    var reqJson = {
      "features": {
        "enableAbortResponse": true,
        "enableExpressPay": true,
        "enableInstrumentDeRegistration": true,
        "enableMerTxnDetails": true,
      },
      "consumerData": {
        "deviceId": "AndroidSH2",
        "token": value,
        "paymentMode": "all",
        "merchantLogoUrl": "https://mysaveapp.com/ic_launcher.png",
        "merchantId": merchantcode,
        "currency": "INR",
        "consumerId": customerid,
        "consumerMobileNo": phone,
        "consumerEmailId": email,
        "txnId": txnid, //Unique merchant transaction ID
        "items": [
          {"itemId": "first", "amount": paidamount, "comAmt": "0"},
        ],
        "customStyle": {
          "PRIMARY_COLOR_CODE": "#0B7D97", //merchant primary color code
          "SECONDARY_COLOR_CODE":
              "#FFFFFF", //provide merchant's suitable color code
          "BUTTON_COLOR_CODE_1":
              "#0B7D97", //merchant"s button background color code
          "BUTTON_COLOR_CODE_2":
              "#FFFFFF", //provide merchant's suitable color code for button text
        },
      },
    };

    wlCheckoutFlutter.open(reqJson);
  }
}
