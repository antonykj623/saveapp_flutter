import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImagePickerUtils {
  static const int MIN_IMAGE_SIZE_KB = 10; // Minimum size: 10KB
  static const int MAX_IMAGE_SIZE_KB = 100; // Maximum size: 100KB (aligned with image>100 error)
  static const int MAX_DIMENSION = 800; // Reduced dimension for smaller images
  static const int JPEG_QUALITY = 75; // Reduced quality for better compression

  static Future<Uint8List?> pickAndProcessImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    bool showValidationMessages = true,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: JPEG_QUALITY,
        maxWidth: MAX_DIMENSION.toDouble(),
        maxHeight: MAX_DIMENSION.toDouble(),
      );

      if (pickedFile == null) {
        return null;
      }

      // Read file bytes
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      
      // Validate minimum size
      if (imageBytes.length < MIN_IMAGE_SIZE_KB * 1024) {
        if (showValidationMessages && context.mounted) {
          _showErrorMessage(
            context,
            'Image Too Small',
            'Please select an image larger than ${MIN_IMAGE_SIZE_KB}KB.\nCurrent size: ${(imageBytes.length / 1024).toStringAsFixed(1)}KB',
          );
        }
        return null;
      }

      // Validate maximum size before processing
      if (imageBytes.length > MAX_IMAGE_SIZE_KB * 1024) {
        if (showValidationMessages && context.mounted) {
          _showErrorMessage(
            context,
            'Image Too Large',
            'Please select an image smaller than ${MAX_IMAGE_SIZE_KB}KB.\nCurrent size: ${(imageBytes.length / 1024).toStringAsFixed(1)}KB',
          );
        }
        return null;
      }

      // Process and compress the image
      final Uint8List? processedImage = await _processImage(imageBytes);
      
      if (processedImage == null) {
        if (showValidationMessages && context.mounted) {
          _showErrorMessage(
            context,
            'Image Processing Failed',
            'Unable to process the selected image. Please try a different image.',
          );
        }
        return null;
      }

      // Validate final size
      if (processedImage.length < MIN_IMAGE_SIZE_KB * 1024) {
        if (showValidationMessages && context.mounted) {
          _showErrorMessage(
            context,
            'Processed Image Too Small',
            'The processed image is too small (${(processedImage.length / 1024).toStringAsFixed(1)}KB).\nMinimum required: ${MIN_IMAGE_SIZE_KB}KB',
          );
        }
        return null;
      }

      if (processedImage.length > MAX_IMAGE_SIZE_KB * 1024) {
        if (showValidationMessages && context.mounted) {
          _showErrorMessage(
            context,
            'Processed Image Too Large',
            'The processed image exceeds ${MAX_IMAGE_SIZE_KB}KB (${(processedImage.length / 1024).toStringAsFixed(1)}KB). Please select a smaller image.',
          );
        }
        return null;
      }

      if (showValidationMessages && context.mounted) {
        _showSuccessMessage(
          context,
          'Image Processed Successfully',
          'Original: ${(imageBytes.length / 1024).toStringAsFixed(1)}KB → Processed: ${(processedImage.length / 1024).toStringAsFixed(1)}KB',
        );
      }

      return processedImage;

    } catch (e) {
      print("Error picking and processing image: $e");
      if (showValidationMessages && context.mounted) {
        _showErrorMessage(
          context,
          'Error',
          'Failed to process image: ${e.toString()}',
        );
      }
      return null;
    }
  }

  static Future<Uint8List?> _processImage(Uint8List imageBytes) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print("Failed to decode image");
        return null;
      }

      // Resize if too large
      if (image.width > MAX_DIMENSION || image.height > MAX_DIMENSION) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? MAX_DIMENSION : null,
          height: image.height > image.width ? MAX_DIMENSION : null,
          interpolation: img.Interpolation.average, // Better for compression
        );
      }

      // Compress the image
      Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: JPEG_QUALITY),
      );

      // If still too large, iteratively reduce quality
      int quality = JPEG_QUALITY;
      while (compressedBytes.length > MAX_IMAGE_SIZE_KB * 1024 && quality > 20) {
        quality -= 10;
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );
      }

      // If still too large, resize further
      if (compressedBytes.length > MAX_IMAGE_SIZE_KB * 1024) {
        image = img.copyResize(
          image,
          width: (image.width * 0.8).round(),
          height: (image.height * 0.8).round(),
        );
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );
      }

      // Final size check
      if (compressedBytes.length > MAX_IMAGE_SIZE_KB * 1024) {
        print("Failed to compress image below ${MAX_IMAGE_SIZE_KB}KB");
        return null;
      }

      return compressedBytes;

    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  static void _showErrorMessage(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static void _showSuccessMessage(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Future<Uint8List?> showImagePickerDialog(BuildContext context) async {
    if (!context.mounted) return null;

    return showDialog<Uint8List?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose how you want to select an image:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                subtitle: const Text('Pick from photo gallery'),
                onTap: () async {
                  final image = await pickAndProcessImage(
                    context: context,
                    source: ImageSource.gallery,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () async {
                  final image = await pickAndProcessImage(
                    context: context,
                    source: ImageSource.camera,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, image);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static bool isValidImageData(Uint8List? imageData) {
    if (imageData == null || imageData.isEmpty) {
      return false;
    }
    
    return imageData.length >= MIN_IMAGE_SIZE_KB * 1024 && 
           imageData.length <= MAX_IMAGE_SIZE_KB * 1024;
  }

  static String getImageSizeInfo(Uint8List? imageData) {
    if (imageData == null || imageData.isEmpty) {
      return 'No image data';
    }
    
    final sizeKB = (imageData.length / 1024).toStringAsFixed(1);
    final status = isValidImageData(imageData) ? '✓' : '✗';
    return '$status ${sizeKB}KB';
  }

  static bool validateImageForStorage(Uint8List? imageData, BuildContext? context) {
    if (imageData == null || imageData.isEmpty) {
      if (context != null && context.mounted) {
        _showErrorMessage(
          context,
          'No Image Data',
          'No image data to store.',
        );
      }
      return false;
    }

    if (imageData.length < MIN_IMAGE_SIZE_KB * 1024) {
      if (context != null && context.mounted) {
        _showErrorMessage(
          context,
          'Image Too Small',
          'Image must be at least ${MIN_IMAGE_SIZE_KB}KB. Current: ${(imageData.length / 1024).toStringAsFixed(1)}KB',
        );
      }
      return false;
    }

    if (imageData.length > MAX_IMAGE_SIZE_KB * 1024) {
      if (context != null && context.mounted) {
        _showErrorMessage(
          context,
          'Image Too Large',
          'Image must be less than ${MAX_IMAGE_SIZE_KB}KB. Current: ${(imageData.length / 1024).toStringAsFixed(1)}KB',
        );
      }
      return false;
    }

    return true;
  }
}