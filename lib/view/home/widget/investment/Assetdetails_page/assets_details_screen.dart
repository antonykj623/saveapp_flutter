import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/investment/assetform_screen/asset_form_screen.dart';
import 'package:new_project_2025/view/home/widget/investment/data_base/Investment_data%20base.dart';
import 'package:new_project_2025/view/home/widget/investment/model_class1/model_class.dart';

class AssetDetailScreen extends StatefulWidget {
  final Investment investment;

  const AssetDetailScreen({Key? key, required this.investment}) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset', style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D7A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Account Name', style: TextStyle(fontSize: 16)),
                        const Text(':', style: TextStyle(fontSize: 16)),
                        Text(widget.investment.accountName, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount', style: TextStyle(fontSize: 16)),
                        const Text(':', style: TextStyle(fontSize: 16)),
                        Text('${widget.investment.amount}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssetFormScreen(investment: widget.investment),
                              ),
                            ).then((result) {
                              if (result == true) {
                                Navigator.pop(context, true);
                              }
                            });
                          },
                          child: const Text('Edit', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: () {
                            _showDeleteDialog();
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssetFormScreen()),
          );
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Asset'),
          content: const Text('Are you sure you want to delete this asset?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseHelper.deleteInvestment(widget.investment.id!);
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}