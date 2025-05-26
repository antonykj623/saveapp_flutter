import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedFileType = 'Image';
  String? _selectedFilePath;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Document'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // File Type Dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFileType,
                    isExpanded: true,
                    items:
                        ['Image', 'Document', 'PDF'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFileType = newValue ?? 'Image';
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pick File Section
              const Text(
                'Pick image from gallery',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // File Picker Button
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Display selected file
              if (_selectedFilePath != null)
                Text(
                  'Selected: ${_selectedFilePath!.split('/').last}',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitDocuments,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: const Text(
            'Submit documents',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result;

      switch (_selectedFileType) {
        case 'Image':
          result = await FilePicker.platform.pickFiles(type: FileType.image);
          break;
        case 'Document':
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['doc', 'docx', 'txt'],
          );
          break;
        case 'PDF':
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
          break;
      }

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result!.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  void _submitDocuments() {
    // This is just UI design as requested, no actual functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document upload UI demo - not implemented'),
      ),
    );
    Navigator.of(context).pop();
  }
}
