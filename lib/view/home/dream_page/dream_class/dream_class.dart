// import 'package:sqflite/sqflite.dart';

// class Dream {
//   final String name;
//   final String category;
//   final String investment;
//   final double targetAmount;
//   final double savedAmount;
//   final DateTime targetDate;
//   final String notes;

//   Dream({
//     required this.name,
//     required this.category,
//     required this.investment,
//     required this.targetAmount,
//     required this.savedAmount,
//     required this.targetDate,
//     required this.notes,
//   });
// }
// Future<void> _onCreate(Database db, int version) async {
//   // ... (Existing table creations)

//   // Insert default target categories (example without images)
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Vehicle'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'New home'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Education'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Emergency'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Healthcare'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Party'});
//   await db.insert('TABLE_TARGETCATEGORY', {'data': 'Charity'});
// }
