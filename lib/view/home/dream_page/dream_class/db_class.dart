import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/model/images/images.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class TargetCategoryService {
  static Future<void> addDefaultTargetCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? value = prefs.getInt("targetcategoriesadded");

    if (value == null || value == 0) {
      final DatabaseHelper _databaseHelper = DatabaseHelper();

      List<Map<String, dynamic>> defaultCategories = [
        {'name': 'Vehicle', 'imagePath': Images.car},
        {'name': 'New home', 'imagePath': Images.home},
        {'name': 'Education', 'imagePath': Images.education},
        {'name': 'Party', 'imagePath': Images.party},
      ];

      for (int i = 0; i < defaultCategories.length; i++) {
        try {
          print(defaultCategories[i]['imagePath']);
          ByteData imageData = await rootBundle.load(
            defaultCategories[i]['imagePath'],
          );
          Uint8List imageBytes = imageData.buffer.asUint8List();

          Map<String, dynamic> dbData = {
            'data': defaultCategories[i]['name'],
            'isCustom': 'false',
            'iconimage': imageBytes,
          };

          await _databaseHelper.insertData("TABLE_TARGETCATEGORY", dbData);
        } catch (e) {
          print('Error loading image for ${defaultCategories[i]['name']}: $e');
        }
      }

      await prefs.setInt('targetcategoriesadded', 1);
      print('Default target categories added successfully');
    } else {
      print('Default target categories already exist');
    }
  }
  

  static Future<List<TargetCategory>> getAllTargetCategories() async {
    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final List<Map<String, dynamic>> data = await _databaseHelper.getAllData(
      "TABLE_TARGETCATEGORY",
    );

    List<TargetCategory> categories = [];

    for (var item in data) {
      try {
        
        print(item);
        Uint8List? iconImage = item['iconimage'];

        bool isCustom = item['isCustom'] == 'true';

        TargetCategory category = TargetCategory(
          id: item['keyid'],
          name: item['data'],
          iconImage: iconImage,
          isCustom: isCustom,
        );

        categories.add(category);
      } catch (e) {
        print('Error parsing category data: $e');
      }
    }

    return categories;
  }

  static Future<bool> addCustomTargetCategory(
    String name,
    Uint8List iconImage,
  ) async {
    try {
      final DatabaseHelper _databaseHelper = DatabaseHelper();

      Map<String, dynamic> dbData = {
        'data': name,
        'isCustom': 'true',
        'iconimage': iconImage,
      };

      int result = await _databaseHelper.insertData(
        "TABLE_TARGETCATEGORY",
        dbData,
      );
      return result > 0;
    } catch (e) {
      print('Error adding custom category: $e');
      return false;
    }
  }

  static Future<bool> categoryExists(String name) async {
    final categories = await getAllTargetCategories();
    return categories.any(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    );
  }

  static Future<bool> deleteTargetCategory(int categoryId) async {
    try {
      final DatabaseHelper _databaseHelper = DatabaseHelper();
      int result = await _databaseHelper.deleteData(
        "TABLE_TARGETCATEGORY",
        categoryId,
      );
      return result > 0;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  static Future<void> resetTargetCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetcategoriesadded', 0);

    final DatabaseHelper _databaseHelper = DatabaseHelper();
    final categories = await getAllTargetCategories();
    for (var category in categories) {
      if (category.id != null) {
        await _databaseHelper.deleteData("TABLE_TARGETCATEGORY", category.id!);
      }
    }

    await addDefaultTargetCategories();
  }
}
