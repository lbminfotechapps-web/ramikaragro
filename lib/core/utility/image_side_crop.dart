
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageSideCrop {
  static Future<File> crop({
    required File source,
    double sidePercent = 0.12,
  }) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Unable to decode camera image');
    }

    if (sidePercent < 0 || sidePercent >= 0.5) {
      throw ArgumentError('Invalid crop percentage');
    }

    final int cropLeft =
        (decoded.width * sidePercent).round();

    final int cropWidth =
        decoded.width - (cropLeft * 2);

    if (cropWidth <= 0) {
      throw Exception('Invalid cropped image width');
    }

    // CHANGED: Remove left and right strips.
    final img.Image cropped = img.copyCrop(
      decoded,
      x: cropLeft,
      y: 0,
      width: cropWidth,
      height: decoded.height,
    );

    final String outputPath =
        '${source.parent.path}${Platform.pathSeparator}'
        'cropped_${DateTime.now().microsecondsSinceEpoch}.jpg';

    final File outputFile = File(outputPath);

    await outputFile.writeAsBytes(
      img.encodeJpg(cropped, quality: 85),
      flush: true,
    );

    debugPrint('========== IMAGE CROP ==========');
    debugPrint('ORIGINAL: ${decoded.width}x${decoded.height}');
    debugPrint('CROPPED: ${cropped.width}x${cropped.height}');
    debugPrint('OUTPUT: ${outputFile.path}');
    debugPrint('================================');

    return outputFile;
  }
}
