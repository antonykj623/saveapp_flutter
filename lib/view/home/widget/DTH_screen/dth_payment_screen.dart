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

class _DthPaymentScreenState extends State<DthPaymentScreen>
    with TickerProviderStateMixin {
  Plan plan;
  String cardnumber;
  String phonenumber;
  String rechargeamount;
  String paidamount;
  String paymentmode;
  String resulturl =
      "https://mysaveapp.com/easyrecharge/paymentgateway/result.php";

  WeiplCheckoutFlutter wlCheckoutFlutter = WeiplCheckoutFlutter();
  
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  String currentStatus = "Initializing...";
  bool isProcessing = true;
  bool showSuccess = false;
  bool showError = false;

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
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    getProfileByPhoneNumber(); 
    wlCheckoutFlutter.on(WeiplCheckoutFlutter.wlResponse, handleResponse);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF8360c3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(),

              // Main Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Payment Details Card
                          _buildPaymentDetailsCard(),
                          
                          const SizedBox(height: 30),
                          
                          // Status Animation
                          if (isProcessing) _buildProcessingAnimation(),
                          if (showSuccess) _buildSuccessAnimation(),
                          if (showError) _buildErrorAnimation(),
                          
                          const SizedBox(height: 30),
                          
                          // Status Text
                          _buildStatusText(),
                          
                          const SizedBox(height: 40),
                          
                          // Action Buttons (if needed)
                          if (!isProcessing) _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Processing",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Secure Transaction",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.tv,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "DTH Recharge",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[200],
          ),
          
          const SizedBox(height: 24),
          
          // Payment Details
          _buildDetailRow("Card Number", cardnumber),
          const SizedBox(height: 16),
          _buildDetailRow("Phone Number", phonenumber),
          const SizedBox(height: 16),
          _buildDetailRow("Recharge Amount", "₹$rechargeamount"),
          const SizedBox(height: 16),
          _buildDetailRow("Total Amount", "₹$paidamount"),
          const SizedBox(height: 16),
          _buildDetailRow("Payment Method", paymentmode),
          
          const SizedBox(height: 24),
          
          // Total Amount Highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Payable",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "₹$paidamount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 6.28,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        Color(0xFF8360c3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hourglass_empty,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorAnimation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5252).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    Color statusColor = isProcessing 
        ? const Color(0xFF667eea) 
        : showSuccess 
            ? const Color(0xFF4CAF50) 
            : const Color(0xFFFF5252);

    return Column(
      children: [
        Text(
          currentStatus,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isProcessing 
              ? "Please wait while we process your payment..."
              : showSuccess
                  ? "Your DTH recharge has been completed successfully!"
                  : "There was an issue processing your payment.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (showSuccess) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Back to Home",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (showError) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isProcessing = true;
                  showError = false;
                  currentStatus = "Retrying...";
                });
                _pulseController.repeat(reverse: true);
                _rotateController.repeat();
                // Retry payment logic here
                getProfileByPhoneNumber();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Retry Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Future<void> handleResponse(dynamic response) async {
    _pulseController.stop();
    _rotateController.stop();
    
    setState(() {
      isProcessing = false;
      currentStatus = "Processing Response...";
    });

    try {
      print(response);
      List<String> parts = response['msg']!.split('|');
      String statusCode = parts[0];
      String statusMessage = parts[1];
      String description = parts[2];
      String transactionId = parts[3];
      String orderId = parts[4];
      String customerId = parts[5];
      String amount = parts[6];
      String txnDateTime = parts[8];
      String uuid = parts[14];
      String hashValue = parts[15];
      String merchantCode = response['merchant_code'] ?? '';

      String paymentstatus = "4";

      if (statusCode.compareTo("0300") == 0) {
        if (statusMessage.compareTo("SUCCESS") == 0) {
          paymentstatus = "5";
          setState(() {
            showSuccess = true;
            currentStatus = "Payment Successful!";
          });
        } else {
          paymentstatus = "6";
          setState(() {
            showError = true;
            currentStatus = "Payment Failed";
          });
        }
      } else {
        paymentstatus = "6";
        setState(() {
          showError = true;
          currentStatus = "Payment Failed";
        });
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
    } catch (e) {
      setState(() {
        showError = true;
        currentStatus = "Error Processing Payment";
      });
      _showNotification("Error processing payment: $e", "Error");
    }
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
      setState(() {
        showError = true;
        currentStatus = "Payment Failed";
      });
      _showNotification("Payment process failed..", "Recharge");
    } else {
      List<String> data = urlData.split("=");

      if (data.isNotEmpty) {
        String res = data[1];

        if (res.isNotEmpty) {
          if (res.contains("Recharge Amount mismatch")) {
            _updateRechargeStatus("", "", "0", transactionId);
            setState(() {
              showError = true;
              currentStatus = "Amount Mismatch";
            });
            _showNotification(
              "Recharge process failed..",
              "Recharge Amount mismatch",
            );
          } else {
            String s = res;

            MobileRechargeResponse mobileRechargeResponse =
                MobileRechargeResponse.fromJson(jsonDecode(s));

            String msg = mobileRechargeResponse.msg;
            String status = mobileRechargeResponse.status.toString();

            if (status == "2") {
              setState(() {
                showSuccess = true;
                currentStatus = "Recharge Successful!";
              });
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
              setState(() {
                showError = true;
                currentStatus = "Recharge Pending";
              });
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
              setState(() {
                showError = true;
                currentStatus = "Recharge Failed";
              });
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

  Future<void> _updateRechargeStatus(
    String rpid,
    String agentid,
    String status,
    String transactionId,
  ) async {
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
    }
  }

  Future<void> updateGenStatus(String transactionId) async {
    print("Gen status updated!");

    Map<String, String> params = {
      "timestamp": DateTime.now().microsecondsSinceEpoch.toString(),
      "id": transactionId,
    };

    String urldata =
        "https://mysaving.in/IntegraAccount/api/updateRechargeStatusRetry.php?timestamp=" +
            DateTime.now().microsecondsSinceEpoch.toString();

    ApiHelper1 apiHelper = new ApiHelper1();
    String responsedata = await apiHelper.postApiResponse(urldata, params);

    final Map<String, dynamic> jsonObject = jsonDecode(responsedata);

    if (jsonObject["status"] == 1) {
      String msg = jsonObject["message"];
    }
  }

  void _showNotification(String message, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              showSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$title: $message",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: showSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  getProfileByPhoneNumber() async {
    setState(() {
      currentStatus = "Verifying user details...";
    });

    try {
      ApiHelper1 apiHelper = new ApiHelper1();
      String response = await apiHelper.postApiResponse(
        "https://mysaving.in/IntegraAccount/api/getUserDetails.php",
        {},
      );

      ProfileEntity entity = ProfileEntity.fromJson(jsonDecode(response));

      if (entity.status == 1) {
        setState(() {
          currentStatus = "Creating transaction...";
        });

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

        String urldata1 =
            "https://mysaving.in/IntegraAccount/api/PostTransactionata.php";

        String response1 = await apiHelper.postApiResponse(urldata1, params);

        print(response1);

        Map jsonObject = jsonDecode(response1);
        String msg = jsonObject["message"];
        String id_transaction = jsonObject["id"].toString();

        setState(() {
          currentStatus = "Initializing payment gateway...";
        });

        goToPaymentSection(
          id_transaction,
          entity.data!.emailId.toString(),
          entity.data!.mobile.toString(),
          rechargeamount,
        );
      } else {
        setState(() {
          showError = true;
          currentStatus = "User Verification Failed";
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        showError = true;
        currentStatus = "Error: ${e.toString()}";
        isProcessing = false;
      });
    }
  }

  goToPaymentSection(
    String transactionid,
    String email,
    String phone,
    String amount,
  ) async {
    setState(() {
      currentStatus = "Setting up secure payment...";
    });

    try {
      ApiHelper1 apiHelper = new ApiHelper1();

      String urldata1 =
          "https://mysaving.in/IntegraAccount/ecommerce_api/getPaymentCredentials.php";

      String response1 = await apiHelper.postApiResponse(urldata1, {});

      Map data1 = jsonDecode(response1);

      String customerid = data1["customerid"];
      String merchantcode = data1["merchantcode"];
      String salt = data1["saltkey"];
      String txnid = transactionid;

      String a = merchantcode +
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

      String methode = "https://mysaveapp.com/generateHash.php?timestamp=" +
          new DateTime.now().microsecondsSinceEpoch.toString();

      String responsedata =
          await apiHelper.postApiResponse(methode, {"data": a});

      Map js = jsonDecode(responsedata);
      String value = js["value"];

      setState(() {
        currentStatus = "Opening payment gateway...";
      });

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
          "txnId": txnid,
          "items": [
            {"itemId": "first", "amount": paidamount, "comAmt": "0"},
          ],
          "customStyle": {
            "PRIMARY_COLOR_CODE": "#0B7D97",
            "SECONDARY_COLOR_CODE": "#FFFFFF",
            "BUTTON_COLOR_CODE_1": "#0B7D97",
            "BUTTON_COLOR_CODE_2": "#FFFFFF",
          },
        },
      };

      wlCheckoutFlutter.open(reqJson);
    } catch (e) {
      setState(() {
        showError = true;
        currentStatus = "Payment Setup Failed";
        isProcessing = false;
      });
      _showNotification("Error setting up payment: $e", "Error");
    }  
  }
}