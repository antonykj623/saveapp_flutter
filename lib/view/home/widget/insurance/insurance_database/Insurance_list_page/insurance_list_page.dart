import 'package:flutter/material.dart';
import 'package:new_project_2025/model/insurance.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/insurance_database.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/insurance_entery_page/Insurance_entry_page.dart';

class InsuranceListPage extends StatefulWidget {
  const InsuranceListPage({Key? key}) : super(key: key);

  @override
  State<InsuranceListPage> createState() => _InsuranceListPageState();
}

class _InsuranceListPageState extends State<InsuranceListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Insurance> _insurances = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInsurances();
  }

  Future<void> _loadInsurances() async {
    final insurances = await _databaseHelper.getInsurances();
    final total = await _databaseHelper.getTotalAmount();
    setState(() {
      _insurances = insurances;
      _totalAmount = total;
    });
  }

  Future<void> _deleteInsurance(int id) async {
    await _databaseHelper.deleteInsurance(id);
    _loadInsurances();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insurance deleted successfully')),
    );
  }

  void _showDeleteDialog(Insurance insurance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Insurance'),
          content: Text(
            'Are you sure you want to delete ${insurance.accountName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteInsurance(insurance.id!);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Insurance', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF607D8B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _insurances.isEmpty
                    ? const Center(
                      child: Text(
                        'No insurance records found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _insurances.length,
                      itemBuilder: (context, index) {
                        final insurance = _insurances[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Account Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(' : '),
                                    Text(insurance.accountName),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(' : '),
                                    Text(insurance.amount.toString()),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => InsuranceEntryPage(
                                                  insurance: insurance,
                                                ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadInsurances();
                                        }
                                      },
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    TextButton(
                                      onPressed:
                                          () => _showDeleteDialog(insurance),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total : $_totalAmount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InsuranceEntryPage()),
          );
          if (result == true) {
            _loadInsurances();
          }
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
