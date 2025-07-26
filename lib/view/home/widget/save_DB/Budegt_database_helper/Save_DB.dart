import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/model_class_emergency.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/model/receipt.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'save.db');
    return await openDatabase(
      path,
      version: 3, // Updated version to handle new schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TABLE_EMERGENCY_CONTACTS (
          keyid INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Update carousel image table structure
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TABLE_CAROUSEL_IMAGES (
          keyid INTEGER PRIMARY KEY AUTOINCREMENT,
          visitcard_id INTEGER,
          image_data BLOB,
          image_order INTEGER,
          is_selected INTEGER DEFAULT 0,
          FOREIGN KEY (visitcard_id) REFERENCES TABLE_VISITCARD (keyid)
        )
      ''');

      // Update visiting card table structure
      await db.execute('''
        ALTER TABLE TABLE_VISITCARD ADD COLUMN parsed_data TEXT
      ''');

      // Insert default carousel images
      await _insertDefaultCarouselImages(db);
    }
  }

  Future<void> _insertDefaultCarouselImages(Database db) async {
    // Insert default background images (these would be asset paths)
    List<String> defaultImages = [
      "assets/1.jpg",
      "assets/2.jpg",
      "assets/3.jpg",
    ];

    for (int i = 0; i < defaultImages.length; i++) {
      await db.insert('TABLE_CAROUSEL_IMAGES', {
        'visitcard_id':
            null, // These are default images not tied to specific cards
        'image_data':
            null, // For asset images, we store path in separate field if needed
        'image_order': i,
        'is_selected': 0,
      });
    }
  }

  Future<void> _createAllTables(Database db) async {
    // All existing tables...
    await db.execute('''
      CREATE TABLE TABLE_TARGETCATEGORY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        iconimage BLOB,
        isCustom TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_PAYMENTVOUCHER (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        voucherdata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INSURANCE_NO (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        insuranceNO TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INVESTNAMES_TABLE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        investname TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE CASHBALANCE_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        cashbalancedata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE LOAN_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE RECEIPT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_DOCUMENT (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_WALLET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_PASSWORD (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    // Updated carousel images table
    await db.execute('''
      CREATE TABLE TABLE_CAROUSEL_IMAGES (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        visitcard_id INTEGER,
        image_data BLOB,
        image_order INTEGER,
        is_selected INTEGER DEFAULT 0,
        FOREIGN KEY (visitcard_id) REFERENCES TABLE_VISITCARD (keyid)
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_APP_PIN (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_MILESTONE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTS (
        ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        ACCOUNTS_VoucherType INTEGER,
        ACCOUNTS_entryid TEXT,
        ACCOUNTS_date TEXT,
        ACCOUNTS_setupid TEXT,
        ACCOUNTS_amount TEXT,
        ACCOUNTS_type TEXT,
        ACCOUNTS_remarks TEXT,
        ACCOUNTS_year TEXT,
        ACCOUNTS_month TEXT,
        ACCOUNTS_cashbanktype TEXT,
        ACCOUNTS_billId TEXT,
        ACCOUNTS_billVoucherNumber TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTS_RECEIPT (
        ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT,
        ACCOUNTS_entryid TEXT,
        ACCOUNTS_date TEXT,
        ACCOUNTS_setupid TEXT,
        ACCOUNTS_amount TEXT,
        ACCOUNTS_type TEXT,
        ACCOUNTS_remarks TEXT,
        ACCOUNTS_year TEXT,
        ACCOUNTS_month TEXT,
        ACCOUNTS_cashbanktype TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ASSET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_LIABILITY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_INSURANCE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTSETTINGS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE DIARYSUBJECT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BUDGET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        account_name TEXT,
        year INTEGER,
        month TEXT,
        amount REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE DIARY_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INVESTMENT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_TASK (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    // Updated visiting card table
    await db.execute('''
      CREATE TABLE TABLE_VISITCARD (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        parsed_data TEXT,
        logoimage BLOB,
        cardimg TEXT,
        selected_background_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_TARGET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ADDEDAMOUNT_MILESTONE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BACKUP (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_RENEWALMSG (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_WEBLINKS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_EMERGENCY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BILLDETAILS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE dreams_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        investment TEXT,
        targetAmount REAL,
        savedAmount REAL,
        targetDate TEXT,
        notes TEXT
      )
    ''');

    // New Emergency Contacts Table
    await db.execute('''
      CREATE TABLE TABLE_EMERGENCY_CONTACTS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    // Insert default emergency contacts
    await _insertDefaultEmergencyContacts(db);

    // Insert default carousel images
    await _insertDefaultCarouselImages(db);
  }

  Future<void> _insertDefaultEmergencyContacts(Database db) async {
    List<EmergencyContact> defaultContacts = [
      EmergencyContact(
        name: "Police",
        phoneNumber: "100",
        category: "Emergency Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Fire Brigade",
        phoneNumber: "101",
        category: "Emergency Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Ambulance",
        phoneNumber: "102",
        category: "Medical Emergency",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Disaster Management Services",
        phoneNumber: "108",
        category: "Emergency Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Women Helpline",
        phoneNumber: "1091",
        category: "Support Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Women Helpline (Domestic Abuse)",
        phoneNumber: "181",
        category: "Support Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Child Helpline",
        phoneNumber: "1098",
        category: "Support Services",
        isCustom: false,
      ),
      EmergencyContact(
        name: "Senior Citizen Helpline",
        phoneNumber: "14567",
        category: "Support Services",
        isCustom: false,
      ),
    ];

    for (EmergencyContact contact in defaultContacts) {
      await db.insert('TABLE_EMERGENCY_CONTACTS', {
        'data': jsonEncode(contact.toJson()),
      });
    }
  }

  // Carousel Image Methods
  Future<int> insertCarouselImage({
    required Uint8List imageData,
    required int visitCardId,
    required int order,
    bool isSelected = false,
  }) async {
    try {
      final db = await database;
      return await db.insert('TABLE_CAROUSEL_IMAGES', {
        'visitcard_id': visitCardId,
        'image_data': imageData,
        'image_order': order,
        'is_selected': isSelected ? 1 : 0,
      });
    } catch (e) {
      print("Error inserting carousel image: $e");
      return 0;
    }
  }

  Future<int> updateCarouselImage({
    required int imageId,
    required Uint8List imageData,
    required int order,
    bool isSelected = false,
  }) async {
    try {
      final db = await database;
      return await db.update(
        'TABLE_CAROUSEL_IMAGES',
        {
          'image_data': imageData,
          'image_order': order,
          'is_selected': isSelected ? 1 : 0,
        },
        where: 'keyid = ?',
        whereArgs: [imageId],
      );
    } catch (e) {
      print("Error updating carousel image: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getCarouselImagesByVisitCardId(
    int visitCardId,
  ) async {
    try {
      final db = await database;
      return await db.query(
        'TABLE_CAROUSEL_IMAGES',
        where: 'visitcard_id = ?',
        whereArgs: [visitCardId],
        orderBy: 'image_order ASC',
      );
    } catch (e) {
      print("Error getting carousel images: $e");
      return [];
    }
  }

  Future<int> setSelectedCarouselImage(int visitCardId, int imageId) async {
    try {
      final db = await database;
      // First, unselect all images for this visiting card
      await db.update(
        'TABLE_CAROUSEL_IMAGES',
        {'is_selected': 0},
        where: 'visitcard_id = ?',
        whereArgs: [visitCardId],
      );

      // Then select the specified image
      return await db.update(
        'TABLE_CAROUSEL_IMAGES',
        {'is_selected': 1},
        where: 'keyid = ?',
        whereArgs: [imageId],
      );
    } catch (e) {
      print("Error setting selected carousel image: $e");
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getSelectedCarouselImage(
    int visitCardId,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        'TABLE_CAROUSEL_IMAGES',
        where: 'visitcard_id = ? AND is_selected = 1',
        whereArgs: [visitCardId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error getting selected carousel image: $e");
      return null;
    }
  }

  // Updated Visiting Card Methods
  Future<int> insertOrUpdateVisitingCard({
    required Map<String, dynamic> cardData,
    Uint8List? logoImage,
    Uint8List? cardImage,
    int? id,
    int? selectedBackgroundId,
  }) async {
    try {
      final db = await database;
      final data = {
        'data': jsonEncode(cardData), // Keep original format for compatibility
        'parsed_data': jsonEncode(
          cardData,
        ), // Add parsed data for easier access
        if (logoImage != null) 'logoimage': logoImage,
        if (cardImage != null) 'cardimg': cardImage,
        if (selectedBackgroundId != null)
          'selected_background_id': selectedBackgroundId,
      };

      if (id != null) {
        // Update existing visiting card
        final result = await db.update(
          'TABLE_VISITCARD',
          data,
          where: 'keyid = ?',
          whereArgs: [id],
        );
        return result > 0 ? id : 0;
      } else {
        // Insert new visiting card
        return await db.insert('TABLE_VISITCARD', data);
      }
    } catch (e) {
      print("Error inserting/updating visiting card: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getVisitingCards() async {
    try {
      final db = await database;
      final cards = await db.query('TABLE_VISITCARD', orderBy: 'keyid DESC');

      // Process each card to ensure parsed_data exists
      List<Map<String, dynamic>> processedCards = [];
      for (var card in cards) {
        Map<String, dynamic> processedCard = Map.from(card);

        // If parsed_data doesn't exist, create it from data
        if (processedCard['parsed_data'] == null &&
            processedCard['data'] != null) {
          try {
            processedCard['parsed_data'] = processedCard['data'];
          } catch (e) {
            print("Error processing card data: $e");
            processedCard['parsed_data'] = '{}';
          }
        }

        // Parse the JSON string to Map if it's still a string
        if (processedCard['parsed_data'] is String) {
          try {
            processedCard['parsed_data'] = jsonDecode(
              processedCard['parsed_data'],
            );
          } catch (e) {
            print("Error parsing JSON: $e");
            processedCard['parsed_data'] = {};
          }
        }

        processedCards.add(processedCard);
      }

      return processedCards;
    } catch (e) {
      print("Error getting visiting cards: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getVisitingCardById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'TABLE_VISITCARD',
        where: 'keyid = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> card = Map.from(result.first);

        // Ensure parsed_data exists
        if (card['parsed_data'] == null && card['data'] != null) {
          card['parsed_data'] = card['data'];
        }

        // Parse the JSON string to Map if it's still a string
        if (card['parsed_data'] is String) {
          try {
            card['parsed_data'] = jsonDecode(card['parsed_data']);
          } catch (e) {
            print("Error parsing JSON: $e");
            card['parsed_data'] = {};
          }
        }

        return card;
      }
      return null;
    } catch (e) {
      print("Error getting visiting card by ID: $e");
      return null;
    }
  }

  Future<int> deleteVisitingCard(int id) async {
    try {
      final db = await database;

      // Delete associated carousel images
      await db.delete(
        'TABLE_CAROUSEL_IMAGES',
        where: 'visitcard_id = ?',
        whereArgs: [id],
      );

      // Delete the visiting card
      return await db.delete(
        'TABLE_VISITCARD',
        where: 'keyid = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting visiting card: $e");
      return 0;
    }
  }

  // Emergency Contact CRUD Operations
  Future<int> insertEmergencyContact(EmergencyContact contact) async {
    try {
      final db = await database;
      return await db.insert('TABLE_EMERGENCY_CONTACTS', {
        'data': jsonEncode(contact.toJson()),
      });
    } catch (e) {
      print("Error inserting emergency contact: $e");
      return 0;
    }
  }

  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'TABLE_EMERGENCY_CONTACTS',
      );
      List<EmergencyContact> contacts = [];

      for (var map in maps) {
        try {
          Map<String, dynamic> contactData = jsonDecode(map['data']);
          contacts.add(
            EmergencyContact.fromJson(contactData, id: map['keyid']),
          );
        } catch (e) {
          print('Error parsing emergency contact data: $e');
        }
      }
      return contacts;
    } catch (e) {
      print("Error getting emergency contacts: $e");
      return [];
    }
  }

  Future<List<EmergencyContact>> getEmergencyContactsByCategory(
    String category,
  ) async {
    try {
      final allContacts = await getAllEmergencyContacts();
      return allContacts
          .where((contact) => contact.category == category)
          .toList();
    } catch (e) {
      print("Error getting emergency contacts by category: $e");
      return [];
    }
  }

  Future<int> updateEmergencyContact(EmergencyContact contact) async {
    try {
      final db = await database;
      return await db.update(
        'TABLE_EMERGENCY_CONTACTS',
        {'data': jsonEncode(contact.toJson())},
        where: 'keyid = ?',
        whereArgs: [contact.id],
      );
    } catch (e) {
      print("Error updating emergency contact: $e");
      return 0;
    }
  }

  Future<int> deleteEmergencyContact(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'TABLE_EMERGENCY_CONTACTS',
        where: 'keyid = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting emergency contact: $e");
      return 0;
    }
  }

  // Search emergency contacts
  Future<List<EmergencyContact>> searchEmergencyContacts(String query) async {
    try {
      final allContacts = await getAllEmergencyContacts();
      return allContacts
          .where(
            (contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.phoneNumber.contains(query),
          )
          .toList();
    } catch (e) {
      print("Error searching emergency contacts: $e");
      return [];
    }
  }

  // Get emergency contacts count
  Future<int> getEmergencyContactsCount() async {
    try {
      final contacts = await getAllEmergencyContacts();
      return contacts.length;
    } catch (e) {
      print("Error getting emergency contacts count: $e");
      return 0;
    }
  }

  // Budget-related methods
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('TABLE_BUDGET', budget);
  }

  Future<List<Map<String, dynamic>>> getBudgets(
    String accountName,
    int year,
  ) async {
    final db = await database;
    return await db.query(
      'TABLE_BUDGET',
      where: 'account_name = ? AND year = ?',
      whereArgs: [accountName, year],
    );
  }

  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'TABLE_BUDGET',
      budget,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('TABLE_BUDGET', where: 'keyid = ?', whereArgs: [id]);
  }

  // Account-related methods
  Future<List<String>> getAccountNames() async {
    final db = await database;
    final result = await db.query('TABLE_ACCOUNTSETTINGS');
    List<String> accountNames = [];
    for (var row in result) {
      try {
        Map<String, dynamic> data = jsonDecode(row['data'] as String);
        String accountName = data['Accountname'];
        if (!accountNames.contains(accountName)) {
          accountNames.add(accountName);
        }
      } catch (e) {
        print('Error parsing account data: $e');
      }
    }
    if (accountNames.isEmpty) {
      return [];
    }
    return accountNames;
  }

  Future<void> updateaccountdet(
    String accountname,
    String category,
    String openingbalance,
    String accountype,
    String year,
    String keyid,
  ) async {
    Database db = await database;
    Map<String, dynamic> accountData = {
      "Accountname": accountname,
      "Accounttype": category,
      "Amount": openingbalance,
      "Type": accountype,
      "year": year,
    };
    Map<String, dynamic> datatoupdate = {
      "keyid": keyid,
      "data": jsonEncode(accountData),
    };
    var res = await db.update(
      'TABLE_ACCOUNTSETTINGS',
      datatoupdate,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );
    if (res == 1) {
      print("Account updated successfully: $res");
    } else {
      print("Account update failed");
    }
  }

  Future<List<Map<String, dynamic>>> queryallacc() async {
    Database db = await database;
    var res = await db.query('TABLE_ACCOUNTSETTINGS');
    return res.toList();
  }

  // General data operations
  Future<int> addData(String table, String data) async {
    int insertedId = 0;
    try {
      final db = await database;
      Map<String, dynamic> values = {'data': data};
      insertedId = await db.insert(table, values);
    } catch (e) {
      print("Database insert error: $e");
    }
    return insertedId;
  }

  Future<int> insertData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> updateData(
    String tableName,
    Map<String, dynamic> data,
    int id,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCategoryByName(
    String tableName,
    Map<String, dynamic> data,
    String oldName,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'data = ?',
      whereArgs: [oldName],
    );
  }

  Future<int> deleteData(String tableName, int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'keyid = ?', whereArgs: [id]);
  }

  // Dream-related methods
  Future<List<Dream>> getAllDreams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dreams_table');
    return List.generate(maps.length, (i) {
      return Dream(
        name: maps[i]['name'],
        category: maps[i]['category'],
        investment: maps[i]['investment'],
        targetAmount: maps[i]['targetAmount'],
        savedAmount: maps[i]['savedAmount'],
        targetDate: DateTime.parse(maps[i]['targetDate']),
        notes: maps[i]['notes'],
      );
    });
  }

  Future<bool> _isCategoryUsed(String categoryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTargetAdded = prefs.getBool('target_$categoryName') ?? false;
      return isTargetAdded;
    } catch (e) {
      print('Error checking if category is used: $e');
      return false;
    }
  }

  // Payment-related methods
  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    Map<String, dynamic> paymentData = {
      "date": payment.date,
      "accountName": payment.accountName,
      "amount": payment.amount,
      "paymentMode": payment.paymentMode,
      "remarks": payment.remarks,
    };
    return await db.insert('TABLE_PAYMENTVOUCHER', {
      'voucherdata': jsonEncode(paymentData),
    });
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await database;
    Map<String, dynamic> paymentData = {
      "date": payment.date,
      "accountName": payment.accountName,
      "amount": payment.amount,
      "paymentMode": payment.paymentMode,
      "remarks": payment.remarks,
    };
    return await db.update(
      'TABLE_PAYMENTVOUCHER',
      {'voucherdata': jsonEncode(paymentData)},
      where: 'keyid = ?',
      whereArgs: [payment.id],
    );
  }

  Future<List<Payment>> getPaymentsByMonth(String yearMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TABLE_PAYMENTVOUCHER',
    );
    List<Payment> payments = [];
    for (var map in maps) {
      try {
        Map<String, dynamic> paymentData = jsonDecode(map['voucherdata']);
        String paymentDate = paymentData['date'];
        if (paymentDate.startsWith(yearMonth)) {
          payments.add(
            Payment(
              id: map['keyid'],
              date: paymentData['date'],
              accountName: paymentData['accountName'],
              amount: double.parse(paymentData['amount'].toString()),
              paymentMode: paymentData['paymentMode'],
              remarks: paymentData['remarks'],
            ),
          );
        }
      } catch (e) {
        print('Error parsing payment data: $e');
      }
    }
    return payments;
  }

  Future<int> deletePayment(int id) async {
    final db = await database;
    return await db.delete(
      'TABLE_PAYMENTVOUCHER',
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  // Receipt-related methods
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    Map<String, dynamic> receiptData = {
      "date": receipt.date,
      "accountName": receipt.accountName,
      "amount": receipt.amount.toString(),
      "paymentMode": receipt.paymentMode,
      "remarks": receipt.remarks ?? '',
    };
    return await db.insert('RECEIPT_table', {
      'receipt_data': jsonEncode(receiptData),
    });
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await database;
    Map<String, dynamic> receiptData = {
      "date": receipt.date,
      "accountName": receipt.accountName,
      "amount": receipt.amount.toString(),
      "paymentMode": receipt.paymentMode,
      "remarks": receipt.remarks ?? '',
    };
    return await db.update(
      'RECEIPT_table',
      {'receipt_data': jsonEncode(receiptData)},
      where: 'keyid = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<List<Receipt>> getReceiptsByMonth(String yearMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RECEIPT_table',
      where: 'receipt_data LIKE ?',
      whereArgs: ['%$yearMonth%'],
    );
    List<Receipt> receipts = [];
    for (var map in maps) {
      try {
        Map<String, dynamic> data = jsonDecode(map['receipt_data']);
        receipts.add(
          Receipt(
            id: map['keyid'],
            date: data['date'],
            accountName: data['accountName'],
            amount: double.parse(data['amount']),
            paymentMode: data['paymentMode'],
            remarks: data['remarks'] ?? '',
          ),
        );
      } catch (e) {
        print('Error parsing receipt data: $e');
      }
    }
    return receipts;
  }

  Future<int> deleteReceipt(int id) async {
    final db = await database;
    await db.delete(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_entryid = ? AND ACCOUNTS_VoucherType = ?',
      whereArgs: [id.toString(), 2],
    );
    return await db.delete(
      'RECEIPT_table',
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getWalletData() async {
    Database db = await database;
    var res = await db.query('TABLE_WALLET');
    return res.toList();
  }

  Future<int> insertAccountEntry(Map<String, dynamic> accountData) async {
    final db = await database;
    return await db.insert('TABLE_ACCOUNTS', accountData);
  }

  Future<List<Map<String, dynamic>>> getAllAccountEntries() async {
    final db = await database;
    return await db.query('TABLE_ACCOUNTS', orderBy: 'ACCOUNTS_id DESC');
  }

  Future<List<Map<String, dynamic>>> getAccountEntriesByEntryId(
    String entryId,
  ) async {
    final db = await database;
    return await db.query(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_entryid = ?',
      whereArgs: [entryId],
    );
  }

  Future<List<Map<String, dynamic>>> getAccountEntriesByMonth(
    String month,
    String year,
  ) async {
    final db = await database;
    return await db.query(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_month = ? AND ACCOUNTS_year = ?',
      whereArgs: [month, year],
      orderBy: 'ACCOUNTS_id DESC',
    );
  }

  Future<double> getTotalDebitAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(ACCOUNTS_amount AS REAL)) as total FROM TABLE_ACCOUNTS WHERE ACCOUNTS_type = ?',
      ['debit'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalCreditAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(ACCOUNTS_amount AS REAL)) as total FROM TABLE_ACCOUNTS WHERE ACCOUNTS_type = ?',
      ['credit'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<bool> validateDoubleEntry() async {
    final debitTotal = await getTotalDebitAmount();
    final creditTotal = await getTotalCreditAmount();
    return debitTotal == creditTotal;
  }

  // Deprecated methods - kept for compatibility
  Future<int> insertVisitingCard(Map<String, dynamic> card) async {
    final db = await database;
    return await db.insert('TABLE_VISITCARD', card);
  }

  Future<List<Map<String, dynamic>>> getAllVisitingCards() async {
    return await getVisitingCards();
  }

  Future<int> insertOrUpdateCarouselImage(Uint8List imageData) async {
    try {
      final db = await database;
      // Check if an image already exists (you can modify this logic based on your requirements)
      final existingImages = await db.query('TABLE_CAROUSEL_IMAGES');
      if (existingImages.isNotEmpty) {
        // Update the first image (or modify logic to handle multiple images)
        return await db.update(
          'TABLE_CAROUSEL_IMAGES',
          {'image_data': imageData},
          where: 'keyid = ?',
          whereArgs: [existingImages.first['keyid']],
        );
      } else {
        // Insert new image
        return await db.insert('TABLE_CAROUSEL_IMAGES', {
          'image_data': imageData,
        });
      }
    } catch (e) {
      print("Error inserting/updating carousel image: $e");
      return 0;
    }
  }

  Future<List<Uint8List>> getAllCarouselImages() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'TABLE_CAROUSEL_IMAGES',
      );
      return maps.map((map) => map['image_data'] as Uint8List).toList();
    } catch (e) {
      print("Error getting carousel images: $e");
      return [];
    }
  }
}

class TargetCategory {
  final int? id;
  final String name;
  final Uint8List? iconImage;
  final IconData? iconData;
  final bool isCustom;

  TargetCategory({
    this.id,
    required this.name,
    this.iconImage,
    this.iconData,
    this.isCustom = false,
  });
}
