import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';
import 'package:new_project_2025/view/home/dream_page/mile_stone_screen/miles_stone_screen.dart';

// You may need to adjust imports for your project structure

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    if (widget.dream != null) {
      selectedTarget = widget.dream!.category;
      targetName = widget.dream!.name;
      targetAmount = widget.dream!.targetAmount;
      selectedInvestment = widget.dream!.investment;
      savedAmount = widget.dream!.savedAmount;
      selectedDate = widget.dream!.targetDate;
      notes = widget.dream!.notes;
    }
  }

  Future<void> _initializeData() async {
    try {
      await _loadTargetCategories();
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

  Future<bool> _checkIfTargetAdded(String target) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('target_$target') ?? false;
  }

  Future<void> _setTargetAdded(String target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('target_$target', true);
  }

  Future<bool> _isCategoryUsed(String categoryName) async {
    return false;
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
                initialValue: targetName,
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
                decoration: const InputDecoration(
                  hintText: 'Target Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'target'),
                readOnly: true,
                controller: TextEditingController(
                  text: targetAmount > 0 ? targetAmount.toString() : '',
                ),
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
                        (verified) =>
                            setState(() => selectedInvestment = verified),
                    items: const [
                      DropdownMenuItem(
                        value: 'My Saving',
                        child: Text('My Saving'),
                      ),
                      DropdownMenuItem(
                        value: 'Fixed Deposit',
                        child: Text('Fixed Deposit'),
                      ),
                      DropdownMenuItem(
                        value: 'Mutual Fund',
                        child: Text('Mutual Fund'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Saved Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onTap: () => _showCalculator(context, 'saved'),
                readOnly: true,
                controller: TextEditingController(
                  text: savedAmount > 0 ? savedAmount.toString() : '',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Select Target Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text:
                      selectedDate != null
                          ? '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                          : '',
                ),
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
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMileStonePage(),
                        ),
                      ),
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
                initialValue: notes,
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
                    if (widget.dream == null) {
                      bool isTargetAdded = await _checkIfTargetAdded(
                        selectedTarget!,
                      );
                      if (isTargetAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Target category "$selectedTarget" has already been added.',
                            ),
                          ),
                        );
                        return;
                      }
                    }
                    final updatedDream = Dream(
                      name: targetName,
                      category: selectedTarget!,
                      investment: selectedInvestment ?? 'My Saving',
                      targetAmount: targetAmount,
                      savedAmount: savedAmount,
                      targetDate: selectedDate ?? DateTime.now(),
                      notes: notes,
                    );
                    if (widget.dream == null) {
                      await _setTargetAdded(selectedTarget!);
                      widget.onDreamAdded(updatedDream);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dream added successfully!'),
                        ),
                      );
                    } else {
                      widget.onDreamUpdated?.call(updatedDream);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dream updated successfully!'),
                        ),
                      );
                    }
                    Navigator.pop(context);
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
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

                                        // category.isCustom
                                        //     ? IconButton(
                                        //       icon: const Icon(
                                        //         Icons.edit,
                                        //         size: 18,
                                        //       ),
                                        //       color:
                                        //           isUsed
                                        //               ? Colors.grey
                                        //               : Colors.teal,
                                        //       tooltip:
                                        //           isUsed
                                        //               ? 'Cannot edit: Category in use'
                                        //               : 'Edit category',
                                        //       onPressed:
                                        //           isUsed
                                        //               ? null
                                        //               : () {
                                        //                 Navigator.pop(context);
                                        //                 _showAddNewCategoryDialog(
                                        //                   category: category,
                                        //                 );
                                        //               },
                                        //     )
                                        //     : const SizedBox.shrink(), // Better than Container()
                                      ],
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
                                    (categoryExists ||
                                        await _checkIfTargetAdded(
                                          nameController.text.trim(),
                                        ))) {
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
                                  await _setTargetAdded(
                                    nameController.text.trim(),
                                  );
                                  if (category.name !=
                                      nameController.text.trim()) {
                                    await _setTargetAdded(category.name);
                                    await SharedPreferences.getInstance().then(
                                      (prefs) => prefs.remove(
                                        'target_${category.name}',
                                      ),
                                    );
                                  }
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
                                if (categoryExists ||
                                    await _checkIfTargetAdded(
                                      nameController.text.trim(),
                                    )) {
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
                                  await _setTargetAdded(
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
                          setState(() {
                            if (type == 'target') {
                              targetAmount = value;
                            } else if (type == 'saved') {
                              savedAmount = value;
                            }
                          });
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
      setState(() => selectedDate = picked);
    }
  }
}
