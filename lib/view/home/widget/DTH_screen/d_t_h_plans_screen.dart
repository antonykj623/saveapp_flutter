import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/DTH_API_class.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/dth_payment_screen.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/pack_list_entity.dart';

import 'Utils.dart';

class DTHPlansScreen extends StatefulWidget {
  Plan plan;

  DTHPlansScreen(this.plan);

  @override
  _DTHPlansScreenState createState() => _DTHPlansScreenState(this.plan);
}

class _DTHPlansScreenState extends State<DTHPlansScreen> {
  Plan plan;
  String selectedtype = "COMBO";
  List<String> arr_type = ["COMBO", "BROADCASTER", "ADDON"];

  List<PackListPacks> packs = [];

  final TextEditingController searchController = TextEditingController();

  _DTHPlansScreenState(this.plan);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getDTHPlans(selectedtype);
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
          plan.name + " " + " Plans",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedtype,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items:
                ["COMBO", "BASE", "ADDON"].map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedtype = value!;
              });

              getDTHPlans(selectedtype);
            },
          ),
          const SizedBox(height: 10),

          // Search Box
          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {}); // re-build UI when searching
            },
            decoration: InputDecoration(
              hintText: "Search by amount or name...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),

          // Packs List
          Expanded(
            child: ListView(
              children:
                  packs
                      .where(
                        (pack) =>
                            pack.name.toString().toLowerCase().contains(
                              searchController.text.toLowerCase(),
                            ) ||
                            pack.prices!.any(
                              (p) => p.amount.toString().contains(
                                searchController.text,
                              ),
                            ),
                      )
                      .map((pack) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pack.name.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children:
                                  pack.prices!.map((p) {
                                    return Expanded(
                                      child: GestureDetector(
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 6,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  p.amount.toString(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(p.validity.toString()),
                                              ],
                                            ),
                                          ),
                                        ),

                                        onTap: () {
                                          showCardDialog(p.amount.toString());
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      })
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void showCardDialog(String amount) {
    final TextEditingController cardController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String card = cardController.text;
                String phone = phoneController.text;

                Navigator.pop(context);

                showPaymentTypeList(double.parse(amount), card, phone);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Card: $card, Phone: $phone")),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  showPaymentTypeList(double amount, String cardnumber, String mobilenumber) {
    List<String> arr = [
      "UPI (no convenience charges)",
      "NET Banking (payment gateway charge @1.5% application)",
      "Debit Card (payment gateway charge @0.4% application)",
      "Credit card (payment gateway charge @2.1% application)",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Payment Option"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: arr.length,
              itemBuilder: (context, index) {
                double amount1 = 0;
                String paymentmode = "";

                if (index == 0) {
                  amount1 = amount;
                  paymentmode = "upi";
                } else if (index == 1) {
                  amount1 = amount + (amount * 1.5 / 100);
                  paymentmode = "Net banking";
                } else if (index == 2) {
                  amount1 = amount + (amount * 0.4 / 100);
                  paymentmode = "Debit Card";
                } else if (index == 3) {
                  amount1 = amount + (amount * 2.1 / 100);
                  paymentmode = "Credit Card";
                }

                return ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text(arr[index] + "\n" + amount1.toString()),
                  onTap: () {
                    Navigator.pop(context, arr[index]);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Selected: ${arr[index]}")),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DthPaymentScreen(
                              plan,
                              cardnumber,
                              mobilenumber,
                              amount.toString(),
                              amount1.toString(),
                              paymentmode,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  getDTHPlans(String type) async {
    String urldata =
        "https://mysaveapp.com/easyrecharge/newrecharge/DTHplans.php?timestamp=" +
        DateTime.now().microsecondsSinceEpoch.toString() +
        "&operatorcode=" +
        plan.opcode +
        "&type=" +
        type;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ApiHelper1.showLoaderDialog(context);
    });

    ApiHelper1 apiHelper = new ApiHelper1();

    String response = await apiHelper.getApiResponse(urldata);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });

    PackListEntity packListEntity = PackListEntity.fromJson(
      jsonDecode(response),
    );

    if (packListEntity.status.toString().compareTo("OK") == 0) {
      setState(() {
        packs.clear();
        packs.addAll(packListEntity.packs!);
      });
    }
  }
}
