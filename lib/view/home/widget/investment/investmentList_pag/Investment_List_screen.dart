import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/investment/Assetdetails_page/assets_details_screen.dart';
import 'package:new_project_2025/view/home/widget/investment/assetform_screen/asset_form_screen.dart';
import 'package:new_project_2025/view/home/widget/investment/model_class1/model_class.dart';

class InvestmentListScreen extends StatefulWidget {
  const InvestmentListScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentListScreen> createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends State<InvestmentListScreen> {
  List<InvestmentAsset> _investments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading with sample data (no database)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _investments = [
        InvestmentAsset(
          id: 1,
          accountName: 'Estate',
          amount: 50000.0,
          dateOfPurchase: DateTime(2024, 1, 15),
          remarks: 'Initial investment',
          reminderDates: [],
        ),
        InvestmentAsset(
          id: 2,
          accountName: 'Stocks',
          amount: 25000.0,
          dateOfPurchase: DateTime(2024, 2, 20),
          remarks: 'Technology stocks',
          reminderDates: [],
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D7A),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _investments.isEmpty
                ? const Center(
                  child: Text(
                    'No investments found.\nTap + to add your first investment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _investments.length,
                  itemBuilder: (context, index) {
                    final investment = _investments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            investment.accountName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Amount: ${investment.amount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              if (investment.dateOfPurchase != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Purchase Date: ${investment.dateOfPurchase!.toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AssetDetailScreen(
                               
                                    ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _loadInvestments();
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssetFormScreen()),
          ).then((result) {
            if (result == true) {
              _loadInvestments();
            }
          });
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
