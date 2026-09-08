import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

// class ImageCompression {
//   static Future<String> imageToOptimizedBase64(
//     File file, {
//     int maxWidth = 450,
//     int maxHeight = 450,
//     int quality = 45,
//   }) async {
//     try {
//       final bytes = await file.readAsBytes();

//       final decodedImage = img.decodeImage(bytes);

//       if (decodedImage == null) {
//         throw Exception('Unable to decode image');
//       }

//       final resizedImage = img.copyResize(
//         decodedImage,
//         width: decodedImage.width > maxWidth
//             ? maxWidth
//             : decodedImage.width,
//         height: decodedImage.height > maxHeight
//             ? maxHeight
//             : decodedImage.height,
//         maintainAspect: true,
//       );

//       final compressedBytes = img.encodeJpg(
//         resizedImage,
//         quality: quality,
//       );

//       print(
//         'Original size: '
//         '${(bytes.length / 1024).toStringAsFixed(2)} KB',
//       );

//       print(
//         'Compressed size: '
//         '${(compressedBytes.length / 1024).toStringAsFixed(2)} KB',
//       );

//       return base64Encode(compressedBytes);
//     } catch (e) {
//       print('Image compression error: $e');
//       return '';
//     }
//   }
// }

class ImageCompression {
  static Future<File?> compressImage(
    File file, {
    int maxWidth = 450,
    int maxHeight = 450,
    int quality = 45,
  }) async {
    try {
      final bytes = await file.readAsBytes();

      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('Unable to decode image');
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: decodedImage.width > maxWidth ? maxWidth : decodedImage.width,
        height: decodedImage.height > maxHeight
            ? maxHeight
            : decodedImage.height,
        maintainAspect: true,
      );

      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      final directory = file.parent;

      final compressedFile = File(
        '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await compressedFile.writeAsBytes(compressedBytes);

      print(
        'Original size: '
        '${(bytes.length / 1024).toStringAsFixed(2)} KB',
      );

      print(
        'Compressed size: '
        '${(compressedBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      print('Compressed file: ${compressedFile.path}');

      return compressedFile;
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }
}
