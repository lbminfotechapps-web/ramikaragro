

import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AppImagePicker {
  AppImagePicker._();

  static final AppImagePicker instance = AppImagePicker._();

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }
}