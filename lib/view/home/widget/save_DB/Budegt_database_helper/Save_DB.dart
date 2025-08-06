import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/model_class_emergency.dart';
import 'package:new_project_2025/view/home/widget/setting_page/bill_header/bill_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
      version: 4,
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
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TABLE_CAROUSEL_IMAGES (
          keyid INTEGER PRIMARY KEY AUTOINCREMENT,
          visitcard_id INTEGER,
          image_data BLOB,
          image_order INTEGER,
          is_selected INTEGER DEFAULT 0,
          FOREIGN KEY (visitcard_id) REFERENCES TABLE_VISITCARD (keyid) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        ALTER TABLE TABLE_VISITCARD ADD COLUMN parsed_data TEXT
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        DROP TABLE IF EXISTS TABLE_CAROUSEL_IMAGES
      ''');
      await db.execute('''
        CREATE TABLE TABLE_CAROUSEL_IMAGES (
          keyid INTEGER PRIMARY KEY AUTOINCREMENT,
          visitcard_id INTEGER,
          image_data BLOB,
          image_order INTEGER,
          is_selected INTEGER DEFAULT 0,
          FOREIGN KEY (visitcard_id) REFERENCES TABLE_VISITCARD (keyid) ON DELETE CASCADE
        )
      ''');
    }
  }

  // NEW: Image compression method to handle large images
  Future<Uint8List?> compressImage(
    Uint8List imageBytes, {
    int maxSizeKB = 100,
    int quality = 85,
  }) async {
    try {
      if (imageBytes.isEmpty) {
        print("Cannot compress empty image data");
        return null;
      }

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print("Failed to decode image for compression");
        return imageBytes; // Return original if can't decode
      }

      // Calculate original size in KB
      double originalSizeKB = imageBytes.length / 1024;
      print("Original image size: ${originalSizeKB.toStringAsFixed(2)} KB");

      if (originalSizeKB <= maxSizeKB) {
        print("Image is already within size limit");
        return imageBytes;
      }

      // Calculate resize ratio based on file size
      double ratio =
          (maxSizeKB / originalSizeKB) * 0.8; // 80% of target to be safe
      int newWidth = (image.width * ratio).round();
      int newHeight = (image.height * ratio).round();

      // Ensure minimum dimensions
      if (newWidth < 100) newWidth = 100;
      if (newHeight < 100) newHeight = 100;

      // Resize the image
      img.Image resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
      );

      // Encode with quality compression
      Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );

      double compressedSizeKB = compressedBytes.length / 1024;
      print("Compressed image size: ${compressedSizeKB.toStringAsFixed(2)} KB");

      // If still too large, reduce quality further
      if (compressedSizeKB > maxSizeKB && quality > 30) {
        print("Still too large, reducing quality further");
        return await compressImage(
          imageBytes,
          maxSizeKB: maxSizeKB,
          quality: quality - 20,
        );
      }

      return compressedBytes;
    } catch (e) {
      print("Error compressing image: $e");
      return imageBytes; // Return original on error
    }
  }

  Future<void> _createAllTables(Database db) async {
    // [Previous table creation code remains unchanged]
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
    await db.execute('''
      CREATE TABLE TABLE_CAROUSEL_IMAGES (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        visitcard_id INTEGER,
        image_data BLOB,
        image_order INTEGER,
        is_selected INTEGER DEFAULT 0,
        FOREIGN KEY (visitcard_id) REFERENCES TABLE_VISITCARD (keyid) ON DELETE CASCADE
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
    await db.execute('''
      CREATE TABLE TABLE_VISITCARD (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        parsed_data TEXT,
        logoimage BLOB,
        cardimg BLOB,
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
    await db.execute('''
      CREATE TABLE TABLE_EMERGENCY_CONTACTS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
    await _insertDefaultEmergencyContacts(db);
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

  // Helper method to convert asset image to Uint8List
  Future<Uint8List> loadAssetImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      Uint8List imageBytes = data.buffer.asUint8List();

      // Compress asset images too if they're large
      Uint8List? compressedBytes = await compressImage(imageBytes);
      return compressedBytes ?? imageBytes;
    } catch (e) {
      print("Error loading asset image $assetPath: $e");
      return Uint8List(0); // Return empty Uint8List on error
    }
  }

  // UPDATED: insertOrUpdateVisitingCard method with image compression
  Future<int> insertOrUpdateVisitingCard({
    required Map<String, dynamic> cardData,
    Uint8List? logoImage,
    Uint8List? cardImage,
    int? id,
    int? selectedBackgroundId,
    List<String>? defaultImageAssets,
  }) async {
    try {
      final db = await database;

      // Validate and clean input data
      Map<String, dynamic> cleanedCardData = {};
      cardData.forEach((key, value) {
        if (value != null) {
          String cleanValue = value.toString().trim();
          if (cleanValue.isNotEmpty && cleanValue.toLowerCase() != 'null') {
            cleanedCardData[key] = cleanValue;
          } else {
            cleanedCardData[key] = '';
          }
        } else {
          cleanedCardData[key] = '';
        }
      });

      // Ensure required fields have valid values
      if (cleanedCardData['name'] == null ||
          cleanedCardData['name'].toString().trim().isEmpty) {
        cleanedCardData['name'] =
            'New Card ${DateTime.now().millisecondsSinceEpoch}';
      }

      // COMPRESS IMAGES BEFORE STORING - Better logo handling
      Uint8List? compressedLogoImage;
      Uint8List? compressedCardImage;

      if (logoImage != null && logoImage.isNotEmpty) {
        print(
          "Compressing logo image... Original size: ${logoImage.length} bytes",
        );
        compressedLogoImage = await compressImage(logoImage, maxSizeKB: 50);
        if (compressedLogoImage == null || compressedLogoImage.isEmpty) {
          print("Failed to compress logo image, using original");
          compressedLogoImage = logoImage;
        } else {
          print("Logo compressed to: ${compressedLogoImage.length} bytes");
        }
      } else {
        print("No logo image provided");
      }

      if (cardImage != null && cardImage.isNotEmpty) {
        print(
          "Compressing card image... Original size: ${cardImage.length} bytes",
        );
        compressedCardImage = await compressImage(cardImage, maxSizeKB: 80);
        if (compressedCardImage == null || compressedCardImage.isEmpty) {
          print("Failed to compress card image, using original");
          compressedCardImage = cardImage;
        } else {
          print(
            "Card image compressed to: ${compressedCardImage.length} bytes",
          );
        }
      }

      // Prepare data for storage - DON'T include logo in JSON data
      Map<String, dynamic> jsonData = Map.from(cleanedCardData);
      // Remove any existing logo from JSON to prevent duplication
      jsonData.remove('logoimage');
      jsonData.remove('logo_image');
      jsonData.remove('logo');

      final data = {
        'data': jsonEncode(jsonData),
        'parsed_data': jsonEncode(cleanedCardData),
        'logoimage': compressedLogoImage, // Store logo separately as BLOB
        'cardimg': compressedCardImage,
        'selected_background_id': selectedBackgroundId,
      };

      int visitingCardId;
      if (id != null && id > 0) {
        // For updates, preserve existing logo if new one is not provided
        if (compressedLogoImage == null) {
          // Don't update logo field if no new logo provided
          data.remove('logoimage');
          print("Update: No new logo provided, keeping existing logo");
        }

        final updateResult = await db.update(
          'TABLE_VISITCARD',
          data,
          where: 'keyid = ?',
          whereArgs: [id],
        );
        if (updateResult > 0) {
          visitingCardId = id;
          print("Card updated successfully with ID: $visitingCardId");
        } else {
          throw Exception('Failed to update card with ID $id');
        }
      } else {
        visitingCardId = await db.insert('TABLE_VISITCARD', data);
        if (visitingCardId <= 0) {
          throw Exception('Failed to insert new card');
        }
        print("New card inserted with ID: $visitingCardId");
      }

      // Handle default images if no cardImage is provided
      if (compressedCardImage == null &&
          defaultImageAssets != null &&
          defaultImageAssets.isNotEmpty) {
        await deleteCarouselImagesByVisitCardId(visitingCardId);
        for (int i = 0; i < defaultImageAssets.length; i++) {
          final Uint8List imageData = await loadAssetImage(
            defaultImageAssets[i],
          );
          if (imageData.isNotEmpty) {
            await insertCarouselImage(
              imageData: imageData,
              visitCardId: visitingCardId,
              order: i,
              isSelected: i == (selectedBackgroundId ?? 0),
            );
          }
        }
      }

      print("Successfully saved visiting card with ID: $visitingCardId");
      return visitingCardId;
    } catch (e) {
      print("Error in insertOrUpdateVisitingCard: $e");
      return 0;
    }
  }

  // UPDATED: getVisitingCards method with better error handling for large images
  Future<List<Map<String, dynamic>>> getVisitingCards() async {
    try {
      final db = await database;

      // Query with pagination to handle large datasets
      final cardsWithoutBlobs = await db.query(
        'TABLE_VISITCARD',
        columns: ['keyid', 'data', 'parsed_data', 'selected_background_id'],
        orderBy: 'keyid DESC',
      );

      List<Map<String, dynamic>> processedCards = [];

      for (var card in cardsWithoutBlobs) {
        try {
          Map<String, dynamic> processedCard = Map.from(card);

          // Handle parsed_data
          if (processedCard['parsed_data'] == null ||
              processedCard['parsed_data'].toString().trim().isEmpty) {
            if (processedCard['data'] != null &&
                processedCard['data'].toString().trim().isNotEmpty) {
              processedCard['parsed_data'] = processedCard['data'];
            } else {
              processedCard['parsed_data'] = jsonEncode({
                'name': 'Recovery Mode Card',
                'phone': '',
                'email': '',
                'website': '',
                'designation': '',
                'companyName': '',
                'error': 'Original data was corrupted or missing',
              });
            }
          }

          // Parse JSON data safely
          if (processedCard['parsed_data'] is String) {
            try {
              final jsonData = jsonDecode(processedCard['parsed_data']);
              if (jsonData is Map<String, dynamic>) {
                processedCard['parsed_data'] = jsonData;
              } else {
                throw FormatException('Invalid JSON structure');
              }
            } catch (e) {
              print(
                "Error parsing JSON for card ${processedCard['keyid']}: $e",
              );
              processedCard['parsed_data'] = {
                'name': 'Data Recovery Card ${processedCard['keyid']}',
                'phone': '',
                'email': '',
                'website': '',
                'designation': '',
                'companyName': '',
                'error': 'JSON parsing failed: ${e.toString()}',
              };
            }
          }

          // Ensure parsed_data is a valid Map
          if (processedCard['parsed_data'] is! Map<String, dynamic>) {
            processedCard['parsed_data'] = {
              'name': 'Unknown Card ${processedCard['keyid']}',
              'phone': '',
              'email': '',
              'website': '',
              'designation': '',
              'companyName': '',
              'error': 'Invalid data type',
            };
          }

          // Clean individual fields
          final parsedData =
              processedCard['parsed_data'] as Map<String, dynamic>;
          parsedData['name'] = _cleanField(parsedData['name'], 'Unnamed Card');
          parsedData['phone'] = _cleanField(parsedData['phone'], '');
          parsedData['email'] = _cleanField(parsedData['email'], '');
          parsedData['website'] = _cleanField(parsedData['website'], '');
          parsedData['designation'] = _cleanField(
            parsedData['designation'],
            '',
          );
          parsedData['companyName'] = _cleanField(
            parsedData['companyName'],
            '',
          );
          parsedData['whatsapnumber'] = _cleanField(
            parsedData['whatsapnumber'],
            '',
          );
          parsedData['landphone'] = _cleanField(parsedData['landphone'], '');
          parsedData['companyaddress'] = _cleanField(
            parsedData['companyaddress'],
            '',
          );
          parsedData['fblink'] = _cleanField(parsedData['fblink'], '');
          parsedData['instalink'] = _cleanField(parsedData['instalink'], '');
          parsedData['youtubelink'] = _cleanField(
            parsedData['youtubelink'],
            '',
          );
          parsedData['saveapplink'] = _cleanField(
            parsedData['saveapplink'],
            '',
          );
          parsedData['couponcode'] = _cleanField(parsedData['couponcode'], '');

          // Load BLOB data separately - Critical for logo display
          try {
            final blobData = await db.query(
              'TABLE_VISITCARD',
              columns: ['logoimage', 'cardimg'],
              where: 'keyid = ?',
              whereArgs: [processedCard['keyid']],
              limit: 1,
            );

            if (blobData.isNotEmpty) {
              final logoImage = blobData.first['logoimage'];
              final cardImg = blobData.first['cardimg'];

              // Validate logo image
              if (logoImage != null &&
                  logoImage is Uint8List &&
                  logoImage.isNotEmpty) {
                processedCard['logoimage'] = logoImage;
                print(
                  "Logo loaded for card ${processedCard['keyid']}: ${logoImage.length} bytes",
                );
              } else {
                processedCard['logoimage'] = null;
                print("No valid logo for card ${processedCard['keyid']}");
              }

              // Validate card image
              if (cardImg != null &&
                  cardImg is Uint8List &&
                  cardImg.isNotEmpty) {
                processedCard['cardimg'] = cardImg;
              } else {
                processedCard['cardimg'] = null;
              }
            } else {
              print("No BLOB data found for card ${processedCard['keyid']}");
              processedCard['logoimage'] = null;
              processedCard['cardimg'] = null;
            }
          } catch (e) {
            print(
              "Error loading BLOB data for card ${processedCard['keyid']}: $e",
            );
            processedCard['logoimage'] = null;
            processedCard['cardimg'] = null;
          }

          processedCards.add(processedCard);
        } catch (e) {
          print("Error processing individual card: $e");
          // Create a safe card entry even if processing fails
          processedCards.add({
            'keyid': card['keyid'] ?? 0,
            'parsed_data': {
              'name': 'Error Card ${card['keyid'] ?? 'Unknown'}',
              'phone': '',
              'email': '',
              'website': '',
              'designation': '',
              'companyName': '',
              'error': 'Card processing failed: ${e.toString()}',
            },
            'logoimage': null,
            'cardimg': null,
          });
        }
      }

      print("Loaded ${processedCards.length} cards successfully");
      return processedCards;
    } catch (e) {
      print("Error getting visiting cards: $e");
      return [];
    }
  }

  // Helper method to clean individual fields
  String _cleanField(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) {
      final cleaned = value.trim();
      if (cleaned.isEmpty ||
          cleaned.toLowerCase() == 'null' ||
          cleaned.toLowerCase() == 'unknown') {
        return defaultValue;
      }
      return cleaned;
    }
    return value.toString().trim().isEmpty ? defaultValue : value.toString();
  }

  // UPDATED: getVisitingCardById method with separate BLOB loading
  Future<Map<String, dynamic>?> getVisitingCardById(int id) async {
    try {
      final db = await database;

      // Get complete card data including BLOB
      final result = await db.query(
        'TABLE_VISITCARD',
        where: 'keyid = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> card = Map.from(result.first);

        // Handle parsed_data
        if (card['parsed_data'] == null && card['data'] != null) {
          card['parsed_data'] = card['data'];
        }
        if (card['parsed_data'] is String) {
          try {
            card['parsed_data'] = jsonDecode(card['parsed_data']);
          } catch (e) {
            print("Error parsing JSON: $e");
            card['parsed_data'] = {};
          }
        }

        // Ensure logoimage is properly retrieved
        final logoImage = card['logoimage'];
        if (logoImage != null && logoImage is Uint8List) {
          if (logoImage.isNotEmpty) {
            print("Logo retrieved from database: ${logoImage.length} bytes");
          } else {
            print("Logo is empty in database");
            card['logoimage'] = null;
          }
        } else {
          print("No logo found in database for card $id");
          card['logoimage'] = null;
        }

        return card;
      }
      return null;
    } catch (e) {
      print("Error getting visiting card by ID: $e");
      return null;
    }
  }

  // UPDATED: insertCarouselImage with compression
  Future<int> insertCarouselImage({
    required Uint8List imageData,
    required int visitCardId,
    required int order,
    bool isSelected = false,
  }) async {
    try {
      final db = await database;
      if (imageData.isEmpty) {
        print("Warning: Attempting to insert empty image data");
        return 0;
      }

      // Compress carousel image
      print("Compressing carousel image...");
      Uint8List? compressedImageData = await compressImage(
        imageData,
        maxSizeKB: 80,
      );
      if (compressedImageData == null) {
        print("Failed to compress carousel image, using original");
        compressedImageData = imageData;
      }

      return await db.insert('TABLE_CAROUSEL_IMAGES', {
        'visitcard_id': visitCardId,
        'image_data': compressedImageData,
        'image_order': order,
        'is_selected': isSelected ? 1 : 0,
      });
    } catch (e) {
      print("Error inserting carousel image: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getCarouselImagesByVisitCardId(
    int visitCardId,
  ) async {
    try {
      final db = await database;

      // Query metadata first
      final metadataResult = await db.query(
        'TABLE_CAROUSEL_IMAGES',
        columns: ['keyid', 'visitcard_id', 'image_order', 'is_selected'],
        where: 'visitcard_id = ?',
        whereArgs: [visitCardId],
        orderBy: 'image_order ASC',
      );

      List<Map<String, dynamic>> result = [];

      for (var metadata in metadataResult) {
        try {
          // Load image data separately
          final imageResult = await db.query(
            'TABLE_CAROUSEL_IMAGES',
            columns: ['image_data'],
            where: 'keyid = ?',
            whereArgs: [metadata['keyid']],
            limit: 1,
          );

          if (imageResult.isNotEmpty &&
              imageResult.first['image_data'] != null) {
            Map<String, dynamic> combined = Map.from(metadata);
            combined['image_data'] = imageResult.first['image_data'];
            result.add(combined);
          }
        } catch (e) {
          print(
            "Error loading image data for carousel image ${metadata['keyid']}: $e",
          );
        }
      }

      return result;
    } catch (e) {
      print("Error getting carousel images: $e");
      return [];
    }
  }

  Future<int> deleteVisitingCard(int id) async {
    try {
      final db = await database;
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

  Future<int> updateCarouselImage({
    required int imageId,
    required Uint8List imageData,
    required int order,
    bool isSelected = false,
  }) async {
    try {
      final db = await database;

      // Compress image before updating
      Uint8List? compressedImageData = await compressImage(
        imageData,
        maxSizeKB: 80,
      );
      if (compressedImageData == null) {
        compressedImageData = imageData;
      }

      return await db.update(
        'TABLE_CAROUSEL_IMAGES',
        {
          'image_data': compressedImageData,
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

  Future<int> setSelectedCarouselImage(int visitCardId, int imageId) async {
    try {
      final db = await database;
      await db.update(
        'TABLE_CAROUSEL_IMAGES',
        {'is_selected': 0},
        where: 'visitcard_id = ?',
        whereArgs: [visitCardId],
      );
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

      // Get metadata first
      final metadataResult = await db.query(
        'TABLE_CAROUSEL_IMAGES',
        columns: ['keyid', 'visitcard_id', 'image_order', 'is_selected'],
        where: 'visitcard_id = ? AND is_selected = 1',
        whereArgs: [visitCardId],
        limit: 1,
      );

      if (metadataResult.isNotEmpty) {
        // Load image data separately
        final imageResult = await db.query(
          'TABLE_CAROUSEL_IMAGES',
          columns: ['image_data'],
          where: 'keyid = ?',
          whereArgs: [metadataResult.first['keyid']],
          limit: 1,
        );

        if (imageResult.isNotEmpty) {
          Map<String, dynamic> result = Map.from(metadataResult.first);
          result['image_data'] = imageResult.first['image_data'];
          return result;
        }
      }
      return null;
    } catch (e) {
      print("Error getting selected carousel image: $e");
      return null;
    }
  }

  Future<int> deleteCarouselImagesByVisitCardId(int visitCardId) async {
    try {
      final db = await database;
      return await db.delete(
        'TABLE_CAROUSEL_IMAGES',
        where: 'visitcard_id = ?',
        whereArgs: [visitCardId],
      );
    } catch (e) {
      print("Error deleting carousel images: $e");
      return 0;
    }
  }

  // New method to repair corrupted visiting cards
  Future<void> repairCorruptedVisitingCards() async {
    try {
      final db = await database;
      final cards = await db.query('TABLE_VISITCARD');

      for (var card in cards) {
        bool needsRepair = false;
        Map<String, dynamic> repairedData = Map.from(card);

        // Check if parsed_data is corrupted
        if (card['parsed_data'] == null ||
            card['parsed_data'].toString().trim().isEmpty) {
          if (card['data'] != null &&
              card['data'].toString().trim().isNotEmpty) {
            repairedData['parsed_data'] = card['data'];
            needsRepair = true;
          } else {
            // Create minimal valid data
            Map<String, dynamic> minimalData = {
              'name': 'Recovered Card ${card['keyid']}',
              'phone': '',
              'email': '',
              'website': '',
              'designation': '',
              'companyName': '',
            };
            repairedData['data'] = jsonEncode(minimalData);
            repairedData['parsed_data'] = jsonEncode(minimalData);
            needsRepair = true;
          }
        }

        // Validate JSON structure
        try {
          if (repairedData['parsed_data'] is String) {
            final parsed = jsonDecode(repairedData['parsed_data']);
            if (parsed is! Map<String, dynamic>) {
              throw FormatException('Invalid structure');
            }
          }
        } catch (e) {
          Map<String, dynamic> safeData = {
            'name': 'Repaired Card ${card['keyid']}',
            'phone': '',
            'email': '',
            'website': '',
            'designation': '',
            'companyName': '',
            'repaired': true,
            'originalError': e.toString(),
          };
          repairedData['data'] = jsonEncode(safeData);
          repairedData['parsed_data'] = jsonEncode(safeData);
          needsRepair = true;
        }

        if (needsRepair) {
          await db.update(
            'TABLE_VISITCARD',
            repairedData,
            where: 'keyid = ?',
            whereArgs: [card['keyid']],
          );
          print("Repaired visiting card ${card['keyid']}");
        }
      }
    } catch (e) {
      print("Error during database repair: $e");
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
Future<List<Map<String, dynamic>>> fetchAllData() async {
  Database db = await database;
  var res = await db.query('TABLE_WEBLINKS');

  List<Map<String, dynamic>> s = res.toList();
  print("Weblink datas are: $s");

  return s;
}
Future<int> deleteWebLInk(String tableName, String id) async {
  final db = await database;
  return await db.delete(tableName, where: 'keyid = ?', whereArgs: [id]);
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
      final existingImages = await db.query('TABLE_CAROUSEL_IMAGES');
      if (existingImages.isNotEmpty) {
        Uint8List? compressedData = await compressImage(imageData);
        return await db.update(
          'TABLE_CAROUSEL_IMAGES',
          {'image_data': compressedData ?? imageData},
          where: 'keyid = ?',
          whereArgs: [existingImages.first['keyid']],
        );
      } else {
        Uint8List? compressedData = await compressImage(imageData);
        return await db.insert('TABLE_CAROUSEL_IMAGES', {
          'image_data': compressedData ?? imageData,
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

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<int> insertBillDetails(BillDetails billDetails) async {
    try {
      final db = await database;

      // Validate input data
      if (billDetails.companyName.trim().isEmpty) {
        print("Error: Company name is required");
        return 0;
      }

      Map<String, dynamic> billData = {
        'data': jsonEncode(billDetails.toJson()),
      };

      int result = await db.insert('TABLE_BILLDETAILS', billData);

      if (result > 0) {
        print("✅ Bill details inserted successfully!");
        print("📋 ID: $result");
        print("🏢 Company: ${billDetails.companyName}");
        print("📍 Address: ${billDetails.address}");
        print("📱 Mobile: ${billDetails.mobile}");
      } else {
        print("❌ Failed to insert bill details");
      }

      return result;
    } catch (e) {
      print("❌ Error inserting bill details: $e");
      return 0;
    }
  }

  /// Update Bill Details
  Future<int> updateBillDetails(int billId, BillDetails billDetails) async {
    try {
      final db = await database;

      // Validate input data
      if (billDetails.companyName.trim().isEmpty) {
        print("Error: Company name is required");
        return 0;
      }

      Map<String, dynamic> billData = {
        'data': jsonEncode(billDetails.toJson()),
      };

      int result = await db.update(
        'TABLE_BILLDETAILS',
        billData,
        where: 'keyid = ?',
        whereArgs: [billId],
      );

      if (result > 0) {
        print("✅ Bill details updated successfully!");
        print("📋 ID: $billId");
        print("🏢 Company: ${billDetails.companyName}");
        print("📍 Address: ${billDetails.address}");
        print("📱 Mobile: ${billDetails.mobile}");
      } else {
        print("❌ No bill found with ID: $billId");
      }

      return result;
    } catch (e) {
      print("❌ Error updating bill details: $e");
      return 0;
    }
  }

  /// Get All Bill Details
  Future<List<BillDetails>> getAllBillDetails() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'TABLE_BILLDETAILS',
      );

      List<BillDetails> billDetailsList = [];

      for (var map in maps) {
        try {
          Map<String, dynamic> billData = jsonDecode(map['data']);
          billDetailsList.add(BillDetails.fromJson(billData, id: map['keyid']));
        } catch (e) {
          print('Error parsing bill details data for ID ${map['keyid']}: $e');
        }
      }

      print("📋 Retrieved ${billDetailsList.length} bill details records");
      return billDetailsList;
    } catch (e) {
      print("❌ Error getting bill details: $e");
      return [];
    }
  }

  /// Get Bill Details by ID
  Future<BillDetails?> getBillDetailsById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'TABLE_BILLDETAILS',
        where: 'keyid = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Map<String, dynamic> billData = jsonDecode(maps.first['data']);
        return BillDetails.fromJson(billData, id: maps.first['keyid']);
      }

      print("❌ No bill details found with ID: $id");
      return null;
    } catch (e) {
      print("❌ Error getting bill details by ID: $e");
      return null;
    }
  }

  /// Delete Bill Details
  Future<int> deleteBillDetails(int id) async {
    try {
      final db = await database;
      int result = await db.delete(
        'TABLE_BILLDETAILS',
        where: 'keyid = ?',
        whereArgs: [id],
      );

      if (result > 0) {
        print("✅ Bill details deleted successfully for ID: $id");
      } else {
        print("❌ No bill details found with ID: $id");
      }

      return result;
    } catch (e) {
      print("❌ Error deleting bill details: $e");
      return 0;
    }
  }

  /// Search Bill Details by Company Name
  Future<List<BillDetails>> searchBillDetailsByCompany(
    String companyName,
  ) async {
    try {
      final allBills = await getAllBillDetails();
      return allBills
          .where(
            (bill) => bill.companyName.toLowerCase().contains(
              companyName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      print("❌ Error searching bill details: $e");
      return [];
    }
  }

  /// Get Bill Details Count
  Future<int> getBillDetailsCount() async {
    try {
      final bills = await getAllBillDetails();
      return bills.length;
    } catch (e) {
      print("❌ Error getting bill details count: $e");
      return 0;
    }
  }

  // Usage Examples:

  /*

*/
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
