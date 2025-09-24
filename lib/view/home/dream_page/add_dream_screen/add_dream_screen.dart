import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';
import 'package:new_project_2025/view/home/dream_page/mile_stone_screen/miles_stone_screen.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddDreamScreen extends StatefulWidget {
  final Function(Dream) onDreamAdded;
  final Function(Dream)? onDreamUpdated;
  final Dream? dream;

  const AddDreamScreen({
    required this.onDreamAdded,
    this.onDreamUpdated,
    this.dream,
    super.key,
  });

  @override
  _AddDreamScreenState createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedTarget;
  String targetName = '';
  double targetAmount = 0.0;
  String? selectedInvestment;
  double savedAmount = 0.0;
  DateTime? selectedDate;
  String notes = '';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TargetCategory> targetCategories = [];
  List<InvestmentAccount> investmentAccounts = [];
  bool isLoading = true;
  int? _dreamId;

  final TextEditingController _targetNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _savedAmountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    if (widget.dream != null) {
      _dreamId = widget.dream!.id;
      selectedTarget = widget.dream!.category;
      targetName = widget.dream!.name;
      targetAmount = widget.dream!.targetAmount;
      selectedInvestment = widget.dream!.investment;
      savedAmount = widget.dream!.savedAmount;
      selectedDate = widget.dream!.targetDate;
      notes = widget.dream!.notes;

      _targetNameController.text = targetName;
      _targetAmountController.text =
          targetAmount > 0 ? targetAmount.toString() : '';
      _savedAmountController.text =
          savedAmount > 0 ? savedAmount.toString() : '';
      _dateController.text =
          selectedDate != null
              ? DateFormat('dd-MM-yyyy').format(selectedDate!)
              : '';
      _notesController.text = notes;
    }
  }

  Future<bool> _saveOrUpdateDream({bool isFinalSave = false}) async {
    try {
      final updatedDream = Dream(
        id: _dreamId,
        name: targetName,
        category: selectedTarget!,
        investment: selectedInvestment ?? 'My Saving',
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        targetDate: selectedDate ?? DateTime.now(),
        notes: notes,
        closingBalance: 0.0, // Adjust based on your needs
        addedAmount: 0.0, // Adjust based on your needs
      );

      Map<String, dynamic> dreamData = {
        "targetname": _targetNameController.text.trim(),
        "targetamount": targetAmount.toString(),
        "savedamount": savedAmount.toString(),
        "target_date": selectedDate.toString(),
        "note": _notesController.text.trim(),
        "investment": selectedInvestment ?? 'My Saving',
        "category": selectedTarget!,
      };

      Map<String, dynamic> dbData = {
        "data": jsonEncode(dreamData),
      }; // FIXED: Use jsonEncode

      if (_dreamId == null) {
        // New dream: Insert and get ID
        _dreamId = await _dbHelper.insertTargetdata(dbData);
        if (_dreamId == 0) return false;

        if (isFinalSave) {
          widget.onDreamAdded(updatedDream.copyWith(id: _dreamId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dream added successfully!')),
          );
        }
      } else {
        // Edit: Update in DB
        final updateResult = await _dbHelper.updateData(
          "TABLE_TARGET",
          dbData,
          _dreamId!,
        );
        if (updateResult == 0) return false;

        if (isFinalSave) {
          widget.onDreamUpdated?.call(updatedDream);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dream updated successfully!')),
          );
        }
      }
      return true;
    } catch (e) {
      print('Error saving dream: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isFinalSave ? (widget.dream == null ? 'add' : 'update') : 'save'} dream: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _targetNameController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _loadTargetCategories();
      await _loadInvestmentAccounts();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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

  Future<void> _loadInvestmentAccounts() async {
    try {
      List<Map<String, dynamic>> accounts = await _dbHelper.getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      List<InvestmentAccount> investments = [];

      // Add default "My Saving" option
      double mySavingBalance = await _calculateMySavingBalance();
      investments.add(
        InvestmentAccount(name: 'My Saving', balance: mySavingBalance),
      );

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          if (accountType == 'investment') {
            double balance = await _calculateInvestmentBalance(accountName);
            investments.add(
              InvestmentAccount(name: accountName, balance: balance),
            );
          }
        } catch (e) {
          print('Error parsing investment account: $e');
        }
      }

      setState(() {
        investmentAccounts = investments;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading investment accounts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<double> _calculateMySavingBalance() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> walletData = await db.query(
        'TABLE_WALLET',
      );

      double balance = 0.0;
      for (var entry in walletData) {
        try {
          Map<String, dynamic> data = jsonDecode(entry['data']);
          double amount = double.tryParse(data['edtAmount'].toString()) ?? 0.0;
          balance += amount;
        } catch (e) {
          print('Error parsing wallet data: $e');
        }
      }
      return balance;
    } catch (e) {
      print('Error calculating My Saving balance: $e');
      return 0.0;
    }
  }

  Future<double> _calculateInvestmentBalance(String accountName) async {
    try {
      final db = await _dbHelper.database;

      String setupId = await _getAccountSetupId(accountName);
      if (setupId == '0') return 0.0;

      final List<Map<String, dynamic>> accountTransactions = await db.query(
        'TABLE_ACCOUNTS',
        where: 'ACCOUNTS_setupid = ?',
        whereArgs: [setupId],
      );

      double balance = 0.0;
      for (var transaction in accountTransactions) {
        try {
          double amount =
              double.tryParse(transaction['ACCOUNTS_amount'].toString()) ?? 0.0;
          String type = transaction['ACCOUNTS_type'].toString();

          if (type == 'debit') {
            balance += amount;
          } else if (type == 'credit') {
            balance -= amount;
          }
        } catch (e) {
          print('Error parsing account transaction: $e');
        }
      }

      double openingBalance = await _getAccountOpeningBalance(accountName);
      balance += openingBalance;

      return balance;
    } catch (e) {
      print('Error calculating investment balance for $accountName: $e');
      return 0.0;
    }
  }

  Future<String> _getAccountSetupId(String accountName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> accounts = await db.query(
        'TABLE_ACCOUNTSETTINGS',
      );

      for (var account in accounts) {
        try {
          Map<String, dynamic> data = jsonDecode(account['data']);
          if (data['Accountname'].toString().toLowerCase() ==
              accountName.toLowerCase()) {
            return account['keyid'].toString();
          }
        } catch (e) {
          print('Error parsing account setup: $e');
        }
      }
      return '0';
    } catch (e) {
      print('Error getting account setup ID: $e');
      return '0';
    }
  }

  Future<double> _getAccountOpeningBalance(String accountName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> accounts = await db.query(
        'TABLE_ACCOUNTSETTINGS',
      );

      for (var account in accounts) {
        try {
          Map<String, dynamic> data = jsonDecode(account['data']);
          if (data['Accountname'].toString().toLowerCase() ==
              accountName.toLowerCase()) {
            return double.tryParse(data['OpeningBalance'].toString()) ?? 0.0;
          }
        } catch (e) {
          print('Error parsing opening balance: $e');
        }
      }
      return 0.0;
    } catch (e) {
      print('Error getting opening balance: $e');
      return 0.0;
    }
  }

  TargetCategory? _getSelectedCategory() {
    if (selectedTarget == null) return null;
    try {
      return targetCategories.firstWhere((cat) => cat.name == selectedTarget);
    } catch (e) {
      return null;
    }
  }

  Widget _buildCategoryIcon(TargetCategory category, {double size = 24}) {
    if (category.iconImage != null && category.iconImage!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.memory(
            category.iconImage!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                size: size,
                color: Colors.grey[400],
              );
            },
          ),
        );
      } catch (e) {
        return Icon(Icons.broken_image, size: size, color: Colors.grey[400]);
      }
    } else if (!category.isCustom && category.iconData != null) {
      return Icon(category.iconData!, color: Colors.teal, size: size);
    } else {
      return Icon(Icons.help_outline, color: Colors.grey[400], size: size);
    }
  }

  Future<bool> _isCategoryUsed(String categoryName) async {
    return false;
  }

  void _showTargetCategoriesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Target Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddNewCategoryDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Add new',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: targetCategories.length,
                    itemBuilder: (context, index) {
                      final category = targetCategories[index];
                      return FutureBuilder<bool>(
                        future: _isCategoryUsed(category.name),
                        builder: (context, snapshot) {
                          final isUsed = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedTarget = category.name);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    selectedTarget == category.name
                                        ? Colors.teal.withOpacity(0.2)
                                        : Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    selectedTarget == category.name
                                        ? Border.all(
                                          color: Colors.teal,
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  category.isCustom
                                      ? IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        color:
                                            isUsed ? Colors.grey : Colors.teal,
                                        tooltip:
                                            isUsed
                                                ? 'Cannot edit: Category in use'
                                                : 'Edit category',
                                        onPressed:
                                            isUsed
                                                ? null
                                                : () {
                                                  Navigator.pop(context);
                                                  _showAddNewCategoryDialog(
                                                    category: category,
                                                  );
                                                },
                                      )
                                      : const SizedBox.shrink(),
                                  Expanded(
                                    child: Center(
                                      child: _buildCategoryIcon(
                                        category,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddNewCategoryDialog({TargetCategory? category}) {
    String newCategoryName = category?.name ?? '';
    Uint8List? selectedImageBytes = category?.iconImage;
    bool isEditing = category != null;
    final nameController = TextEditingController(text: newCategoryName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Category' : 'Add New Category',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.label),
                      ),
                      controller: nameController,
                      onChanged: (value) => newCategoryName = value,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Selected Icon: '),
                              const SizedBox(width: 10),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    selectedImageBytes != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.memory(
                                            selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 24,
                                                    ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _pickImageFile(
                                    setDialogState,
                                    (bytes) => selectedImageBytes = bytes,
                                  );
                                  setDialogState(() {});
                                },
                                icon: const Icon(Icons.folder_open, size: 16),
                                label: const Text('Browse'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedImageBytes != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a category name'),
                                ),
                              );
                              return;
                            }
                            if (selectedImageBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select an image for the category',
                                  ),
                                ),
                              );
                              return;
                            }
                            try {
                              final DatabaseHelper _dbHelper = DatabaseHelper();
                              Map<String, dynamic> dbData = {
                                'data': nameController.text.trim(),
                                'isCustom': 'true',
                                'iconimage': selectedImageBytes,
                              };

                              bool categoryExists =
                                  await TargetCategoryService.categoryExists(
                                    nameController.text.trim(),
                                  );

                              if (isEditing) {
                                if (category!.name !=
                                        nameController.text.trim() &&
                                    categoryExists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Category "${nameController.text.trim()}" already exists!',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                int result = await _dbHelper
                                    .updateCategoryByName(
                                      "TABLE_TARGETCATEGORY",
                                      dbData,
                                      category.name,
                                    );
                                if (result > 0) {
                                  await _loadTargetCategories();
                                  setState(() {
                                    if (selectedTarget == category.name) {
                                      selectedTarget =
                                          nameController.text.trim();
                                    }
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Category "${nameController.text.trim()}" updated successfully!',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to update category. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                if (categoryExists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Category "${nameController.text.trim()}" already exists!',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                int result = await _dbHelper.insertData(
                                  "TABLE_TARGETCATEGORY",
                                  dbData,
                                );

                                if (result > 0) {
                                  await _loadTargetCategories();
                                  setState(
                                    () =>
                                        selectedTarget =
                                            nameController.text.trim(),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'New category "${nameController.text.trim()}" added successfully!',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to add category. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to ${isEditing ? 'update' : 'add'} category. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: Text(
                            isEditing ? 'Update Category' : 'Add Category',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFile(
    StateSetter setDialogState,
    Function(Uint8List?) onImageSelected,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        setDialogState(() => onImageSelected(bytes));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCalculator(BuildContext context, String type) {
    String currentValue = '';
    String firstNumber = '';
    String operator = '';
    String displayExpression = '';
    bool isOperatorPressed = false;
    bool showResult = false;

    const buttonRows = [
      ['1', '2', '3', '/'],
      ['4', '5', '6', '-'],
      ['7', '8', '9', 'X'],
      ['.', '0', '%', '+'],
      ['DEL', '='],
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (displayExpression.isNotEmpty)
                            Text(
                              displayExpression,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            currentValue.isEmpty ? '0' : currentValue,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  showResult
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...buttonRows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              row.map((buttonText) {
                                final isOperator = [
                                  '/',
                                  '-',
                                  'X',
                                  '+',
                                  '=',
                                  'DEL',
                                  '%',
                                ].contains(buttonText);
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (buttonText == 'DEL') {
                                            if (showResult) {
                                              currentValue = '';
                                              displayExpression = '';
                                              firstNumber = '';
                                              operator = '';
                                              isOperatorPressed = false;
                                              showResult = false;
                                            } else if (currentValue
                                                .isNotEmpty) {
                                              currentValue = currentValue
                                                  .substring(
                                                    0,
                                                    currentValue.length - 1,
                                                  );
                                            }
                                          } else if (buttonText == '=') {
                                            if (firstNumber.isNotEmpty &&
                                                operator.isNotEmpty &&
                                                currentValue.isNotEmpty) {
                                              try {
                                                final num1 = double.parse(
                                                  firstNumber,
                                                );
                                                final num2 = double.parse(
                                                  currentValue,
                                                );
                                                double result = 0;

                                                displayExpression =
                                                    '$firstNumber $operator $currentValue =';
                                                switch (operator) {
                                                  case '+':
                                                    result = num1 + num2;
                                                    break;
                                                  case '-':
                                                    result = num1 - num2;
                                                    break;
                                                  case 'X':
                                                    result = num1 * num2;
                                                    break;
                                                  case '/':
                                                    result =
                                                        num2 != 0
                                                            ? num1 / num2
                                                            : 0;
                                                    break;
                                                  case '%':
                                                    result =
                                                        num1 * (num2 / 100);
                                                    break;
                                                }
                                                currentValue = result
                                                    .toStringAsFixed(2)
                                                    .replaceAll(
                                                      RegExp(r'\.?0*$'),
                                                      '',
                                                    );
                                                showResult = true;
                                                firstNumber = '';
                                                operator = '';
                                                isOperatorPressed = false;
                                              } catch (e) {
                                                currentValue = 'Error';
                                                displayExpression = '';
                                                showResult = true;
                                              }
                                            }
                                          } else if (isOperator &&
                                              buttonText != '=') {
                                            if (showResult) {
                                              firstNumber = currentValue;
                                              operator = buttonText;
                                              displayExpression =
                                                  '$currentValue $buttonText';
                                              currentValue = '';
                                              isOperatorPressed = true;
                                              showResult = false;
                                            } else if (currentValue
                                                    .isNotEmpty &&
                                                !isOperatorPressed) {
                                              firstNumber = currentValue;
                                              operator = buttonText;
                                              displayExpression =
                                                  '$currentValue $buttonText';
                                              currentValue = '';
                                              isOperatorPressed = true;
                                            }
                                          } else {
                                            if (showResult) {
                                              currentValue = buttonText;
                                              displayExpression = '';
                                              firstNumber = '';
                                              operator = '';
                                              isOperatorPressed = false;
                                              showResult = false;
                                            } else {
                                              currentValue += buttonText;
                                              isOperatorPressed = false;
                                            }
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isOperator
                                                ? Colors.grey[400]
                                                : Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        buttonText,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          final value = double.tryParse(currentValue) ?? 0.0;
                          if (type == 'target') {
                            targetAmount = value;
                            _targetAmountController.text =
                                value > 0 ? value.toString() : '';
                          } else if (type == 'saved') {
                            savedAmount = value;
                            _savedAmountController.text =
                                value > 0 ? value.toString() : '';
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'INSERT',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat(
          'dd-MM-yyyy',
        ).format(picked); // FIXED: Use DateFormat
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            widget.dream == null ? 'Add Dream' : 'Edit Dream',
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          widget.dream == null ? 'Add Dream' : 'Edit Dream',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showTargetCategoriesDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      if (selectedTarget != null) ...[
                        _buildCategoryIcon(_getSelectedCategory()!, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          selectedTarget!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ] else ...[
                        Text(
                          'Select Target',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetNameController,
                decoration: const InputDecoration(
                  hintText: 'Target Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter a target name'
                            : null,
                onChanged: (value) => targetName = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  hintText: 'Target Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'target'),
                readOnly: true,
                validator:
                    (value) =>
                        targetAmount <= 0
                            ? 'Please enter a valid target amount'
                            : null,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedInvestment,
                    hint: const Text('Select Investment'),
                    isExpanded: true,
                    onChanged:
                        (value) => setState(() => selectedInvestment = value),
                    items:
                        investmentAccounts.map<DropdownMenuItem<String>>((
                          InvestmentAccount account,
                        ) {
                          return DropdownMenuItem<String>(
                            value: account.name,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    account.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '₹${account.balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                        account.balance >= 0
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _savedAmountController,
                decoration: const InputDecoration(
                  hintText: 'Saved Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'saved'),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  hintText: 'Select Target Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator:
                    (value) =>
                        selectedDate == null
                            ? 'Please select a target date'
                            : null,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate() &&
                        selectedTarget != null) {
                      await _saveOrUpdateDream();
                      if (_dreamId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddMileStonePage(targetId: _dreamId!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to save dream. Please try again.',
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add MileStone'),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => notes = value,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (selectedTarget == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a target category'),
                        ),
                      );
                      return;
                    }

                    // FIXED: Use _saveOrUpdateDream for consistency
                    final success = await _saveOrUpdateDream(isFinalSave: true);
                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    widget.dream == null ? 'Add' : 'Update',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvestmentAccount {
  final String name;
  final double balance;

  InvestmentAccount({required this.name, required this.balance});
}
