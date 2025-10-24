import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/dream_page/add_dream_screen/add_dream_screen.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/dream_page/view_details_screen/view_details_screen.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';

import '../../widget/save_DB/Budegt_database_helper/Save_DB.dart';

class MyDreamScreen extends StatefulWidget {
  @override
  _MyDreamScreenState createState() => _MyDreamScreenState();
}

class _MyDreamScreenState extends State<MyDreamScreen> {
  List<Dream> dreams = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TargetCategory> targetCategories = []; // Add this

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadTargetCategories(); // Load categories first
    await _loadDreams();
  }

  Future<void> _loadTargetCategories() async {
    try {
      final categories = await TargetCategoryService.getAllTargetCategories();
      setState(() {
        targetCategories = categories;
      });
    } catch (e) {
      print('Error loading target categories: $e');
    }
  }

  Future<void> _loadDreams() async {
    try {
      final loadedDreams = await _dbHelper.getAllDreams();
      if (loadedDreams.isEmpty) {
        final defaultDream = Dream(
          name: "Hhh",
          category: "Vehicle",
          investment: "My Saving",
          closingBalance: 0.0,
          addedAmount: 5000.0,
          savedAmount: 5200.0,
          targetAmount: 25888.0,
          targetDate: DateTime(2025, 5, 29),
          notes: "",
        );
        await _dbHelper.insertDream(defaultDream);
        loadedDreams.add(defaultDream);
      }

      setState(() {
        dreams = loadedDreams;
      });
    } catch (e) {
      print('Error loading dreams: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load dreams: $e')));
    }
  }

  void _addNewDream(Dream newDream) async {
    try {
      await _dbHelper.insertDream(newDream);
      setState(() {
        dreams.add(newDream);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dream added successfully!')));
    } catch (e) {
      print('Error adding new dream: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add dream: $e')));
    }
  }

  // NEW METHOD: Get category icon for a dream
  Widget _getCategoryIcon(String categoryName) {
    try {
      final category = targetCategories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => throw Exception('Category not found'),
      );

      // All categories (default and custom) use stored images
      if (category.iconImage != null && category.iconImage!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            category.iconImage!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                size: 32,
                color: Colors.grey[400],
              );
            },
          ),
        );
      } else {
        // Fallback if image is missing
        return Icon(Icons.category, size: 32, color: Colors.grey[400]);
      }
    } catch (e) {
      print('Error getting category icon for $categoryName: $e');
      // Fallback icon if category not found
      return Icon(Icons.help_outline, size: 32, color: Colors.grey[400]);
    }
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
                                // FIXED: Use dynamic category icon
                                _getCategoryIcon(dream.category),
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
                              dream.savedAmount.toStringAsFixed(2),
                            ),
                            _buildDetailRow(
                              'Target Amount',
                              dream.targetAmount.toStringAsFixed(2),
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
                                    minHeight: 15,
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
