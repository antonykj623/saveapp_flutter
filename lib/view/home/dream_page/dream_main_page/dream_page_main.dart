import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/dream_page/add_dream_screen/add_dream_screen.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/dream_page/view_details_screen/view_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Savings',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyDreamScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyDreamScreen extends StatefulWidget {
  @override
  _MyDreamScreenState createState() => _MyDreamScreenState();
}

class _MyDreamScreenState extends State<MyDreamScreen> {
  // List to store all dreams
  List<Dream> dreams = [
    Dream(
      name: "Hhh",
      category: "Vehicle",
      investment: "My Saving",
      closingBalance: 0.0,
      addedAmount: 5000.0,
      savedAmount: 5200.0,
      targetAmount: 25888.0,
      targetDate: DateTime(2025, 5, 29),
    ),
  ];

  void _addNewDream(Dream newDream) {
    setState(() {
      dreams.add(newDream);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('My Dream', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          dreams.isEmpty
              ? Center(
                child: Text(
                  'No dreams added yet. Add a new dream!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: dreams.length,
                itemBuilder: (context, index) {
                  final dream = dreams[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDetailsScreen(dream: dream),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 32,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  dream.category,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow('Name', dream.name),
                            _buildDetailRow('Investment', dream.investment),
                            _buildDetailRow(
                              'Saved Amount',
                              dream.savedAmount.toString(),
                            ),
                            _buildDetailRow(
                              'Target Amount',
                              dream.targetAmount.toString(),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  '${dream.progressPercentage.toStringAsFixed(2)} %',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    minHeight: 15 ,
                                    value: dream.progressPercentage / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDreamScreen(onDreamAdded: _addNewDream),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 16))),
          Text(':', style: TextStyle(fontSize: 16)),
          SizedBox(width: 16),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
